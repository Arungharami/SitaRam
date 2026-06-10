import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sitaram/main.dart';

void main() {
  testWidgets('SitaRam app builds and loads Home screen smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SitaRamApp(),
      ),
    );

    // Verify that the title "SITARAM" is displayed
    expect(find.text('SITARAM'), findsOneWidget);
  });
}
