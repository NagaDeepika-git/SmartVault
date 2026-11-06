import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/services/attachment_service.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../data/models/document_model.dart';
import '../products/product_provider.dart';
import 'document_provider.dart';

/// Form screen for creating or editing Document records in SmartVault.
/// Fulfills Flutter syllabus Form, `GlobalKey<FormState>`, and input validation requirements.
class DocumentFormScreen extends StatefulWidget {
  final DocumentModel? documentToEdit;

  const DocumentFormScreen({super.key, this.documentToEdit});

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _issuerController;
  late TextEditingController _tagsController;
  late TextEditingController _notesController;

  late DocumentCategory _selectedCategory;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  String? _selectedProductId;
  String? _attachedFileName;
  String? _attachedFileType;
  int? _attachedFileSize;
  String? _attachedFileData;
  bool _isFavorite = false;
  bool _isSubmitting = false;

  bool get _isEditing => widget.documentToEdit != null;

  @override
  void initState() {
    super.initState();
    final doc = widget.documentToEdit;

    _titleController = TextEditingController(text: doc?.title ?? '');
    _issuerController = TextEditingController(text: doc?.issuer ?? '');
    _tagsController = TextEditingController(text: doc?.tags.join(', ') ?? '');
    _notesController = TextEditingController(text: doc?.notes ?? '');

    _selectedCategory = doc?.category ?? DocumentCategory.academic;
    _issueDate = doc?.issueDate;
    _expiryDate = doc?.expiryDate;
    _selectedProductId = doc?.productId;
    _attachedFileName = doc?.filePath;
    _attachedFileType = doc?.fileType;
    _attachedFileSize = doc?.fileSize;
    _attachedFileData = doc?.fileData;
    _isFavorite = doc?.isFavorite ?? false;

    // Load products for linkage dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAttachmentOptions() {
    final title = _titleController.text.trim().isEmpty ? 'Document' : _titleController.text.trim();
    final issuer = _issuerController.text.trim().isEmpty ? 'Official Authority' : _issuerController.text.trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Attach Verified Document', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x22F5C57A),
                  child: Icon(Icons.school_rounded, color: AppColors.champagne),
                ),
                title: const Text('Academic Degree / Diploma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Generates official degree parchment with university seals & Latin motto', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _setAttachment(AttachmentService.createAcademicDegreeScan(
                    recipientName: 'Naga Deepika Gogineni',
                    degreeTitle: title,
                    university: issuer,
                    graduationDate: 'June 15, 2024',
                  ));
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x22F59E0B),
                  child: Icon(Icons.receipt_long_rounded, color: AppColors.amber),
                ),
                title: const Text('Tax Invoice / Purchase Receipt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Generates GST retail invoice with itemized pricing & verification QR', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _setAttachment(AttachmentService.createTaxInvoiceScan(
                    vendor: issuer,
                    productName: title,
                    amount: 999.00,
                    currency: '\$',
                    invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    purchaseDate: 'October 24, 2026',
                  ));
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x2238BDF8),
                  child: Icon(Icons.badge_rounded, color: AppColors.info),
                ),
                title: const Text('National Identity / Passport Scan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Generates secure ID document with Machine-Readable Zone (MRZ)', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _setAttachment(AttachmentService.createGovernmentIdScan(
                    idType: title,
                    idNumber: 'P849201948',
                    fullName: 'Naga Deepika Gogineni',
                    country: issuer,
                  ));
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x2210B981),
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.success),
                ),
                title: const Text('Digital Optical Camera Scan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('300 DPI high-contrast optical paper scan with timestamp', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _setAttachment(AttachmentService.createCapturedDocumentPhoto(
                    title: title,
                    category: _selectedCategory.label,
                  ));
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _setAttachment(AttachmentFile file) {
    setState(() {
      _attachedFileName = file.name;
      _attachedFileType = file.fileType;
      _attachedFileSize = file.fileSize;
      _attachedFileData = file.base64Data;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attached ${file.name} (${file.fileType.toUpperCase()})'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeAttachment() {
    setState(() {
      _attachedFileName = null;
      _attachedFileType = null;
      _attachedFileSize = null;
      _attachedFileData = null;
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date sequence if both exist
    final dateError = Validators.dateOrder(
      start: _issueDate,
      end: _expiryDate,
      message: 'Expiry date must be after issue date',
    );
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final rawTags = _tagsController.text
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    final documentProvider = context.read<DocumentProvider>();

    bool success;
    if (_isEditing) {
      final updatedDoc = widget.documentToEdit!.copyWith(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        issuer: _issuerController.text.trim().isEmpty ? null : _issuerController.text.trim(),
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        filePath: _attachedFileName,
        fileType: _attachedFileType,
        fileSize: _attachedFileSize,
        fileData: _attachedFileData,
        tags: rawTags,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        productId: _selectedProductId,
        isFavorite: _isFavorite,
      );
      success = await documentProvider.updateDocument(updatedDoc);
    } else {
      final newDoc = DocumentModel(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        issuer: _issuerController.text.trim().isEmpty ? null : _issuerController.text.trim(),
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        filePath: _attachedFileName,
        fileType: _attachedFileType,
        fileSize: _attachedFileSize,
        fileData: _attachedFileData,
        tags: rawTags,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        productId: _selectedProductId,
        isFavorite: _isFavorite,
        isSample: false, // User-created records are not samples
      );
      success = await documentProvider.createDocument(newDoc);
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Document updated in Vault' : 'New document saved to Vault'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(documentProvider.errorMessage ?? 'Failed to save document.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Document' : 'Add New Document'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.error : null,
            ),
            tooltip: 'Favorite',
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagne,
                foregroundColor: const Color(0xFF1A1300),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1A1300)),
                    )
                  : Text(
                      _isEditing ? 'Update Document' : 'Save Document to Vault',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 720,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Document Title
              CustomTextField(
                controller: _titleController,
                label: 'Document Title *',
                hint: 'e.g. Bachelor of Science Degree, Apartment Lease',
                prefixIcon: Icons.title_rounded,
                validator: (val) => Validators.required(val, 'Document title'),
              ),
              const SizedBox(height: 18),

              // Category Selector
              CustomDropdownField<DocumentCategory>(
                label: 'Category *',
                value: _selectedCategory,
                prefixIcon: Icons.category_rounded,
                items: DocumentCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 18),

              // Issuer / Authority
              CustomTextField(
                controller: _issuerController,
                label: 'Issuer or Issuing Authority',
                hint: 'e.g. Stanford University, Ministry of State, Apple Inc.',
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 18),

              // Date Row
              Row(
                children: [
                  Expanded(
                    child: CustomDatePickerField(
                      label: 'Issue Date',
                      hint: 'Issue Date',
                      selectedDate: _issueDate,
                      onDateSelected: (date) => setState(() => _issueDate = date),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomDatePickerField(
                      label: 'Expiration Date',
                      hint: 'No Expiry',
                      selectedDate: _expiryDate,
                      onDateSelected: (date) => setState(() => _expiryDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Connect to Tracked Product (Asset Linking)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link to Product / Asset (Optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedProductId,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link_rounded, size: 20, color: AppColors.champagne),
                      hintText: 'Select product (e.g. MacBook Pro, Pixel 9)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No Associated Product'),
                      ),
                      ...products.map((p) {
                        return DropdownMenuItem<String?>(
                          value: p.id,
                          child: Text('${p.name} (${p.brand ?? 'Asset'})'),
                        );
                      }),
                    ],
                    onChanged: (val) => setState(() => _selectedProductId = val),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Attachment Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'File Attachment',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_attachedFileName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.champagne.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _attachedFileType == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                            color: AppColors.champagne,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _attachedFileName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _attachedFileType?.toUpperCase() ?? 'DOCUMENT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: AppColors.error,
                            onPressed: _removeAttachment,
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showAttachmentOptions,
                        icon: const Icon(Icons.attach_file_rounded, size: 20),
                        label: const Text('Add Document Scan or Digital Certificate', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.champagne,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.champagne.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Tags Input
              CustomTextField(
                controller: _tagsController,
                label: 'Tags (comma-separated)',
                hint: 'degree, graduation, academic, engineering',
                prefixIcon: Icons.tag_rounded,
              ),
              const SizedBox(height: 18),

              // Notes
              CustomTextField(
                controller: _notesController,
                label: 'Additional Notes',
                hint: 'Physical storage location, verification codes, or reminders...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
