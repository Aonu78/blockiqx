import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blockiqx/providers/auth_provider.dart';
import 'package:blockiqx/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    await authProvider.loadFromStorage();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: BLOCKIQxApp(authProvider: authProvider),
      ),
    );

    expect(find.byType(BLOCKIQxApp), findsOneWidget);
  });
}
