import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/data/models/product_model.dart';
import 'package:smart_vault/features/products/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard displays name, brand, formatted price, and triggers callbacks',
      (WidgetTester tester) async {
    bool tapped = false;
    bool favoriteToggled = false;

    final product = ProductModel(
      id: 'prod-001',
      name: 'MacBook Pro 16"',
      brand: 'Apple',
      model: 'M3 Max',
      category: ProductCategory.laptops,
      purchaseDate: DateTime(2024, 1, 15),
      purchasePrice: 3499.00,
      currency: '\$',
      isFavorite: false,
      imageData: 'mock_base64_data',
      imagePath: 'photo_macbook.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            onTap: () => tapped = true,
            onToggleFavorite: () => favoriteToggled = true,
          ),
        ),
      ),
    );

    expect(find.text('MacBook Pro 16"'), findsOneWidget);
    expect(find.text('Apple • M3 Max'), findsOneWidget);
    expect(find.text('\$3,499.00'), findsOneWidget);

    // Tap card
    await tester.tap(find.text('MacBook Pro 16"'));
    await tester.pump();
    expect(tapped, isTrue);

    // Tap favorite icon
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(favoriteToggled, isTrue);
  });
}
