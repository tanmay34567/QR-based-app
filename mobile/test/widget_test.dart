import 'package:flutter_test/flutter_test.dart';
import 'package:qr_dialer/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QrDialerApp());
    expect(find.byType(QrDialerApp), findsOneWidget);
  });
}
