import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_vault/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
    });
  });

  testWidgets('SmartVault smoke test builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartVaultRoot());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SmartVaultApp), findsOneWidget);
  });
}
