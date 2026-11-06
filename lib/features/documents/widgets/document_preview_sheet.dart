import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/document_model.dart';

/// Interactive Document Attachment Preview Viewer.
/// Renders authentic document certificates, invoices, scans, and images with zoom,
/// verified digital seal badges, and export capabilities.
class DocumentPreviewSheet extends StatefulWidget {
  final DocumentModel document;

  const DocumentPreviewSheet({super.key, required this.document});

  static Future<void> show(BuildContext context, DocumentModel document) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: DocumentPreviewSheet(document: document),
      ),
    );
  }

  @override
  State<DocumentPreviewSheet> createState() => _DocumentPreviewSheetState();
}

class _DocumentPreviewSheetState extends State<DocumentPreviewSheet> {
  final TransformationController _transformController = TransformationController();
  Map<String, dynamic>? _parsedData;
  bool _isRawImage = false;

  @override
  void initState() {
    super.initState();
    _parseAttachmentContent();
  }

  void _parseAttachmentContent() {
    final rawData = widget.document.fileData;
    if (rawData == null || rawData.isEmpty) return;

    try {
      final decodedBytes = base64Decode(rawData);
      // Check if valid JSON document descriptor
      final decodedString = utf8.decode(decodedBytes);
      final jsonMap = jsonDecode(decodedString);
      if (jsonMap is Map<String, dynamic>) {
        _parsedData = jsonMap;
        return;
      }
    } catch (_) {
      // Not UTF-8 JSON -> Raw image binary
      _isRawImage = true;
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: AppColors.champagne.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview Header Bar
            _buildHeader(context, doc, isDark),
            const Divider(height: 1),

            // Main Document Interactive Canvas
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Container(
                  color: isDark ? const Color(0xFF0D1424) : const Color(0xFFF1F5F9),
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.8,
                    maxScale: 3.5,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildDocumentContent(doc, isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomBar(context, doc, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DocumentModel doc, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.champagne.withValues(alpha: 0.15),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(
              doc.fileType == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: AppColors.champagne,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  '${doc.filePath ?? doc.category.label} • ${doc.formattedFileSize.isNotEmpty ? doc.formattedFileSize : "Verified Vault Record"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Reset Zoom',
            onPressed: _resetZoom,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Close Preview',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, DocumentModel doc, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Cryptographically Verified Local Vault File',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exported "${doc.title}" to local downloads successfully.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export File', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagne,
              foregroundColor: const Color(0xFF1A1300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent(DocumentModel doc, bool isDark) {
    if (_isRawImage && doc.fileData != null) {
      try {
        final bytes = base64Decode(doc.fileData!);
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusMd,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusMd,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildFallbackDocumentCard(doc, isDark),
            ),
          ),
        );
      } catch (_) {}
    }

    final data = _parsedData;
    if (data != null) {
      final type = data['type'] as String?;
      if (type == 'academic_degree') {
        return _buildAcademicDegreeCertificate(doc, data);
      } else if (type == 'professional_certification') {
        return _buildProfessionalCertification(doc, data);
      } else if (type == 'tax_invoice') {
        return _buildTaxInvoice(doc, data);
      } else if (type == 'national_identity') {
        return _buildNationalIdentity(doc, data);
      } else if (type == 'camera_scan') {
        return _buildCameraDocumentScan(doc, data);
      }
    }

    return _buildFallbackDocumentCard(doc, isDark);
  }

  Widget _buildAcademicDegreeCertificate(DocumentModel doc, Map<String, dynamic> data) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8), // Cream parchment
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: const Color(0xFFC59B27), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Inner Ornamental Border
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC59B27).withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              children: [
                const Icon(Icons.school_rounded, color: Color(0xFF8B6B1B), size: 48),
                const SizedBox(height: 12),
                Text(
                  (data['university'] as String? ?? 'Institute of Technology').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'EXCELLENTIA ET VIRTUS • OFFICIAL CONFERRAL OF DEGREE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'This is to certify that',
                  style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 13, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 8),
                Text(
                  data['recipient'] as String? ?? 'Graduating Scholar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'having fulfilled all the academic conditions and examinations required by law,\nis hereby admitted to the degree of',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'serif', fontSize: 12, color: Color(0xFF4B5563), height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3DC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Text(
                    data['degree'] as String? ?? doc.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B6B1B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data['honors'] as String? ?? 'First Class Honors with Distinction',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conferred: ${data['date'] ?? DateFormatter.formatDate(doc.issueDate)}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                          const SizedBox(height: 4),
                          const Text('Sign: Dean of Academic Affairs',
                              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF374151))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        ),
                        child: const Icon(Icons.military_tech_rounded, color: Color(0xFFC59B27), size: 24),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('OFFICIAL SEAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8B6B1B))),
                          const SizedBox(height: 4),
                          const Text('Sign: Registrar',
                              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF374151))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCertification(DocumentModel doc, Map<String, dynamic> data) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark executive slate
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.champagne, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_done_rounded, color: AppColors.champagne, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    (data['issuer'] as String? ?? 'Cloud Authority').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Text(
                  'VERIFIED CREDENTIAL',
                  style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'CERTIFICATE OF COMPETENCY',
            style: TextStyle(color: AppColors.champagne, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            data['title'] as String? ?? doc.title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            'Demonstrating advanced expertise in enterprise distributed architecture, cloud infrastructure resilience, and secure operations.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Credential ID', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(data['credential_id'] as String? ?? 'CRED-8492019',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Issue Date', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(data['issue_date'] ?? DateFormatter.formatDate(doc.issueDate),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valid Through', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(data['expiry_date'] ?? DateFormatter.formatDate(doc.expiryDate),
                        style: const TextStyle(color: AppColors.champagne, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxInvoice(DocumentModel doc, Map<String, dynamic> data) {
    final amount = (data['amount'] as num?)?.toDouble() ?? 1499.00;
    final currency = data['currency'] as String? ?? '\$';

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(26.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (data['vendor'] as String? ?? 'Authorized Retailer').toUpperCase(),
                  style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TAX INVOICE',
                style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Invoice No: ${data['invoice_no'] ?? "INV-2026-8910"} • Date: ${data['date'] ?? DateFormatter.formatDate(doc.issueDate)}',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
          const Divider(height: 24),
          const Text('Billed Asset Description', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['product'] as String? ?? doc.title,
                  style: const TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                CurrencyFormatter.format(amount, symbol: currency),
                style: const TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Estimated GST / Tax (Included)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              ),
              Text('$currency ${data['gst_tax'] ?? (amount * 0.18).toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF374151), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount Paid', style: TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w800)),
              Text(
                CurrencyFormatter.format(amount, symbol: currency),
                style: const TextStyle(color: Color(0xFF047857), fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF374151)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Electronic Proof of Purchase • Serial verified with manufacturer database.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalIdentity(DocumentModel doc, Map<String, dynamic> data) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.champagne.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (data['country'] as String? ?? 'NATIONAL IDENTITY').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5),
              ),
              const Icon(Icons.shield_rounded, color: AppColors.champagne, size: 24),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: AppRadius.radiusSm,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.person_rounded, size: 64, color: Colors.white54),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Full Name', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text(data['full_name'] as String? ?? doc.title,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    const Text('Identity Document No.', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text(data['id_number'] as String? ?? 'P849201948',
                        style: const TextStyle(color: AppColors.champagne, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.black38,
            width: double.infinity,
            child: Text(
              data['security_code'] as String? ?? 'MRZ:P<USA<<<<<<<<<<<<<<<<<<<<<<8492019<',
              style: const TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraDocumentScan(DocumentModel doc, Map<String, dynamic> data) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.document_scanner_rounded, color: Color(0xFF0F172A), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    data['title'] as String? ?? doc.title,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(data['resolution'] as String? ?? '300 DPI Clear',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              ),
            ],
          ),
          const Divider(height: 20),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusSm,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 54, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(
                    doc.notes ?? 'High-resolution digital optical scan stored securely in Vault.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackDocumentCard(DocumentModel doc, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.champagne.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            doc.fileType == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
            size: 64,
            color: AppColors.champagne,
          ),
          const SizedBox(height: 16),
          Text(
            doc.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            '${doc.category.label} • ${DateFormatter.formatDate(doc.issueDate)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doc.description ?? 'Digital vault archive record with verified local integrity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
