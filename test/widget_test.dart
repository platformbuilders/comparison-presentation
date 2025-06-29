import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:comparison_calculator/main_demo.dart';

void main() {
  testWidgets('Calculator app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ComparisonCalculatorDemo());

    // Verify that the app loads
    expect(find.text('Calculadora Compra × Locação (Demo)'), findsOneWidget);
  });
}