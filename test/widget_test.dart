import 'package:flutter_test/flutter_test.dart';

import 'package:birr_gebeya/main.dart';

void main() {
  testWidgets('Splash screen shows entry actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ብር Gebeya'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}
