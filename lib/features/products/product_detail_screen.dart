import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/models/product_model.dart';
import '../documents/document_provider.dart';
import '../service_history/service_provider.dart';
import 'product_provider.dart';
import 'product_form_screen.dart';

/// Detailed view for a single Product / Asset record in SmartVault.
/// Displays warranty countdown, masked serial number toggle, linked invoices, and service history.
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isSerialRevealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadRecordsForProduct(widget.productId);
    });
  }

  void _showDeleteConfirmation(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product Asset?'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? All associated service history will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<ProductProvider>().deleteProduct(product.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product and history deleted from Vault')),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productProvider = context.watch<ProductProvider>();
    final documentProvider = context.watch<DocumentProvider>();
    final serviceProvider = context.watch<ServiceProvider>();

    final product = productProvider.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => ProductModel(
        id: widget.productId,
        name: 'Product Not Found',
        category: ProductCategory.other,
        purchaseDate: DateTime.now(),
      ),
    );

    final warranty = product.warrantyResult;
    final linkedInvoice = product.invoiceDocumentId != null
        ? documentProvider.documents.where((d) => d.id == product.invoiceDocumentId).firstOrNull
        : null;

    final serviceRecords = serviceProvider.recordsForProduct(widget.productId);
    final totalServiceCost = serviceProvider.totalCostForProduct(widget.productId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset & Warranty'),
        actions: [
          IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: product.isFavorite ? AppColors.error : null,
            ),
            tooltip: 'Toggle Favorite',
            onPressed: () => productProvider.toggleFavorite(product.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Asset',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ProductFormScreen(productToEdit: product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Asset',
            onPressed: () => _showDeleteConfirmation(context, product),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentContainer(
        maxWidth: 760,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: ListView(
          children: [
            // Header Info Card
            VaultCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withValues(alpha: 0.15),
                          borderRadius: AppRadius.radiusFull,
                          border: Border.all(color: AppColors.champagne.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          product.category.label,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.champagne),
                        ),
                      ),
                      if (product.isSample)
                        StatusBadge.sample(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.brand ?? 'Asset'} ${product.model != null ? '• ${product.model}' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (product.purchasePrice != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormatter.format(product.purchasePrice, symbol: product.currency),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.champagne,
                      ),
                    ),
                  ],
                  if (product.hasImage) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.champagne.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.champagne.withValues(alpha: 0.2),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: const Icon(Icons.photo_camera_rounded, color: AppColors.champagne, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.imagePath ?? 'Asset Photo',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Physical Asset Proof • Verified in Vault',
                                  style: TextStyle(fontSize: 11, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified_rounded, color: AppColors.champagne, size: 20),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Warranty Countdown & Progress Card
            VaultCard(
              padding: const EdgeInsets.all(20.0),
              backgroundColor: warranty.status == WarrantyStatus.expiringSoon
                  ? AppColors.warning.withValues(alpha: 0.08)
                  : warranty.status == WarrantyStatus.expired
                      ? AppColors.error.withValues(alpha: 0.08)
                      : null,
              border: Border.all(
                color: warranty.status == WarrantyStatus.expiringSoon
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : warranty.status == WarrantyStatus.expired
                        ? AppColors.error.withValues(alpha: 0.4)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Warranty Timeline',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      StatusBadge.fromWarrantyStatus(warranty.status),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Remaining Days Countdown Display
                  if (warranty.remainingDays != null) ...[
                    Text(
                      warranty.isExpired
                          ? 'Expired ${warranty.remainingDays!.abs()} days ago'
                          : warranty.remainingDays == 0
                              ? 'Expires Today'
                              : '${warranty.remainingDays} Days Remaining',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: warranty.isExpired
                            ? AppColors.error
                            : warranty.isExpiringSoon
                                ? AppColors.warning
                                : AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: AppRadius.radiusFull,
                      child: LinearProgressIndicator(
                        value: warranty.progress,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          warranty.isExpired
                              ? AppColors.error
                              : warranty.isExpiringSoon
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start: ${DateFormatter.formatDate(product.warrantyStartDate ?? product.purchaseDate)}',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                      Text(
                        'End: ${DateFormatter.formatDate(product.warrantyEndDate)}',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                    ],
                  ),

                  if (product.warrantyNotes != null && product.warrantyNotes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      product.warrantyNotes!,
                      style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sensitive Identifier Card (Serial Number Masking & Reveal)
            VaultCard(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, size: 22, color: AppColors.champagne),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serial Number (Masked)',
                          style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isSerialRevealed
                              ? (product.serialNumber ?? 'N/A')
                              : product.maskedSerialNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (product.serialNumber != null && product.serialNumber!.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        _isSerialRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                      ),
                      tooltip: _isSerialRevealed ? 'Hide Serial' : 'Reveal Serial',
                      onPressed: () => setState(() => _isSerialRevealed = !_isSerialRevealed),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Linked Purchase Invoice Banner
            if (linkedInvoice != null) ...[
              VaultCard(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    RouteNames.documentDetail,
                    arguments: linkedInvoice.id,
                  );
                },
                backgroundColor: AppColors.champagne.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.champagne.withValues(alpha: 0.35)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.champagne, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Linked Purchase Invoice',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.champagne),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            linkedInvoice.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Issued: ${DateFormatter.formatDate(linkedInvoice.issueDate)} • Tap to view proof',
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.champagne),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Service & Repair History Section
            VaultCard(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service & Repair History',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Total Maintenance Cost: ${CurrencyFormatter.format(totalServiceCost, symbol: product.currency)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.champagne),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.champagne),
                        tooltip: 'Add Service Record',
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            RouteNames.serviceForm,
                            arguments: product.id,
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  if (serviceRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          'No maintenance records logged for this asset yet.',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        ),
                      ),
                    )
                  else
                    ...serviceRecords.map((record) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.build_rounded, size: 14, color: AppColors.info),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.issueDescription,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${record.serviceProvider} • ${DateFormatter.formatDate(record.serviceDate)}',
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                  ),
                                  if (record.resolution != null)
                                    Text(
                                      record.resolution!,
                                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(record.cost, symbol: product.currency),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
