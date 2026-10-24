import '../datasources/local_database_service.dart';
import '../models/document_model.dart';
import '../models/product_model.dart';
import '../models/service_record_model.dart';
import '../models/reminder_model.dart';

/// Seeds realistic initial sample data into SmartVault on first launch.
/// Fulfills portfolio requirements: connected records, active and expiring warranties,
/// academic certificates, and linked purchase invoices.
class SampleDataLoader {
  SampleDataLoader._();

  static const String sampleProductIdMacBook = 'prod-macbook-pro-m3';
  static const String sampleProductIdPixel = 'prod-pixel-9-pro';
  static const String sampleProductIdSony = 'prod-sony-wh1000xm4';
  static const String sampleProductIdDyson = 'prod-dyson-purifier';

  static const String sampleDocIdDegree = 'doc-degree-cs';
  static const String sampleDocIdAws = 'doc-cert-aws';
  static const String sampleDocIdMacInvoice = 'doc-invoice-macbook';
  static const String sampleDocIdPassport = 'doc-id-passport';

  static List<ProductModel> getProducts(DateTime now) {
    return [
      ProductModel(
        id: sampleProductIdMacBook,
        name: 'MacBook Pro 16" M3 Max',
        brand: 'Apple',
        model: 'A2991 Space Black',
        serialNumber: 'C02G8792MD6R',
        category: ProductCategory.laptops,
        purchaseDate: now.subtract(const Duration(days: 120)),
        purchasePrice: 3499.00,
        currency: '\$',
        seller: 'Apple Official Store',
        warrantyStartDate: now.subtract(const Duration(days: 120)),
        warrantyEndDate: now.add(const Duration(days: 610)), // Active (2 years AppleCare+)
        warrantyNotes: 'AppleCare+ Extended Protection with global hardware coverage.',
        invoiceDocumentId: sampleDocIdMacInvoice,
        isFavorite: true,
        isSample: true,
      ),
      ProductModel(
        id: sampleProductIdPixel,
        name: 'Google Pixel 9 Pro',
        brand: 'Google',
        model: 'Obsidian 256GB',
        serialNumber: '358941092481023',
        category: ProductCategory.smartphones,
        purchaseDate: now.subtract(const Duration(days: 347)),
        purchasePrice: 999.00,
        currency: '\$',
        seller: 'Google Store Online',
        warrantyStartDate: now.subtract(const Duration(days: 347)),
        warrantyEndDate: now.add(const Duration(days: 18)), // Expiring Soon (18 days left!)
        warrantyNotes: '1-Year Limited Manufacturer Warranty. Contact Google support for claims.',
        isFavorite: true,
        isSample: true,
      ),
      ProductModel(
        id: sampleProductIdSony,
        name: 'WH-1000XM4 Wireless Headphones',
        brand: 'Sony',
        model: 'WH-1000XM4 Black',
        serialNumber: 'S01-9482103-E',
        category: ProductCategory.electronics,
        purchaseDate: now.subtract(const Duration(days: 410)),
        purchasePrice: 348.00,
        currency: '\$',
        seller: 'Best Buy Electronics',
        warrantyStartDate: now.subtract(const Duration(days: 410)),
        warrantyEndDate: now.subtract(const Duration(days: 45)), // Expired 45 days ago
        warrantyNotes: 'Standard 1-year Sony North America warranty expired.',
        isFavorite: false,
        isSample: true,
      ),
      ProductModel(
        id: sampleProductIdDyson,
        name: 'Dyson Purifier Hot+Cool HP07',
        brand: 'Dyson',
        model: 'HP07 White/Silver',
        serialNumber: 'NN4-US-MCA2091',
        category: ProductCategory.appliances,
        purchaseDate: now.subtract(const Duration(days: 200)),
        purchasePrice: 649.99,
        currency: '\$',
        seller: 'Dyson Direct',
        warrantyStartDate: now.subtract(const Duration(days: 200)),
        warrantyEndDate: now.add(const Duration(days: 530)), // Active 2-Year Warranty
        warrantyNotes: 'Full 2-year parts and labor warranty with Dyson in-home support.',
        isFavorite: false,
        isSample: true,
      ),
    ];
  }

