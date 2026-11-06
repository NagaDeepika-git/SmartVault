import 'package:uuid/uuid.dart';

/// Document categories matching SmartVault requirements.
enum DocumentCategory {
  identity('Identity', 'ID & Passports'),
  academic('Academic', 'Certificates & Degrees'),
  employment('Employment', 'Contracts & Resumes'),
  financial('Financial', 'Tax & Bank Records'),
  medical('Medical', 'Health & Prescriptions'),
  receipts('Receipts & Invoices', 'Purchase Proofs'),
  warranty('Product Warranties', 'Warranty Cards'),
  other('Other', 'Miscellaneous');

  final String label;
  final String subtitle;
  const DocumentCategory(this.label, this.subtitle);

  static DocumentCategory fromString(String? value) {
    if (value == null) return DocumentCategory.other;
    return DocumentCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => DocumentCategory.other,
    );
  }
}

/// Core Document model representing personal and academic records in SmartVault.
class DocumentModel {
  final String id;
  final String title;
  final String? description;
  final DocumentCategory category;
  final String? issuer;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? filePath;
  final String? fileType;
  final int? fileSize;
  final String? fileData; // Persistent Base64 file content or SVG/data representation
  final List<String> tags;
  final String? notes;
  final String? productId; // Connected module link: binds document to an asset/product
  final bool isFavorite;
  final bool isSample;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    String? id,
    required this.title,
    this.description,
    required this.category,
    this.issuer,
    this.issueDate,
    this.expiryDate,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.fileData,
    List<String>? tags,
    this.notes,
    this.productId,
    this.isFavorite = false,
    this.isSample = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? const [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasAttachment =>
      (filePath != null && filePath!.isNotEmpty) ||
      (fileData != null && fileData!.isNotEmpty);

  bool get hasFileData => fileData != null && fileData!.isNotEmpty;

  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return expiryDate!.isBefore(today);
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return target.difference(today).inDays;
  }

  String get formattedFileSize {
    if (fileSize == null || fileSize! <= 0) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? description,
    DocumentCategory? category,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? filePath,
    String? fileType,
    int? fileSize,
    String? fileData,
    List<String>? tags,
    String? notes,
    String? productId,
    bool? isFavorite,
    bool? isSample,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      fileData: fileData ?? this.fileData,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      productId: productId ?? this.productId,
      isFavorite: isFavorite ?? this.isFavorite,
      isSample: isSample ?? this.isSample,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'issuer': issuer,
      'issue_date': issueDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'file_data': fileData,
      'tags': tags.join(','),
      'notes': notes,
      'product_id': productId,
      'is_favorite': isFavorite ? 1 : 0,
      'is_sample': isSample ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: DocumentCategory.fromString(map['category'] as String?),
      issuer: map['issuer'] as String?,
      issueDate: map['issue_date'] != null ? DateTime.tryParse(map['issue_date'] as String) : null,
      expiryDate: map['expiry_date'] != null ? DateTime.tryParse(map['expiry_date'] as String) : null,
      filePath: map['file_path'] as String?,
      fileType: map['file_type'] as String?,
      fileSize: map['file_size'] as int?,
      fileData: map['file_data'] as String?,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
      notes: map['notes'] as String?,
      productId: map['product_id'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      isSample: (map['is_sample'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }
}
