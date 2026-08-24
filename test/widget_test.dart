// Basic smoke test for HabitFlow app.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/app.dart';

void main() {
  testWidgets('App builds and renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HabitFlowApp(),
      ),
    );

    // Verify the app renders the home screen title
    expect(find.text('Today'), findsOneWidget);
  });
}