  static List<DocumentModel> getDocuments(DateTime now) {
    return [
      DocumentModel(
        id: sampleDocIdDegree,
        title: 'B.Tech in Computer Science Degree',
        description: 'Original University Bachelor Degree Certificate with First Class Honors.',
        category: DocumentCategory.academic,
        issuer: 'Institute of Technology',
        issueDate: DateTime(2024, 6, 15),
        expiryDate: null,
        fileType: 'pdf',
        fileSize: 2450000,
        tags: ['degree', 'graduation', 'academic', 'engineering'],
        notes: 'Official verified digital copy with digital signature.',
        isFavorite: true,
        isSample: true,
      ),
      DocumentModel(
        id: sampleDocIdAws,
        title: 'AWS Certified Solutions Architect',
        description: 'Professional Cloud Architecture Certification credential.',
        category: DocumentCategory.academic,
        issuer: 'Amazon Web Services',
        issueDate: now.subtract(const Duration(days: 180)),
        expiryDate: now.add(const Duration(days: 550)),
        fileType: 'pdf',
        fileSize: 1120000,
        tags: ['aws', 'cloud', 'certification', 'credentials'],
        notes: 'Verification ID: AWS-PSA-8392019.',
        isFavorite: true,
        isSample: true,
      ),
      DocumentModel(
        id: sampleDocIdMacInvoice,
        title: 'MacBook Pro Purchase Tax Invoice',
        description: 'Authorized Apple Store retail receipt and GST tax invoice.',
        category: DocumentCategory.receipts,
        issuer: 'Apple Retail Store',
        issueDate: now.subtract(const Duration(days: 120)),
        expiryDate: null,
        fileType: 'pdf',
        fileSize: 840000,
        tags: ['apple', 'invoice', 'receipt', 'tax'],
        notes: 'Includes proof of serial number registration.',
        productId: sampleProductIdMacBook, // Connected link to MacBook Pro!
        isFavorite: true,
        isSample: true,
      ),
      DocumentModel(
        id: sampleDocIdPassport,
        title: 'International Travel Passport',
        description: 'Official Government Issued Identity & Travel Document.',
        category: DocumentCategory.identity,
        issuer: 'Department of Foreign Affairs',
        issueDate: DateTime(2021, 4, 10),
        expiryDate: DateTime(2031, 4, 10),
        fileType: 'jpg',
        fileSize: 1850000,
        tags: ['passport', 'identity', 'travel', 'government'],
        notes: 'Keep physical book safe in safety deposit.',
        isFavorite: false,
        isSample: true,
      ),
      DocumentModel(
        id: 'doc-medical-insurance',
        title: 'Health & Medical Insurance Policy',
        description: 'Comprehensive annual medical hospitalization coverage.',
        category: DocumentCategory.medical,
        issuer: 'BlueShield Health',
        issueDate: now.subtract(const Duration(days: 300)),
        expiryDate: now.add(const Duration(days: 65)),
        fileType: 'pdf',
        fileSize: 3200000,
        tags: ['medical', 'health', 'insurance', 'policy'],
        notes: 'Policy No: BLU-9204-8291. TPA Card attached.',
        isFavorite: false,
        isSample: true,
      ),
    ];
  }

