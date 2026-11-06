import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/app/navigation/navigation_shell.dart';

void main() {
  testWidgets('NavigationShell renders bottom navigation and switches pages on mobile', (tester) async {
    // Set mobile screen size
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: NavigationShell(
          pages: [
            Center(child: Text('Home Screen Content')),
            Center(child: Text('Vault Screen Content')),
            Center(child: Text('Products Screen Content')),
            Center(child: Text('Insights Screen Content')),
          ],
        ),
      ),
    );

    expect(find.text('Home Screen Content'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Vault tab
    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Vault Screen Content'), findsOneWidget);

    // Tap Products tab
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();

    expect(find.text('Products Screen Content'), findsOneWidget);
  });
}
