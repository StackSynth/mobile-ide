import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('App loads and renders main interface smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MobileCloudIdeApp()));
    await tester.pumpAndSettle();

    expect(find.text('StackSynth'), findsWidgets);
  });
}