  static List<ServiceRecordModel> getServiceRecords(DateTime now) {
    return [
      ServiceRecordModel(
        id: 'svc-macbook-maintenance',
        productId: sampleProductIdMacBook,
        serviceDate: now.subtract(const Duration(days: 40)),
        serviceProvider: 'Apple Genius Bar',
        issueDescription: 'Keypad key cap replacement and internal thermal cooling fan cleaning.',
        cost: 0.00, // Covered under AppleCare+
        resolution: 'Replaced spacebar mechanism and performed full hardware diagnostics. Passed.',
        nextMaintenanceDate: now.add(const Duration(days: 140)),
        isSample: true,
      ),
      ServiceRecordModel(
        id: 'svc-pixel-screen-guard',
        productId: sampleProductIdPixel,
        serviceDate: now.subtract(const Duration(days: 90)),
        serviceProvider: 'Authorized Google Mobile Care',
        issueDescription: 'UV Tempered Glass installation and USB-C port lint extraction.',
        cost: 35.00,
        resolution: 'Tempered glass aligned and port cleaned. Fast charging verified.',
        nextMaintenanceDate: now.add(const Duration(days: 90)),
        isSample: true,
      ),
      ServiceRecordModel(
        id: 'svc-dyson-filter-change',
        productId: sampleProductIdDyson,
        serviceDate: now.subtract(const Duration(days: 15)),
        serviceProvider: 'Self Maintenance (OEM Dyson Parts)',
        issueDescription: 'Annual HEPA H13 and Activated Carbon filter replacement.',
        cost: 79.99,
        resolution: 'Fitted genuine Dyson dual filter pack. Reset filter life counter to 100%.',
        nextMaintenanceDate: now.add(const Duration(days: 350)),
        isSample: true,
      ),
    ];
  }

  static List<ReminderModel> getReminders(DateTime now) {
    return [
      ReminderModel(
        id: 'rem-pixel-warranty',
        title: 'Google Pixel 9 Pro Warranty Expiration',
        description: 'Manufacturer warranty expires in 18 days! Inspect screen and battery health.',
        type: ReminderType.warrantyExpiry,
        targetDate: now.add(const Duration(days: 18)),
        relatedId: sampleProductIdPixel,
        relatedType: 'product',
        isCompleted: false,
      ),
      ReminderModel(
        id: 'rem-medical-policy',
        title: 'Health Insurance Annual Renewal',
        description: 'Policy expires in 65 days. Review premium and no-claim bonus.',
        type: ReminderType.documentExpiry,
        targetDate: now.add(const Duration(days: 65)),
        relatedId: 'doc-medical-insurance',
        relatedType: 'document',
        isCompleted: false,
      ),
      ReminderModel(
        id: 'rem-mac-maintenance',
        title: 'MacBook Pro Scheduled Diagnostic Check',
        description: 'Semi-annual thermal cleaning and battery cycle checkup.',
        type: ReminderType.maintenance,
        targetDate: now.add(const Duration(days: 140)),
        relatedId: sampleProductIdMacBook,
        relatedType: 'product',
        isCompleted: false,
      ),
    ];
  }

  /// Seeds all initial sample data if storage is empty.
  static Future<void> seedIfEmpty(LocalDatabaseService dbService) async {
    final alreadySeeded = await dbService.isSeeded();
    final hasDocs = await dbService.hasData(LocalDatabaseService.tableDocuments);

    if (!alreadySeeded && !hasDocs) {
      await seedSampleData(dbService);
    }
  }

  /// Forces insertion of curated sample dataset.
  static Future<void> seedSampleData(LocalDatabaseService dbService) async {
    final now = DateTime.now();

    for (final product in getProducts(now)) {
      await dbService.insert(
        LocalDatabaseService.tableProducts,
        product.toMap(),
      );
    }

    for (final doc in getDocuments(now)) {
      await dbService.insert(
        LocalDatabaseService.tableDocuments,
        doc.toMap(),
      );
    }

    for (final service in getServiceRecords(now)) {
      await dbService.insert(
        LocalDatabaseService.tableServiceRecords,
        service.toMap(),
      );
    }

    for (final reminder in getReminders(now)) {
      await dbService.insert(
        LocalDatabaseService.tableReminders,
        reminder.toMap(),
      );
    }

    await dbService.setSeeded(true);
  }
}
