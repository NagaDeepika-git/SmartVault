import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/vault_card.dart';
import '../../../data/models/product_model.dart';

/// Reusable product card component with warranty countdown pill and price tag.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggleFavorite,
  });

  IconData _getProductIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.smartphones:
        return Icons.smartphone_rounded;
      case ProductCategory.laptops:
        return Icons.laptop_mac_rounded;
      case ProductCategory.appliances:
        return Icons.kitchen_rounded;
      case ProductCategory.electronics:
        return Icons.headphones_rounded;
      case ProductCategory.furniture:
        return Icons.chair_rounded;
      case ProductCategory.other:
        return Icons.devices_other_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warranty = product.warrantyResult;

    return VaultCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Icon Emblem
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.champagne.withValues(alpha: 0.14),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: AppColors.champagne.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Icon(_getProductIcon(product.category), color: AppColors.champagne, size: 24),
              ),
              const SizedBox(width: 14),

              // Name, Brand & Model
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.brand ?? ''} ${product.model != null ? '• ${product.model}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Heart Button
              IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: product.isFavorite ? AppColors.error : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Price and Warranty Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Purchase Price
              if (product.purchasePrice != null)
                Text(
                  CurrencyFormatter.format(product.purchasePrice, symbol: product.currency),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    letterSpacing: -0.2,
                  ),
                )
              else
                Text(
                  'Purchased ${DateFormatter.formatShortDate(product.purchaseDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),

              // Warranty Status Pill
              StatusBadge.fromWarrantyStatus(
                warranty.status,
                customLabel: warranty.statusLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
