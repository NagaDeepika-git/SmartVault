import 'package:uuid/uuid.dart';
import '../../core/utils/warranty_calculator.dart';

/// Categories of products tracked within SmartVault.
enum ProductCategory {
  smartphones('Smartphones', 'Mobile devices & accessories'),
  laptops('Laptops & Computers', 'PCs, MacBooks, tablets'),
  appliances('Home Appliances', 'Refrigerators, ACs, washers'),
  electronics('Electronics', 'Audio, cameras, TVs, consoles'),
  furniture('Furniture', 'Desks, chairs, household items'),
  other('Other Assets', 'Miscellaneous equipment');

  final String label;
  final String description;
  const ProductCategory(this.label, this.description);

  static ProductCategory fromString(String? value) {
    if (value == null) return ProductCategory.other;
    return ProductCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ProductCategory.other,
    );
  }
}

/// Core Product entity representing physical assets, warranties, and purchase details.
class ProductModel {
  final String id;
  final String name;
  final String? brand;
  final String? model;
  final String? serialNumber; // Sensitive identifier
  final ProductCategory category;
  final DateTime purchaseDate;
  final double? purchasePrice;
  final String currency;
  final String? seller;
  final String? imagePath;
  final String? imageData; // Base64 product photo representation
  final DateTime? warrantyStartDate;
  final DateTime? warrantyEndDate;
  final String? warrantyNotes;
  final String? invoiceDocumentId; // Linked document ID for purchase proof
  final String? warrantyDocumentId; // Linked document ID for warranty card
  final bool isFavorite;
  final bool isSample;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    String? id,
    required this.name,
    this.brand,
    this.model,
    this.serialNumber,
    required this.category,
    required this.purchaseDate,
    this.purchasePrice,
    this.currency = '\$',
    this.seller,
    this.imagePath,
    this.imageData,
    this.warrantyStartDate,
    this.warrantyEndDate,
    this.warrantyNotes,
    this.invoiceDocumentId,
    this.warrantyDocumentId,
    this.isFavorite = false,
    this.isSample = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasImage =>
      (imagePath != null && imagePath!.isNotEmpty) ||
      (imageData != null && imageData!.isNotEmpty);

  /// Calculates real-time date-based warranty metrics using WarrantyCalculator.
  WarrantyResult get warrantyResult {
    return WarrantyCalculator.calculate(
      startDate: warrantyStartDate ?? purchaseDate,
      endDate: warrantyEndDate,
    );
  }

  bool get hasWarranty => warrantyEndDate != null;

  /// Returns masked representation of serial number for security (e.g. "••••••••4829").
  String get maskedSerialNumber {
    if (serialNumber == null || serialNumber!.trim().isEmpty) {
      return 'N/A';
    }
    final clean = serialNumber!.trim();
    if (clean.length <= 4) {
      return '••••';
    }
    final lastFour = clean.substring(clean.length - 4);
    final prefixDots = '•' * (clean.length - 4);
    return '$prefixDots$lastFour';
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? serialNumber,
    ProductCategory? category,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? currency,
    String? seller,
    String? imagePath,
    String? imageData,
    DateTime? warrantyStartDate,
    DateTime? warrantyEndDate,
    String? warrantyNotes,
    String? invoiceDocumentId,
    String? warrantyDocumentId,
    bool? isFavorite,
    bool? isSample,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currency: currency ?? this.currency,
      seller: seller ?? this.seller,
      imagePath: imagePath ?? this.imagePath,
      imageData: imageData ?? this.imageData,
      warrantyStartDate: warrantyStartDate ?? this.warrantyStartDate,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      warrantyNotes: warrantyNotes ?? this.warrantyNotes,
      invoiceDocumentId: invoiceDocumentId ?? this.invoiceDocumentId,
      warrantyDocumentId: warrantyDocumentId ?? this.warrantyDocumentId,
      isFavorite: isFavorite ?? this.isFavorite,
      isSample: isSample ?? this.isSample,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'category': category.name,
      'purchase_date': purchaseDate.toIso8601String(),
      'purchase_price': purchasePrice,
      'currency': currency,
      'seller': seller,
      'image_path': imagePath,
      'image_data': imageData,
      'warranty_start_date': warrantyStartDate?.toIso8601String(),
      'warranty_end_date': warrantyEndDate?.toIso8601String(),
      'warranty_notes': warrantyNotes,
      'invoice_document_id': invoiceDocumentId,
      'warranty_document_id': warrantyDocumentId,
      'is_favorite': isFavorite ? 1 : 0,
      'is_sample': isSample ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      serialNumber: map['serial_number'] as String?,
      category: ProductCategory.fromString(map['category'] as String?),
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      purchasePrice: map['purchase_price'] != null ? (map['purchase_price'] as num).toDouble() : null,
      currency: (map['currency'] as String?) ?? '\$',
      seller: map['seller'] as String?,
      imagePath: map['image_path'] as String?,
      imageData: map['image_data'] as String?,
      warrantyStartDate: map['warranty_start_date'] != null
          ? DateTime.tryParse(map['warranty_start_date'] as String)
          : null,
      warrantyEndDate: map['warranty_end_date'] != null
          ? DateTime.tryParse(map['warranty_end_date'] as String)
          : null,
      warrantyNotes: map['warranty_notes'] as String?,
      invoiceDocumentId: map['invoice_document_id'] as String?,
      warrantyDocumentId: map['warranty_document_id'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      isSample: (map['is_sample'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }
}
