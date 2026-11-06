import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/models/document_model.dart';
import '../products/product_provider.dart';
import 'document_provider.dart';
import 'document_form_screen.dart';
import 'widgets/document_preview_sheet.dart';

/// Detailed view for a single Document in SmartVault.
/// Displays complete metadata, tags, attachment preview modal, and connected product navigation.
class DocumentDetailScreen extends StatelessWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  void _showDeleteConfirmation(BuildContext context, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to remove "${doc.title}" from your vault? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<DocumentProvider>().deleteDocument(doc.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document deleted from Vault')),
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

  void _showAttachmentPreview(BuildContext context, DocumentModel doc) {
    DocumentPreviewSheet.show(context, doc);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DocumentProvider>();
    final productProvider = context.watch<ProductProvider>();

    final doc = provider.documents.firstWhere(
      (d) => d.id == documentId,
      orElse: () => DocumentModel(
        id: documentId,
        title: 'Document Not Found',
        category: DocumentCategory.other,
      ),
    );

    // Linked product if any
    final linkedProduct = doc.productId != null
        ? productProvider.products.where((p) => p.id == doc.productId).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: [
          IconButton(
            icon: Icon(
              doc.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: doc.isFavorite ? AppColors.error : null,
            ),
            tooltip: 'Toggle Favorite',
            onPressed: () => provider.toggleFavorite(doc.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Document',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => DocumentFormScreen(documentToEdit: doc),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Document',
            onPressed: () => _showDeleteConfirmation(context, doc),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentContainer(
        maxWidth: 720,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: ListView(
          children: [
            // Header Card
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
                          doc.category.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.champagne,
                          ),
                        ),
                      ),
                      if (doc.isSample)
                        StatusBadge.sample(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    doc.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (doc.issuer != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          doc.issuer!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (doc.description != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      doc.description!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date & Expiration Card
            VaultCard(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Issue Date',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatDate(doc.issueDate),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiration Status',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (doc.expiryDate != null)
                          Text(
                            doc.isExpired
                                ? 'Expired (${DateFormatter.formatDate(doc.expiryDate)})'
                                : 'Expires: ${DateFormatter.formatDate(doc.expiryDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: doc.isExpired ? AppColors.error : AppColors.warning,
                            ),
                          )
                        else
                          const Text(
                            'Does Not Expire',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Connected Product Link Banner (Connecting the 2 apps)
            if (linkedProduct != null)
              VaultCard(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    RouteNames.productDetail,
                    arguments: linkedProduct.id,
                  );
                },
                backgroundColor: AppColors.amber.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.link_rounded, color: AppColors.amber, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Associated Product Asset',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.amber),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            linkedProduct.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${linkedProduct.brand ?? ''} • Warranty: ${linkedProduct.warrantyResult.statusLabel}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.amber),
                  ],
                ),
              ),
            if (linkedProduct != null) const SizedBox(height: 16),

            // Attachment Section
            VaultCard(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attached File',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      if (doc.hasAttachment)
                        TextButton.icon(
                          onPressed: () => _showAttachmentPreview(context, doc),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('Preview'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (doc.hasAttachment)
                    InkWell(
                      onTap: () => _showAttachmentPreview(context, doc),
                      borderRadius: AppRadius.radiusMd,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(color: AppColors.champagne.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              doc.fileType == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                              color: AppColors.champagne,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.filePath ?? 'document.pdf',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${doc.fileType?.toUpperCase() ?? "PDF"} • ${doc.formattedFileSize.isNotEmpty ? doc.formattedFileSize : "Verified Vault Record"} • Tap to Preview',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.champagne : const Color(0xFF8B6B1B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_full_rounded, size: 18, color: AppColors.champagne),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No physical file attached to this vault record.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tags Section
            if (doc.tags.isNotEmpty) ...[
              VaultCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tags', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doc.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Section
            if (doc.notes != null && doc.notes!.isNotEmpty) ...[
              VaultCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vault Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      doc.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
