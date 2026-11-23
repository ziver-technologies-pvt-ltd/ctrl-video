import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ctrl_video/main.dart';
import 'package:ctrl_video/services/engine_manager.dart';

// Test fake engine manager that immediately reports ready
class FakeEngineManager extends EngineManager {
  @override
  Future<bool> ensureEngineReady() async => true;

  @override
  String? get ytDlpVersion => '2026.01.01-test';
}

void main() {
  testWidgets('CtrlVideoApp displays navigation destinations and title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          engineManagerProvider.overrideWithValue(FakeEngineManager()),
          engineStatusFutureProvider.overrideWith((ref) async => true),
        ],
        child: const CtrlVideoApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ctrl+video'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Queue'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
