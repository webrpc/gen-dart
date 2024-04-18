import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tests/ref_client.dart';

void main() {
  group('Test interoperability with webrpc-test reference server', () {
    final TestApi client = TestApiImpl("http://localhost:${Platform.environment['PORT']}");

    test('serialization', () {
      expect(Complex.fromJson(jsonDecode(jsonEncode(_complex))), isNotNull);
      expect(Simple.fromJson(jsonDecode(jsonEncode(_simple))), isNotNull);
      expect(User.fromJson(jsonDecode(jsonEncode(_user))), isNotNull);
      expect(Status.fromJson(jsonDecode(jsonEncode(_status))), isNotNull);

      // TODO future version where we implement deep equality by overriding == and hashCode
      // expect(Complex.fromJson(jsonDecode(jsonEncode(_complex))), equals(_complex));
      // expect(Simple.fromJson(jsonDecode(jsonEncode(_simple))), equals(_simple));
      // expect(User.fromJson(jsonDecode(jsonEncode(_user))), equals(_user));
      // expect(Status.fromJson(jsonDecode(jsonEncode(_status))), equals(_status));
    });

    test('GetEmpty - doesnt throw', () async {
      await client.getEmpty();
    });

    test('GetError - throws expected error', () async {
      expectLater(client.getError(), throwsA(anything));
    });

    test('GetOne - returns complete result', () async {
      final (:one) = await client.getOne();
      expectSimpleIsComplete(one);
    });

    test('SendOne - doesnt throw', () async {
      await client.sendOne((await client.getOne()).one);
    });

    test('GetMulti - returns complete result', () async {
      final (:one, :two, :three) = await client.getMulti();
      expectSimpleIsComplete(one);
      expectSimpleIsComplete(two);
      expectSimpleIsComplete(three);
    });

    test('GetComplex - returns complete result', () async {
      final (:complex) = await client.getComplex();
      expect(complex, isNotNull);
      expect(complex.doubleArray, isNotNull);
      expect(complex.listOfMaps, isNotNull);
      expect(complex.listOfUsers, isNotNull);
      expect(complex.mapOfUsers, isNotNull);
      expect(complex.meta, isNotNull);
      expect(complex.metaNestedExample, isNotNull);
      expect(complex.namesList, isNotNull);
      expect(complex.numsList, isNotNull);
      expect(complex.status, isNotNull);
      expect(complex.user, isNotNull);
      expect(complex.user.USERNAME, isNotNull);
      expect(complex.user.id, isNotNull);
      expect(complex.user.role, isNotNull);
    });

    test('SendComplex - doesnt throw', () async {
      await client.sendComplex((await client.getComplex()).complex);
    });

    test('GetSchemaError(Unauthorized) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(1), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(ExpiredToken) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(2), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(InvalidToken) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(3), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(Deactivated) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(4), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(ConfirmAccount) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(5), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(AccessDenied) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(6), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(MissingArgument) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(7), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(UnexpectedValue) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(8), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(RateLimited) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(100), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(DatabaseDown) - throws WebrpcException', () async {
      expectLater(client.getSchemaError(101), throwsA(isA<WebrpcException>()));
    });

    test('GetSchemaError(ElasticDown) - throws WebrpcException', () async {
      expectLater(client.getSchemaError(102), throwsA(isA<WebrpcException>()));
    });

    test('GetSchemaError(NotImplemented) - throws WebrpcException', () async {
      expectLater(client.getSchemaError(103), throwsA(isA<WebrpcException>()));
    });

    test('GetSchemaError(UserNotFound) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(200), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(UserBusy) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(201), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(InvalidUsername) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(202), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(FileTooBig) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(300), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(FileInfected) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(301), throwsA(isA<WebrpcError>()));
    });

    test('GetSchemaError(FileType) - throws WebrpcError', () async {
      expectLater(client.getSchemaError(302), throwsA(isA<WebrpcError>()));
    });
  });
}

void expectSimpleIsComplete(Simple candidate) {
  expect(candidate, isNotNull);
  expect(candidate.id, isNotNull);
  expect(candidate.name, isNotNull);
}

final Complex _complex = Complex(
  meta: {
    'a': 1,
    'b': '2',
    'c': [
      3,
      '4',
      [
        '5',
        6,
        {'d': 7}
      ],
      {
        'e': '8',
        'f': ['9', 10]
      }
    ],
    'g': {'h': '11'}
  },
  metaNestedExample: {
    'a': {'b': 2, 'c': 3},
    'd': {'e': 4}
  },
  namesList: ['a', 'b', 'c'],
  numsList: [BigInt.from(1), BigInt.from(2), BigInt.from(3)],
  doubleArray: [
    ['a', 'b', 'c'],
    ['d', 'e', 'f']
  ],
  listOfMaps: [
    {'a': 1, 'b': 2},
    {'c': 3},
    {},
    {'d': 4}
  ],
  listOfUsers: [User(id: BigInt.from(1), USERNAME: 'AWM', role: 'goat')],
  mapOfUsers: {'MLB': User(id: BigInt.from(2), USERNAME: 'MLB', role: 'ref')},
  user: User(id: BigInt.from(3), USERNAME: 'FAQ', role: 'what'),
  status: Status.AVAILABLE,
);

final Simple _simple = Simple(id: 5, name: 'AWM');

final User _user = User(id: BigInt.from(10), USERNAME: 'AWM', role: 'goat');

final Status _status = Status.AVAILABLE;
