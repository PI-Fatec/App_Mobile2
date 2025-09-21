import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager/main.dart';

void main() {
  testWidgets('App should launch without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExpenseManagerApp());

    // Verify that the app launches with the correct title
    expect(find.text('Gerenciador de Despesas'), findsOneWidget);
  });
}
