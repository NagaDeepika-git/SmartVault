import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/core/widgets/metric_card.dart';

void main() {
  testWidgets('MetricCard displays title, value, and responds to click', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: 'Active Warranties',
            value: 4,
            icon: Icons.verified_user_rounded,
            accentColor: Colors.amber,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Allow AnimatedCounter TweenAnimationBuilder to tick
    await tester.pumpAndSettle();

    expect(find.text('Active Warranties'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);

    await tester.tap(find.byType(MetricCard));
    expect(tapped, true);
  });
}
