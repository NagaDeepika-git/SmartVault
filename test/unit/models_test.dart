import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/data/models/document_model.dart';
import 'package:smart_vault/data/models/product_model.dart';
import 'package:smart_vault/data/models/reminder_model.dart';
import 'package:smart_vault/data/models/service_record_model.dart';

void main() {
  group('Domain Models Serialization Roundtrip Tests', () {
    test('DocumentModel serializes and deserializes cleanly', () {
      final doc = DocumentModel(
        id: 'doc-test-1',
        title: 'B.Tech Degree Certificate',
        description: 'Computer Science and Engineering official degree parchment',
        category: DocumentCategory.academic,
        tags: ['degree', 'engineering', 'university'],
        issueDate: DateTime(2025, 5, 20),
        expiryDate: null,
        filePath: '/storage/emulated/0/SmartVault/degree.pdf',
        fileType: 'pdf',
        fileSize: 2048500,
        fileData: 'JVBERi0xLjQKJcTl8uXrp/Og0MTGCjQgMCBvYmoKPDwKL1R5cGUgL1BhZ2VzCi9Db3VudCAxCj4+CmVuZG9iag==',
        isFavorite: true,
        isSample: false,
      );

      final map = doc.toMap();
      final restored = DocumentModel.fromMap(map);

      expect(restored.id, doc.id);
      expect(restored.title, doc.title);
      expect(restored.description, doc.description);
      expect(restored.category, doc.category);
      expect(restored.tags, doc.tags);
      expect(restored.fileType, 'pdf');
      expect(restored.fileData, doc.fileData);
      expect(restored.hasFileData, true);
      expect(restored.hasAttachment, true);
      expect(restored.isFavorite, true);
      expect(restored.isSample, false);
    });

    test('ProductModel serializes and deserializes cleanly', () {
      final product = ProductModel(
        id: 'prod-test-1',
        name: 'MacBook Pro 16" M3 Max',
        brand: 'Apple',
        model: 'A2991 Space Black',
        serialNumber: 'C02G8792MD6R',
        category: ProductCategory.laptops,
        purchaseDate: DateTime(2024, 6, 1),
        purchasePrice: 3499.00,
        currency: '\$',
        seller: 'Apple Official Store',
        warrantyStartDate: DateTime(2024, 6, 1),
        warrantyEndDate: DateTime(2027, 6, 1),
        warrantyNotes: 'AppleCare+ 3 Year Coverage',
        imageData: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        isFavorite: true,
        isSample: false,
      );

      final map = product.toMap();
      final restored = ProductModel.fromMap(map);

      expect(restored.id, product.id);
      expect(restored.name, product.name);
      expect(restored.brand, 'Apple');
      expect(restored.serialNumber, 'C02G8792MD6R');
      expect(restored.purchasePrice, 3499.00);
      expect(restored.category, ProductCategory.laptops);
      expect(restored.hasWarranty, true);
      expect(restored.imageData, product.imageData);
      expect(restored.hasImage, true);
    });

    test('ServiceRecordModel serializes and deserializes cleanly', () {
      final service = ServiceRecordModel(
        id: 'serv-test-1',
        productId: 'prod-test-1',
        serviceDate: DateTime(2025, 3, 10),
        serviceProvider: 'Apple Authorized Service Center',
        issueDescription: 'Keypad stuck on spacebar',
        cost: 0.0,
        resolution: 'Replaced top-case keyboard under AppleCare+ warranty',
        isSample: false,
      );

      final map = service.toMap();
      final restored = ServiceRecordModel.fromMap(map);

      expect(restored.id, service.id);
      expect(restored.productId, 'prod-test-1');
      expect(restored.serviceProvider, 'Apple Authorized Service Center');
      expect(restored.cost, 0.0);
    });

    test('ReminderModel serializes and deserializes cleanly', () {
      final reminder = ReminderModel(
        id: 'rem-test-1',
        title: 'Renew Passport',
        description: 'Schedule passport renewal appointment 6 months before expiry',
        type: ReminderType.documentExpiry,
        targetDate: DateTime(2026, 11, 15),
        isCompleted: false,
      );

      final map = reminder.toMap();
      final restored = ReminderModel.fromMap(map);

      expect(restored.id, reminder.id);
      expect(restored.title, reminder.title);
      expect(restored.type, ReminderType.documentExpiry);
      expect(restored.isCompleted, false);
    });
  });
}
