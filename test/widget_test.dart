import 'package:flutter_test/flutter_test.dart';

import 'package:my_day/app/app.dart';
import 'package:my_day/core/constants/app_constants.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyDayApp());

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    // Let the splash screen's navigation timer finish so it doesn't leak
    // into the next test.
    await tester.pump(const Duration(seconds: 3));
  });
}
