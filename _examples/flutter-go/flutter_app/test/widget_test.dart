// This is an example Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
//
// Visit https://flutter.dev/docs/cookbook/testing/widget/introduction for
// more information about Widget testing.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/generated/sdk.dart';
import 'package:flutter_app/src/dev/mock_sdk.dart';
import 'package:flutter_app/src/sample_feature/sample_item_details_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Run these tests by using the configured task in VS code or
/// cd _examples/flutter-go/flutter_app
/// flutter test --dart-define=SERVICE=mock

void main() {
  group('SampleItemDetailsView', () {
    testWidgets('displays correct count of an item', (WidgetTester tester) async {
      final MockExampleService service = MockExampleService();
      service.setMaxDelay(Duration.zero);
      final int count = _genInt(1000);
      final Item item = Item(
        id: "test_item",
        name: "My Item",
        tier: ItemTier.PREMIUM,
        count: count,
        createdAt: DateTime.now(),
        lastUpdate: null,
      );
      final ItemSummary summary = ItemSummary(id: item.id, name: item.name);
      service.putItem(item);
      final Widget widget = _makeTestWidget(SampleItemDetailsView(summary: summary), service);

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text("Count: $count"), findsOneWidget);
    });
  });
}

Widget _makeTestWidget(Widget body, ExampleService service) {
  return MultiProvider(
    providers: [Provider<ExampleService>(create: (_) => service)],
    child: MaterialApp(
      home: body,
    ),
  );
}

final Random _rand = Random.secure();
int _genInt(int max) {
  return _rand.nextInt(max);
}
