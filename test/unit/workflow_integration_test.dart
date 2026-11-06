import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_vault/core/services/attachment_service.dart';
import 'package:smart_vault/data/datasources/local_database_service.dart';
import 'package:smart_vault/data/models/document_model.dart';
import 'package:smart_vault/data/models/product_model.dart';
import 'package:smart_vault/data/models/reminder_model.dart';
import 'package:smart_vault/data/models/service_record_model.dart';
import 'package:smart_vault/data/repositories/document_repository.dart';
import 'package:smart_vault/data/repositories/product_repository.dart';
import 'package:smart_vault/data/repositories/reminder_repository.dart';
import 'package:smart_vault/data/repositories/service_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabaseService dbService;
  late DocumentRepository docRepo;
  late ProductRepository prodRepo;
  late ServiceRepository servRepo;
  late ReminderRepository reminderRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dbService = LocalDatabaseService.instance;
    await dbService.init();

    docRepo = LocalDocumentRepository(dbService: dbService);
    prodRepo = LocalProductRepository(dbService: dbService);
    servRepo = LocalServiceRepository(dbService: dbService);
    reminderRepo = LocalReminderRepository(dbService: dbService);
  });

  group('SmartVault End-to-End Persistence and Workflow Tests', () {
    test('Document CRUD with persistent AttachmentFile lifecycle', () async {
      final scan = AttachmentService.createAcademicDegreeScan(
        recipientName: 'Integration Tester',
        degreeTitle: 'Bachelor of Software Engineering',
        university: 'Carnegie Mellon',
        graduationDate: '2024-05-20',
      );

      final doc = DocumentModel(
        id: 'doc-persist-1',
        title: 'CMU Degree',
        category: DocumentCategory.academic,
        filePath: scan.name,
        fileData: scan.base64Data,
        fileType: scan.fileType,
        fileSize: scan.fileSize,
        issueDate: DateTime(2024, 5, 20),
      );

      // Create
      await docRepo.createDocument(doc);
      final loaded = await docRepo.getAllDocuments();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'CMU Degree');
      expect(loaded.first.hasFileData, isTrue);
      expect(loaded.first.fileData, scan.base64Data);

      // Update
      final updated = doc.copyWith(title: 'CMU Degree (Verified)');
      await docRepo.updateDocument(updated);
      final reloaded = await docRepo.getDocumentById('doc-persist-1');
      expect(reloaded?.title, 'CMU Degree (Verified)');

      // Delete
      await docRepo.deleteDocument('doc-persist-1');
      final afterDelete = await docRepo.getAllDocuments();
      expect(afterDelete.isEmpty, isTrue);
    });

    test('Product CRUD with photo and linked invoice lifecycle', () async {
      final photo = AttachmentService.createProductPhoto(
        productName: 'iPad Pro M4',
        brand: 'Apple',
      );

      final product = ProductModel(
        id: 'prod-persist-1',
        name: 'iPad Pro M4',
        brand: 'Apple',
        category: ProductCategory.smartphones,
        purchaseDate: DateTime(2024, 4, 1),
        purchasePrice: 1199.00,
        currency: '\$',
        imagePath: photo.name,
        imageData: photo.base64Data,
        warrantyStartDate: DateTime(2024, 4, 1),
        warrantyEndDate: DateTime.now().add(const Duration(days: 365)),
      );

      await prodRepo.createProduct(product);
      final products = await prodRepo.getAllProducts();
      expect(products.length, 1);
      expect(products.first.hasImage, isTrue);
      expect(products.first.imageData, photo.base64Data);

      // Check warranty status calculation
      final warranty = products.first.warrantyResult;
      expect(warranty.isActive, isTrue);

      await prodRepo.deleteProduct('prod-persist-1');
      final emptyProducts = await prodRepo.getAllProducts();
      expect(emptyProducts.isEmpty, isTrue);
    });

    test('Service record and Reminder creation workflow', () async {
      final service = ServiceRecordModel(
        id: 'serv-1',
        productId: 'prod-persist-1',
        serviceDate: DateTime(2024, 7, 1),
        serviceProvider: 'Apple Genius Bar',
        cost: 99.00,
        issueDescription: 'Battery health degraded',
        resolution: 'Replaced official battery unit',
      );

      await servRepo.createServiceRecord(service);
      final services = await servRepo.getServiceRecordsByProductId('prod-persist-1');
      expect(services.length, 1);
      expect(services.first.cost, 99.00);

      final reminder = ReminderModel(
        id: 'rem-1',
        title: 'Renew AppleCare',
        targetDate: DateTime.now().add(const Duration(days: 15)),
        type: ReminderType.warrantyExpiry,
        relatedId: 'prod-persist-1',
        relatedType: 'product',
      );

      await reminderRepo.createReminder(reminder);
      final reminders = await reminderRepo.getAllReminders();
      expect(reminders.length, 1);
      expect(reminders.first.title, 'Renew AppleCare');
      expect(reminders.first.isCompleted, isFalse);
    });
  });
}
