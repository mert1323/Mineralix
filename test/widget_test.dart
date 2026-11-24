import 'package:flutter_test/flutter_test.dart';
import 'package:mineralix/main.dart';

void main() {
  testWidgets('App loads with bottom navigation', (tester) async {
    await tester.pumpWidget(const MineralixApp());
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Mineralix'), findsOneWidget);
  });
}
