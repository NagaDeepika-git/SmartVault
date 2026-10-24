import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/vault_card.dart';
import '../../../data/models/document_model.dart';

/// Reusable document card representing an individual record in the vault.
class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
  });

  IconData _getCategoryIcon(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.academic:
        return Icons.school_rounded;
      case DocumentCategory.identity:
        return Icons.badge_rounded;
      case DocumentCategory.employment:
        return Icons.work_rounded;
      case DocumentCategory.financial:
        return Icons.account_balance_rounded;
      case DocumentCategory.medical:
        return Icons.medical_services_rounded;
      case DocumentCategory.receipts:
        return Icons.receipt_long_rounded;
      case DocumentCategory.warranty:
        return Icons.verified_user_rounded;
      case DocumentCategory.other:
        return Icons.description_rounded;
    }
  }

  Color _getCategoryColor(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.academic:
        return AppColors.champagne;
      case DocumentCategory.identity:
        return AppColors.info;
      case DocumentCategory.employment:
        return const Color(0xFF818CF8);
      case DocumentCategory.financial:
        return AppColors.success;
      case DocumentCategory.medical:
        return const Color(0xFFF472B6);
      case DocumentCategory.receipts:
        return AppColors.amber;
      case DocumentCategory.warranty:
        return const Color(0xFF34D399);
      case DocumentCategory.other:
        return AppColors.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(document.category);

    return VaultCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Emblem
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Icon(_getCategoryIcon(document.category), color: categoryColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title, Issuer, and Category Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      document.issuer ?? document.category.label,
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

              // Favorite Heart Toggle Button
              IconButton(
                icon: Icon(
                  document.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: document.isFavorite ? AppColors.error : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metadata Chips & Badges Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Category Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Text(
                  document.category.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: categoryColor),
                ),
              ),

              // Expiry or Issue Date Badge
              if (document.expiryDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: document.isExpired ? AppColors.errorBackground : AppColors.warningBackground,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        document.isExpired ? Icons.cancel_outlined : Icons.timer_outlined,
                        size: 12,
                        color: document.isExpired ? AppColors.error : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        document.isExpired
                            ? 'Expired (${DateFormatter.formatDate(document.expiryDate)})'
                            : 'Expires in ${document.daysUntilExpiry} days',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: document.isExpired ? AppColors.error : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                )
              else if (document.issueDate != null)
                Text(
                  'Issued: ${DateFormatter.formatDate(document.issueDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),

              // Attachment Indicator
              if (document.hasAttachment)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 12, color: AppColors.champagne),
                      const SizedBox(width: 3),
                      Text(
                        document.fileType?.toUpperCase() ?? 'FILE',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.champagne),
                      ),
                    ],
                  ),
                ),

              // Connected Product Badge
              if (document.productId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.12),
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded, size: 12, color: AppColors.amber),
                      SizedBox(width: 3),
                      Text(
                        'Linked Asset',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.amber),
                      ),
                    ],
                  ),
                ),

              // Sample Data Badge
              if (document.isSample)
                StatusBadge.sample(),
            ],
          ),
        ],
      ),
    );
  }
}
