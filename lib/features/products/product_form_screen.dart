import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/services/attachment_service.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../data/models/product_model.dart';
import '../documents/document_provider.dart';
import 'product_provider.dart';

/// Form screen for adding and updating product and asset records in SmartVault.
class ProductFormScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _serialController;
  late TextEditingController _priceController;
  late TextEditingController _sellerController;
  late TextEditingController _warrantyNotesController;

  late ProductCategory _selectedCategory;
  late DateTime _purchaseDate;
  DateTime? _warrantyStartDate;
  DateTime? _warrantyEndDate;
  String _selectedCurrency = '\$';
  String? _selectedInvoiceDocId;
  String? _imagePath;
  String? _imageData;
  bool _isFavorite = false;
  bool _isSubmitting = false;

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _modelController = TextEditingController(text: p?.model ?? '');
    _serialController = TextEditingController(text: p?.serialNumber ?? '');
    _priceController = TextEditingController(text: p?.purchasePrice?.toStringAsFixed(2) ?? '');
    _sellerController = TextEditingController(text: p?.seller ?? '');
    _warrantyNotesController = TextEditingController(text: p?.warrantyNotes ?? '');

    _selectedCategory = p?.category ?? ProductCategory.laptops;
    _purchaseDate = p?.purchaseDate ?? DateTime.now();
    _warrantyStartDate = p?.warrantyStartDate ?? p?.purchaseDate;
    _warrantyEndDate = p?.warrantyEndDate;
    _selectedCurrency = p?.currency ?? '\$';
    _selectedInvoiceDocId = p?.invoiceDocumentId;
    _imagePath = p?.imagePath;
    _imageData = p?.imageData;
    _isFavorite = p?.isFavorite ?? false;

    // Load documents for invoice linkage dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().loadDocuments();
    });
  }

  void _attachProductPhoto() {
    final name = _nameController.text.trim().isEmpty ? 'Asset' : _nameController.text.trim();
    final brand = _brandController.text.trim().isEmpty ? 'Brand' : _brandController.text.trim();
    final photo = AttachmentService.createProductPhoto(productName: name, brand: brand);
    setState(() {
      _imagePath = photo.name;
      _imageData = photo.base64Data;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attached photo for $name'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeProductPhoto() {
    setState(() {
      _imagePath = null;
      _imageData = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _priceController.dispose();
    _sellerController.dispose();
    _warrantyNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate warranty date bounds
    final dateError = Validators.dateOrder(
      start: _warrantyStartDate,
      end: _warrantyEndDate,
      message: 'Warranty expiration date must be after warranty start date',
    );
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final double? parsedPrice = _priceController.text.trim().isNotEmpty
        ? double.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''))
        : null;

    final provider = context.read<ProductProvider>();

    bool success;
    if (_isEditing) {
      final updated = widget.productToEdit!.copyWith(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
        category: _selectedCategory,
        purchaseDate: _purchaseDate,
        purchasePrice: parsedPrice,
        currency: _selectedCurrency,
        seller: _sellerController.text.trim().isEmpty ? null : _sellerController.text.trim(),
        warrantyStartDate: _warrantyStartDate,
        warrantyEndDate: _warrantyEndDate,
        warrantyNotes: _warrantyNotesController.text.trim().isEmpty ? null : _warrantyNotesController.text.trim(),
        invoiceDocumentId: _selectedInvoiceDocId,
        imagePath: _imagePath,
        imageData: _imageData,
        isFavorite: _isFavorite,
      );
      success = await provider.updateProduct(updated);
    } else {
      final newProduct = ProductModel(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
        category: _selectedCategory,
        purchaseDate: _purchaseDate,
        purchasePrice: parsedPrice,
        currency: _selectedCurrency,
        seller: _sellerController.text.trim().isEmpty ? null : _sellerController.text.trim(),
        warrantyStartDate: _warrantyStartDate,
        warrantyEndDate: _warrantyEndDate,
        warrantyNotes: _warrantyNotesController.text.trim().isEmpty ? null : _warrantyNotesController.text.trim(),
        invoiceDocumentId: _selectedInvoiceDocId,
        imagePath: _imagePath,
        imageData: _imageData,
        isFavorite: _isFavorite,
        isSample: false,
      );
      success = await provider.createProduct(newProduct);
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Asset updated successfully' : 'New asset registered in Vault'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save product.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final documents = context.watch<DocumentProvider>().documents;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Asset Information' : 'Register New Asset'),
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
                      _isEditing ? 'Update Asset' : 'Register Asset in Vault',
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
              // Product Name
              CustomTextField(
                controller: _nameController,
                label: 'Product / Asset Name *',
                hint: 'e.g. MacBook Pro 16", Pixel 9 Pro, Dyson Purifier',
                prefixIcon: Icons.devices_rounded,
                validator: (val) => Validators.required(val, 'Product name'),
              ),
              const SizedBox(height: 18),

              // Category Selector
              CustomDropdownField<ProductCategory>(
                label: 'Category *',
                value: _selectedCategory,
                prefixIcon: Icons.category_rounded,
                items: ProductCategory.values.map((cat) {
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

              // Brand & Model Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _brandController,
                      label: 'Brand',
                      hint: 'e.g. Apple, Google, Sony',
                      prefixIcon: Icons.branding_watermark_outlined,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: _modelController,
                      label: 'Model / Variant',
                      hint: 'e.g. A2991, 256GB Space Black',
                      prefixIcon: Icons.info_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Serial Number (Sensitive Data)
              CustomTextField(
                controller: _serialController,
                label: 'Serial Number / IMEI (Protected)',
                hint: 'e.g. C02G8792MD6R',
                prefixIcon: Icons.qr_code_rounded,
                helperText: 'Protected: Masked in standard lists and views for security.',
              ),
              const SizedBox(height: 18),

              // Purchase Details Row (Date, Price, Currency)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomDatePickerField(
                      label: 'Purchase Date *',
                      selectedDate: _purchaseDate,
                      isRequired: true,
                      onDateSelected: (date) {
                        if (date != null) {
                          setState(() {
                            _purchaseDate = date;
                            _warrantyStartDate ??= date;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Purchase Price',
                      hint: '0.00',
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => Validators.optionalNumeric(val, 'Price'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomDropdownField<String>(
                      label: 'Currency',
                      value: _selectedCurrency,
                      items: const [
                        DropdownMenuItem(value: '\$', child: Text('USD (\$)')),
                        DropdownMenuItem(value: '€', child: Text('EUR (€)')),
                        DropdownMenuItem(value: '£', child: Text('GBP (£)')),
                        DropdownMenuItem(value: '₹', child: Text('INR (₹)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCurrency = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Seller / Store
              CustomTextField(
                controller: _sellerController,
                label: 'Seller / Store / Vendor',
                hint: 'e.g. Apple Official Store, Amazon Online, Best Buy',
                prefixIcon: Icons.storefront_outlined,
              ),
              const SizedBox(height: 18),

              // Warranty Dates Row
              Row(
                children: [
                  Expanded(
                    child: CustomDatePickerField(
                      label: 'Warranty Start Date',
                      selectedDate: _warrantyStartDate,
                      onDateSelected: (date) => setState(() => _warrantyStartDate = date),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomDatePickerField(
                      label: 'Warranty End Date',
                      hint: 'No Expiry Date',
                      selectedDate: _warrantyEndDate,
                      onDateSelected: (date) => setState(() => _warrantyEndDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Warranty Notes
              CustomTextField(
                controller: _warrantyNotesController,
                label: 'Warranty Coverage Notes',
                hint: 'e.g. AppleCare+ 2-Year global hardware coverage, accidental damage...',
                prefixIcon: Icons.shield_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 18),

              // Asset Photo Attachment
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asset Photo / Physical Verification',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_imageData != null || _imagePath != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.champagne.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.champagne.withValues(alpha: 0.15),
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
                                  _imagePath ?? 'asset_photo.jpg',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Photo attached & securely stored in Vault',
                                  style: TextStyle(fontSize: 12, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                            tooltip: 'Remove photo',
                            onPressed: _removeProductPhoto,
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _attachProductPhoto,
                        icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                        label: const Text('Capture or Attach Asset Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.champagne,
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Connect to Purchase Invoice (Document Linkage)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link Purchase Proof / Tax Invoice',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedInvoiceDocId,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.receipt_long_rounded, size: 20, color: AppColors.champagne),
                      hintText: 'Select invoice document from Vault',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No Linked Invoice Document'),
                      ),
                      ...documents.map((doc) {
                        return DropdownMenuItem<String?>(
                          value: doc.id,
                          child: Text('${doc.title} (${doc.category.label})'),
                        );
                      }),
                    ],
                    onChanged: (val) => setState(() => _selectedInvoiceDocId = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
