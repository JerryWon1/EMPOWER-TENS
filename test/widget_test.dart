import 'package:flutter_test/flutter_test.dart';
import 'package:empower_tens/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TensApp());
    expect(find.text('TENS Device Controller'), findsOneWidget);
    expect(find.text('Power Level'), findsOneWidget);
    expect(find.text('Start Timer'), findsOneWidget);
  });
}
