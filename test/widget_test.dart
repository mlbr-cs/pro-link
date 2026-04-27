import 'package:flutter_test/flutter_test.dart';
import 'package:pro_link/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProLinkApp());

    expect(find.text('Welcome to Pro-Link'), findsOneWidget);
  });
}
