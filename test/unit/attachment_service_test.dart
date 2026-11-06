import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/core/services/attachment_service.dart';

void main() {
  group('AttachmentService Tests', () {
    test('createAcademicDegreeScan produces valid PDF attachment with decoded JSON payload', () {
      final attachment = AttachmentService.createAcademicDegreeScan(
        recipientName: 'Jane Doe',
        degreeTitle: 'Bachelor of Computer Science',
        university: 'Stanford University',
        graduationDate: '2024-05-15',
      );

      expect(attachment.isPdf, isTrue);
      expect(attachment.isImage, isFalse);
      expect(attachment.fileType, 'pdf');
      expect(attachment.name, contains('Bachelor_of_Computer_Science'));
      expect(attachment.fileSize, greaterThan(0));

      final decoded = jsonDecode(utf8.decode(base64Decode(attachment.base64Data)));
      expect(decoded['type'], 'academic_degree');
      expect(decoded['recipient'], 'Jane Doe');
      expect(decoded['university'], 'Stanford University');
    });

    test('createCertificationCredentialScan produces verified credential payload', () {
      final attachment = AttachmentService.createCertificationCredentialScan(
        certificationName: 'AWS Solutions Architect',
        issuingOrganization: 'Amazon Web Services',
        credentialId: 'AWS-999888',
        issueDate: '2024-01-10',
        expiryDate: '2027-01-10',
      );

      expect(attachment.isPdf, isTrue);
      expect(attachment.mimeType, 'application/pdf');

      final decoded = jsonDecode(utf8.decode(base64Decode(attachment.base64Data)));
      expect(decoded['type'], 'professional_certification');
      expect(decoded['credential_id'], 'AWS-999888');
      expect(decoded['issuer'], 'Amazon Web Services');
    });

    test('createTaxInvoiceScan produces valid invoice structure', () {
      final attachment = AttachmentService.createTaxInvoiceScan(
        vendor: 'Apple Store',
        productName: 'MacBook Pro M3',
        amount: 2499.00,
        currency: '\$',
        invoiceNumber: 'INV-2024-001',
        purchaseDate: '2024-03-01',
      );

      expect(attachment.isPdf, isTrue);
      expect(attachment.name, 'Tax_Invoice_INV-2024-001.pdf');

      final decoded = jsonDecode(utf8.decode(base64Decode(attachment.base64Data)));
      expect(decoded['type'], 'tax_invoice');
      expect(decoded['vendor'], 'Apple Store');
      expect(decoded['amount'], 2499.00);
    });

    test('createGovernmentIdScan generates secure identity scan', () {
      final attachment = AttachmentService.createGovernmentIdScan(
        idType: 'Passport',
        idNumber: 'A12345678',
        fullName: 'Jane Doe',
        country: 'United States',
      );

      expect(attachment.isPdf, isTrue);
      final decoded = jsonDecode(utf8.decode(base64Decode(attachment.base64Data)));
      expect(decoded['type'], 'national_identity');
      expect(decoded['id_number'], 'A12345678');
      expect(decoded['security_code'], contains('USA'));
    });

    test('createCapturedDocumentPhoto creates valid image file', () {
      final attachment = AttachmentService.createCapturedDocumentPhoto(
        title: 'Rental Agreement',
        category: 'Legal',
      );

      expect(attachment.isImage, isTrue);
      expect(attachment.isPdf, isFalse);
      expect(attachment.fileType, 'jpg');
      expect(attachment.mimeType, 'image/jpeg');

      final decoded = jsonDecode(utf8.decode(base64Decode(attachment.base64Data)));
      expect(decoded['type'], 'camera_scan');
      expect(decoded['title'], 'Rental Agreement');
      expect(decoded['category'], 'Legal');
    });

    test('createProductPhoto creates valid product image', () {
      final photo = AttachmentService.createProductPhoto(
        productName: 'Sony WH-1000XM5',
        brand: 'Sony',
      );

      expect(photo.isImage, isTrue);
      expect(photo.fileType, 'jpg');
      expect(photo.name, contains('sony'));

      final decoded = jsonDecode(utf8.decode(base64Decode(photo.base64Data)));
      expect(decoded['type'], 'product_photo');
      expect(decoded['product'], 'Sony WH-1000XM5');
      expect(decoded['brand'], 'Sony');
    });

    test('AttachmentFile serialization to and from Map', () {
      const file = AttachmentFile(
        name: 'test.pdf',
        fileType: 'pdf',
        fileSize: 1024,
        base64Data: 'dGVzdA==',
        mimeType: 'application/pdf',
      );

      final map = file.toMap();
      final roundtrip = AttachmentFile.fromMap(map);

      expect(roundtrip.name, file.name);
      expect(roundtrip.fileType, file.fileType);
      expect(roundtrip.fileSize, file.fileSize);
      expect(roundtrip.base64Data, file.base64Data);
      expect(roundtrip.mimeType, file.mimeType);
      expect(roundtrip.isPdf, isTrue);
    });
  });
}
