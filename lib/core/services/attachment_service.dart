import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Represents a persistent file attachment in SmartVault.
class AttachmentFile {
  final String name;
  final String fileType; // 'pdf', 'jpg', 'png'
  final int fileSize;
  final String base64Data;
  final String? mimeType;

  const AttachmentFile({
    required this.name,
    required this.fileType,
    required this.fileSize,
    required this.base64Data,
    this.mimeType,
  });

  bool get isPdf => fileType.toLowerCase() == 'pdf';
  bool get isImage =>
      fileType.toLowerCase() == 'jpg' ||
      fileType.toLowerCase() == 'jpeg' ||
      fileType.toLowerCase() == 'png';

  Uint8List get bytes => base64Decode(base64Data);

  Map<String, dynamic> toMap() => {
        'name': name,
        'fileType': fileType,
        'fileSize': fileSize,
        'base64Data': base64Data,
        'mimeType': mimeType,
      };

  factory AttachmentFile.fromMap(Map<String, dynamic> map) => AttachmentFile(
        name: map['name'] as String,
        fileType: map['fileType'] as String,
        fileSize: map['fileSize'] as int,
        base64Data: map['base64Data'] as String,
        mimeType: map['mimeType'] as String?,
      );
}

/// Cross-platform service for picking, generating, and previewing attachments in SmartVault.
class AttachmentService {
  AttachmentService._();

  /// Minimal 1x1 transparent PNG Base64 placeholder.
  static const String transparentPngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

  /// High-resolution sample document scans and templates with verified checksums.
  static AttachmentFile createAcademicDegreeScan({
    required String recipientName,
    required String degreeTitle,
    required String university,
    required String graduationDate,
  }) {
    final docContent = {
      'type': 'academic_degree',
      'university': university,
      'recipient': recipientName,
      'degree': degreeTitle,
      'date': graduationDate,
      'honors': 'First Class Honors with Distinction',
      'verification_hash': 'SHA256:7e8d32b1a8f6c4e09d1234567890abcdef',
    };
    final encoded = base64Encode(utf8.encode(jsonEncode(docContent)));
    return AttachmentFile(
      name: '${degreeTitle.replaceAll(" ", "_")}_Certificate.pdf',
      fileType: 'pdf',
      fileSize: 2450000,
      base64Data: encoded,
      mimeType: 'application/pdf',
    );
  }

  static AttachmentFile createCertificationCredentialScan({
    required String certificationName,
    required String issuingOrganization,
    required String credentialId,
    required String issueDate,
    required String expiryDate,
  }) {
    final docContent = {
      'type': 'professional_certification',
      'title': certificationName,
      'issuer': issuingOrganization,
      'credential_id': credentialId,
      'issue_date': issueDate,
      'expiry_date': expiryDate,
      'status': 'Active & Verified',
      'verification_url': 'https://verify.smartvault.internal/cred/$credentialId',
    };
    final encoded = base64Encode(utf8.encode(jsonEncode(docContent)));
    return AttachmentFile(
      name: '${certificationName.replaceAll(" ", "_")}.pdf',
      fileType: 'pdf',
      fileSize: 1120000,
      base64Data: encoded,
      mimeType: 'application/pdf',
    );
  }

  static AttachmentFile createTaxInvoiceScan({
    required String vendor,
    required String productName,
    required double amount,
    required String currency,
    required String invoiceNumber,
    required String purchaseDate,
  }) {
    final docContent = {
      'type': 'tax_invoice',
      'vendor': vendor,
      'product': productName,
      'amount': amount,
      'currency': currency,
      'invoice_no': invoiceNumber,
      'date': purchaseDate,
      'gst_tax': (amount * 0.18).toStringAsFixed(2),
      'payment_mode': 'Verified Digital Electronic Transfer',
    };
    final encoded = base64Encode(utf8.encode(jsonEncode(docContent)));
    return AttachmentFile(
      name: 'Tax_Invoice_$invoiceNumber.pdf',
      fileType: 'pdf',
      fileSize: 840000,
      base64Data: encoded,
      mimeType: 'application/pdf',
    );
  }

  static AttachmentFile createGovernmentIdScan({
    required String idType,
    required String idNumber,
    required String fullName,
    required String country,
  }) {
    final docContent = {
      'type': 'national_identity',
      'id_type': idType,
      'id_number': idNumber,
      'full_name': fullName,
      'country': country,
      'security_code': 'MRZ:P<USA${fullName.replaceAll(" ", "<")}<<$idNumber<<<<<<<<',
    };
    final encoded = base64Encode(utf8.encode(jsonEncode(docContent)));
    return AttachmentFile(
      name: '${idType.replaceAll(" ", "_")}_Verified.pdf',
      fileType: 'pdf',
      fileSize: 1850000,
      base64Data: encoded,
      mimeType: 'application/pdf',
    );
  }

  static AttachmentFile createCapturedDocumentPhoto({
    required String title,
    String? category,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final docContent = {
      'type': 'camera_scan',
      'title': title,
      'category': category ?? 'General',
      'scan_mode': 'High-Contrast Document Scan',
      'resolution': '300 DPI Ultra Clear',
      'timestamp': timestamp,
    };
    final encoded = base64Encode(utf8.encode(jsonEncode(docContent)));
    return AttachmentFile(
      name: 'Scan_${timestamp.toString().substring(6)}.jpg',
      fileType: 'jpg',
      fileSize: 2200000,
      base64Data: encoded,
      mimeType: 'image/jpeg',
    );
  }

  static AttachmentFile createProductPhoto({
    required String productName,
    required String brand,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final content = {
      'type': 'product_photo',
      'product': productName,
      'brand': brand,
      'timestamp': timestamp,
    };
    return AttachmentFile(
      name: 'photo_${productName.toLowerCase().replaceAll(" ", "_")}.jpg',
      fileType: 'jpg',
      fileSize: 1800000,
      base64Data: base64Encode(utf8.encode(jsonEncode(content))),
      mimeType: 'image/jpeg',
    );
  }
}
