import 'dart:convert';

import 'package:test/test.dart';
import 'package:tests/custom_client.dart';

void main() {
  group('serialization', () {
    test('simple', () {});

    test('item serialization works with null createdAt', () {
      expect(Item.fromJson(jsonDecode(jsonEncode(_itemNullCreatedAt))), isNotNull);
    });

    test('item serialization works with non-null createdAt', () {
      expect(Item.fromJson(jsonDecode(jsonEncode(_itemNonNullCreatedAt))), isNotNull);
    });
  });
}

final Item _itemNullCreatedAt = Item(
  id: "unique_id",
  name: "Item",
  tier: ItemTier.PREMIUM,
  count: 999,
  createdAt: null,
);

final Item _itemNonNullCreatedAt = Item(
  id: "unique_id",
  name: "Item",
  tier: ItemTier.PREMIUM,
  count: 999,
  createdAt: DateTime.now(),
);
