import 'package:flutter_test/flutter_test.dart';

import 'package:ai_trader/main.dart';

void main() {
  testWidgets('renders trading dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const AiTraderApp());
    expect(find.text('BTC/USDT'), findsOneWidget);
  });
}
