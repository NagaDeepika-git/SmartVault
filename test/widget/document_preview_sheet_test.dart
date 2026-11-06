import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/core/services/attachment_service.dart';
import 'package:smart_vault/data/models/document_model.dart';
import 'package:smart_vault/features/documents/widgets/document_preview_sheet.dart';

void main() {
  testWidgets('DocumentPreviewSheet displays certificate document preview with zoom and close button',
      (WidgetTester tester) async {
    final scan = AttachmentService.createAcademicDegreeScan(
      recipientName: 'Jane Smith',
      degreeTitle: 'Master of Science in Artificial Intelligence',
      university: 'MIT',
      graduationDate: '2024-06-12',
    );

    final document = DocumentModel(
      id: 'doc-test-1',
      title: 'MIT Degree Certificate',
      category: DocumentCategory.academic,
      filePath: scan.name,
      fileData: scan.base64Data,
      fileType: scan.fileType,
      fileSize: scan.fileSize,
      issueDate: DateTime(2024, 6, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentPreviewSheet(document: document),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('MIT Degree Certificate'), findsOneWidget);
    expect(find.text('Master of Science in Artificial Intelligence'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('MIT'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('DocumentPreviewSheet displays invoice document preview correctly',
      (WidgetTester tester) async {
    final invoiceScan = AttachmentService.createTaxInvoiceScan(
      vendor: 'Dell Technologies',
      productName: 'Dell XPS 15',
      amount: 1999.00,
      currency: '\$',
      invoiceNumber: 'INV-DELL-900',
      purchaseDate: '2024-02-20',
    );

    final document = DocumentModel(
      id: 'doc-test-2',
      title: 'Dell Purchase Invoice',
      category: DocumentCategory.receipts,
      filePath: invoiceScan.name,
      fileData: invoiceScan.base64Data,
      fileType: invoiceScan.fileType,
      fileSize: invoiceScan.fileSize,
      issueDate: DateTime(2024, 2, 20),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentPreviewSheet(document: document),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dell Purchase Invoice'), findsOneWidget);
    expect(find.text('DELL TECHNOLOGIES'), findsOneWidget);
    expect(find.text('TAX INVOICE'), findsOneWidget);
  });
}
