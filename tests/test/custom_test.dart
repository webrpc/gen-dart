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

    WebrpcHttpResponse makeResponse(dynamic body, [int status = 200]) {
      return WebrpcHttpResponse(statusCode: status, body: jsonEncode(body));
    }

    WebrpcHttpResponse happy(dynamic body) {
      return makeResponse(body);
    }

    WebrpcHttpResponse sadClient(ErrorId id) {
      final WebrpcError error = WebrpcError.fromCode(id.code);
      return makeResponse({'code': id.code}, error.httpStatus);
    }

    WebrpcHttpResponse sadServer(ErrorId id) {
      final WebrpcException error = WebrpcException.fromCode(id.code);
      return makeResponse({'code': id.code}, error.httpStatus);
    }

    Future<WebrpcError> catchWebrpcError(Future request) async {
      try {
        await request;
      } on WebrpcError catch (e) {
        return e;
      }
      fail("Expected a WebrpcError but didnt get one.");
    }

    Future<WebrpcException> catchWebrpcException(Future request) async {
      try {
        await request;
      } on WebrpcException catch (e) {
        return e;
      }
      fail("Expected a WebrpcException but didnt get one.");
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

    test('core type: list', () async {
      final List<int> request = _genList(10, () => _rand.nextInt(999));
      httpClient.setResponse(uri('MList'), happy({'v': request}));
      expect((await client.mList(request)).v, isNotNull);
    });

    test('core type: map', () async {
      final Map<int, String> request = Map.fromEntries(_genList(10, () => MapEntry(_rand.nextInt(999), _genKey(10))));
      httpClient.setResponse(uri('MMap'), happy({'v': request.map((key, value) => MapEntry(key.toString(), value))}));
      expect((await client.mMap(request)).v, isNotNull);
    });

    test('no request or response - doesnt throw', () async {
      httpClient.setResponse(uri('Ping'), happy(null));
      await client.ping();
    });

    test('no request and single result', () async {
      final int response = _rand.nextInt(9999);
      httpClient.setResponse(uri('GetOne'), happy({'v': response}));
      expect((await client.getOne()).v, equals(response));
    });

    test('no request and multiple results', () async {
      final ({int v1, int v2}) expected = (v1: _rand.nextInt(9999), v2: _rand.nextInt(9999));
      httpClient.setResponse(uri('GetMulti'), happy({'v1': expected.v1, 'v2': expected.v2}));
      final result = await client.getMulti();
      expect(result.v1, equals(expected.v1));
      expect(result.v2, equals(expected.v2));
    });

    test('send one with no response - doesnt throw', () async {
      final int request = _rand.nextInt(9999);
      httpClient.setResponse(uri('SendOne'), happy(null));
      await client.sendOne(request);
    });

    test('send multiple with no response - doesnt throw', () async {
      final ({int v1, int v2}) request = (v1: _rand.nextInt(9999), v2: _rand.nextInt(9999));
      httpClient.setResponse(uri('SendMulti'), happy(null));
      await client.sendMulti(request.v1, request.v2);
    });

    test('receive error - smallest code number - valid response', () async {
      final ErrorId errorId = ErrorId.smallestCode;
      httpClient.setResponse(uri('GetSchemaError'), sadClient(ErrorId.smallestCode));
      final WebrpcError error = await catchWebrpcError(client.getSchemaError(errorId.code));
      expect(error, isNotNull);
    });

    test('receive error - basic client error - correct error ID', () async {
      final ErrorId errorId = ErrorId.basicClientError;
      httpClient.setResponse(uri('GetSchemaError'), sadClient(errorId));
      final WebrpcError error = await catchWebrpcError(client.getSchemaError(errorId.code));
      expect(error.id, equals(errorId));
    });

    test('receive error - custom client error - correct error ID', () async {
      final ErrorId errorId = ErrorId.customClientError;
      httpClient.setResponse(uri('GetSchemaError'), sadClient(errorId));
      final WebrpcError error = await catchWebrpcError(client.getSchemaError(errorId.code));
      expect(error.id, equals(errorId));
    });

    test('receive error - basic server error - correct error ID', () async {
      final ErrorId errorId = ErrorId.basicServerError;
      httpClient.setResponse(uri('GetSchemaError'), sadServer(errorId));
      final WebrpcException error = await catchWebrpcException(client.getSchemaError(errorId.code));
      expect(error.id, equals(errorId));
    });

    test('receive error - custom server error - correct error ID', () async {
      final ErrorId errorId = ErrorId.customServerError;
      httpClient.setResponse(uri('GetSchemaError'), sadServer(errorId));
      final WebrpcException error = await catchWebrpcException(client.getSchemaError(errorId.code));
      expect(error.id, equals(errorId));
    });

    test('receive error - error with no specified http code - has default http code', () async {
      final ErrorId errorId = ErrorId.defaultHttpCode;
      httpClient.setResponse(uri('GetSchemaError'), sadClient(errorId));
      final WebrpcError error = await catchWebrpcError(client.getSchemaError(errorId.code));
      expect(error.httpStatus, equals(400));
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
