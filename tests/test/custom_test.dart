import 'dart:convert';
import 'dart:math';

import 'package:test/test.dart';
import 'package:tests/custom_client.dart';

void main() {
  group('serialization', () {
    test('core types serialization works with required fields', () {
      expect(CoreTypesRequired.fromJson(jsonDecode(jsonEncode(_coreTypesRequired))), isNotNull);
    });

    test('core types serialization works with non-null optional fields', () {
      expect(CoreTypesOptional.fromJson(jsonDecode(jsonEncode(_coreTypesOptionalNonNull))), isNotNull);
    });

    test('core types serialization works with null optional fields', () {
      expect(CoreTypesOptional.fromJson(jsonDecode(jsonEncode(_coreTypesOptionalNull))), isNotNull);
    });

    test('complex serialization works with nested objects', () {
      for (int i = 0; i < 10; i++) {
        expect(Complex.fromJson(jsonDecode(jsonEncode(_genComplex(depth: 3)))), isNotNull);
      }
    });
  });
}

final CoreTypesOptional _coreTypesOptionalNull = CoreTypesOptional(
  mByte: null,
  mBool: null,
  mNull: null,
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
  mNull: null,
  mAny: (a: 3, b: '4', 'hello, world'),
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
  mNull: null,
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

Complex _genComplex({
  int depth = 2,
  int nestedMaxSize = 3,
}) {
  final bool dive = depth > 0;
  genNested() => _genComplex(
        depth: depth - 1,
        nestedMaxSize: nestedMaxSize,
      );

  genNestedList() => !dive ? List<Complex>.empty() : _genList(nestedMaxSize, genNested);

  return Complex(
    coreList: _genList(nestedMaxSize, () => _rand.nextInt(9999)),
    recursiveList: genNestedList(),
    nestedList: _genList(nestedMaxSize, genNestedList),
    optionalList: _rand.nextBool() ? null : _genList(nestedMaxSize, () => _rand.nextInt(999)),
    coreMap: Map.fromEntries(_genList(
      nestedMaxSize,
      () => MapEntry(_genKey(10), _genDateTime()),
    )),
    recursiveMap: !dive
        ? {}
        : Map.fromEntries(_genList(
            nestedMaxSize,
            () => MapEntry(_genKey(10), genNested()),
          )),
    nestedMap: Map.fromEntries(_genList(
      nestedMaxSize,
      () => MapEntry(
        _genKey(10),
        Map.fromEntries(_genList(
          nestedMaxSize,
          () => MapEntry(_rand.nextInt(9999), genNestedList()),
        )),
      ),
    )),
    optionalMap: _rand.nextBool()
        ? null
        : Map.fromEntries(_genList(
            nestedMaxSize,
            () => MapEntry(_genKey(10), _genDateTime()),
          )),
    myEnum: _choose(MyEnum.values),
    myEnumList: _genList(nestedMaxSize, () => _choose(MyEnum.values)),
    myEnumMap: Map.fromEntries(_genList(
      nestedMaxSize,
      () => MapEntry(_genKey(10), _choose(MyEnum.values)),
    )),
    myEnumOptional: _rand.nextBool() ? null : _choose(MyEnum.values),
  );
}

String _genKey(int length) {
  return List.generate(length, (_) => _choose(chars)).join('');
}

List<T> _genList<T>(int nMax, T Function() generator) {
  return List.generate(_rand.nextInt(nMax), (_) => generator());
}

DateTime _genDateTime() {
  final int msSinceEpoch = _rand.nextInt(max(1, min(4294967296, DateTime.now().millisecondsSinceEpoch)));
  return DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
}

T _choose<T>(List<T> options) {
  return options[_rand.nextInt(options.length)];
}

final List<String> chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('');
final Random _rand = Random();
