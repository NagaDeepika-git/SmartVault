import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/data/models/document_model.dart';
import 'package:smart_vault/features/documents/widgets/document_card.dart';

void main() {
  testWidgets('DocumentCard renders title, category, and responds to tap', (tester) async {
    bool tapped = false;
    bool favoriteToggled = false;

    final doc = DocumentModel(
      id: 'doc-1',
      title: 'Stanford University Diploma',
      description: 'Official degree credential',
      category: DocumentCategory.academic,
      issueDate: DateTime(2025, 6, 1),
      isFavorite: true,
      fileType: 'pdf',
      fileSize: 1048576,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentCard(
            document: doc,
            onTap: () => tapped = true,
            onToggleFavorite: () => favoriteToggled = true,
          ),
        ),
      ),
    );

    expect(find.text('Stanford University Diploma'), findsOneWidget);
    expect(find.textContaining('Academic'), findsWidgets);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byType(DocumentCard));
    expect(tapped, true);

    await tester.tap(find.byIcon(Icons.favorite_rounded));
    expect(favoriteToggled, true);
  });
}
