import 'dart:convert';

import 'package:test/test.dart';
import 'package:tests/custom_client.dart';

void main() {
  group('serialization', () {
    test('simple', () {
      expect(ItemSummary.fromJson(jsonDecode(jsonEncode(_itemSummary))), isNotNull);
      expect(ItemTier.fromJson(jsonDecode(jsonEncode(_itemTier))), isNotNull);
    });

    test('core types serialization works with required fields', () {
      expect(CoreTypesRequired.fromJson(jsonDecode(jsonEncode(_coreTypesRequired))), isNotNull);
    });

    test('core types serialization works with non-null optional fields', () {
      expect(CoreTypesOptional.fromJson(jsonDecode(jsonEncode(_coreTypesOptionalNonNull))), isNotNull);
    });

    test('core types serialization works with null optional fields', () {
      expect(CoreTypesOptional.fromJson(jsonDecode(jsonEncode(_coreTypesOptionalNull))), isNotNull);
    });

    test('item serialization works', () {
      expect(Item.fromJson(jsonDecode(jsonEncode(_item))), isNotNull);
    });
  });
}

final ItemSummary _itemSummary = ItemSummary(
  id: "unique id",
  name: "Item Summary",
);

final ItemTier _itemTier = ItemTier.PREMIUM;

final Item _item = Item(
  id: "unique_id",
  name: "Item",
  tier: ItemTier.PREMIUM,
  count: 999,
  createdAt: DateTime.now(),
);

final CoreTypesOptional _coreTypesOptionalNull = CoreTypesOptional(
  mByte: null,
  mBool: null,
  mAny: null,
  mUint8: null,
  mUint16: null,
  mUint32: null,
  mUint64: null,
  mInt8: null,
  mInt16: null,
  mInt32: null,
  mInt64: null,
  mFloat32: null,
  mFloat64: null,
  mString: null,
  mTimestamp: null,
);

final CoreTypesOptional _coreTypesOptionalNonNull = CoreTypesOptional(
  mByte: 1,
  mBool: false,
  mAny: {'a': 3, "b": 4},
  mUint8: 2,
  mUint16: 3,
  mUint32: 4,
  mUint64: 5,
  mInt8: -1,
  mInt16: -2,
  mInt32: -3,
  mInt64: -4,
  mFloat32: 1.1,
  mFloat64: 2.2,
  mString: "hello, world",
  mTimestamp: DateTime.now(),
);

final CoreTypesRequired _coreTypesRequired = CoreTypesRequired(
  mByte: 1,
  mBool: false,
  mAny: {'a': 3, "b": 4},
  mUint8: 2,
  mUint16: 3,
  mUint32: 4,
  mUint64: 5,
  mInt8: -1,
  mInt16: -2,
  mInt32: -3,
  mInt64: -4,
  mFloat32: 1.1,
  mFloat64: 2.2,
  mString: "hello, world",
  mTimestamp: DateTime.now(),
);
