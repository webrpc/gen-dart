import 'dart:async';
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

  group('client correctly calls API', () {
    final String baseUrl = 'http://bogus.com';
    late MockHttpClient httpClient;
    late CustomService client;

    setUp(
      // https://api.flutter.dev/flutter/dart-io/HttpOverrides-class.html
      () {
        httpClient = MockHttpClient();
        client = CustomServiceImpl(baseUrl, httpClient);
      },
    );

    WebrpcHttpResponse happy(dynamic body) {
      return WebrpcHttpResponse(statusCode: 200, body: jsonEncode(body));
    }

    Uri uri(String method) {
      return Uri.parse("$baseUrl/rpc/CustomService/$method");
    }

    test('core type: byte', () async {
      final int request = _rand.nextInt(8);
      httpClient.setResponse(uri('MByte'), happy({'v': request}));
      expect((await client.mByte(request)).v, equals(request));
    });

    test('core type: bool', () async {
      final bool request = _rand.nextBool();
      httpClient.setResponse(uri('MBool'), happy({'v': request}));
      expect((await client.mBool(request)).v, equals(request));
    });

    test('core type: any', () async {
      final dynamic request = {'hello': 'world', 'goodbye': 3};
      httpClient.setResponse(uri('MAny'), happy({'v': request}));
      expect((await client.mAny(request)).v, equals(request));
    });

    test('core type: null', () async {
      final Null request = null;
      httpClient.setResponse(uri('MNull'), happy({'v': request}));
      expect((await client.mNull(request)).v, equals(request));
    });

    test('core type: uint8', () async {
      final int request = pow(2, 8).toInt();
      httpClient.setResponse(uri('MUint8'), happy({'v': request}));
      expect((await client.mUint8(request)).v, equals(request));
    });

    test('core type: uint16', () async {
      final int request = pow(2, 16).toInt();
      httpClient.setResponse(uri('MUint16'), happy({'v': request}));
      expect((await client.mUint16(request)).v, equals(request));
    });

    test('core type: uint32', () async {
      final int request = pow(2, 32).toInt();
      httpClient.setResponse(uri('MUint32'), happy({'v': request}));
      expect((await client.mUint32(request)).v, equals(request));
    });

    test('core type: uint64', () async {
      final int maxInt = 0x7FFFFFFFFFFFFFFF;
      final int request = maxInt;
      httpClient.setResponse(uri('MUint64'), happy({'v': request}));
      expect((await client.mUint64(request)).v, equals(request));
    });

    test('core type: int8', () async {
      final int request = pow(2, 8).toInt();
      httpClient.setResponse(uri('MInt8'), happy({'v': request}));
      expect((await client.mInt8(request)).v, equals(request));
    });

    test('core type: int16', () async {
      final int request = pow(2, 16).toInt();
      httpClient.setResponse(uri('MInt16'), happy({'v': request}));
      expect((await client.mInt16(request)).v, equals(request));
    });

    test('core type: int32', () async {
      final int request = pow(2, 32).toInt();
      httpClient.setResponse(uri('MInt32'), happy({'v': request}));
      expect((await client.mInt32(request)).v, equals(request));
    });

    test('core type: int64', () async {
      final int minInt = -0x8000000000000000;
      final int request = minInt;
      httpClient.setResponse(uri('MInt64'), happy({'v': request}));
      expect((await client.mInt64(request)).v, equals(request));
    });

    test('core type: float32', () async {
      final double request = pow(2.0, 32).toDouble();
      httpClient.setResponse(uri('MFloat32'), happy({'v': request}));
      expect((await client.mFloat32(request)).v, equals(request));
    });

    test('core type: float64', () async {
      final double request = pow(2.0, 64).toDouble();
      httpClient.setResponse(uri('MFloat64'), happy({'v': request}));
      expect((await client.mFloat64(request)).v, equals(request));
    });

    test('core type: string', () async {
      final String request = _genKey(1000);
      httpClient.setResponse(uri('MString'), happy({'v': request}));
      expect((await client.mString(request)).v, equals(request));
    });

    test('core type: timestamp', () async {
      final DateTime request = _genDateTime();
      httpClient.setResponse(uri('MTimestamp'), happy({'v': request.toIso8601String()}));
      expect((await client.mTimestamp(request)).v, equals(request));
    });

    test('struct with required fields', () async {
      final CoreTypesRequired request = _coreTypesRequired;
      httpClient.setResponse(uri('CoreTypesRequired'), happy({'v': request}));
      expect((await client.coreTypesRequired(request)).v, isNotNull);
    });

    test('struct with optional fields all null', () async {
      final CoreTypesOptional request = _coreTypesOptionalNull;
      httpClient.setResponse(uri('CoreTypesOptional'), happy({'v': request}));
      expect((await client.coreTypesOptional(request)).v, isNotNull);
    });

    test('struct with optional fields all non-null', () async {
      final CoreTypesOptional request = _coreTypesOptionalNonNull;
      httpClient.setResponse(uri('CoreTypesOptional'), happy({'v': request}));
      expect((await client.coreTypesOptional(request)).v, isNotNull);
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

class MockHttpClient implements WebrpcHttpClient {
  Map<Uri, WebrpcHttpResponse> responses = {};

  void setResponse(Uri uri, WebrpcHttpResponse response) {
    responses[uri] = response;
  }

  @override
  Future<WebrpcHttpResponse> post(WebrpcHttpRequest request) {
    return Future.microtask(() {
      if (responses[request.uri] == null) {
        throw StateError('Set the response');
      } else {
        return responses[request.uri]!;
      }
    });
  }
}
