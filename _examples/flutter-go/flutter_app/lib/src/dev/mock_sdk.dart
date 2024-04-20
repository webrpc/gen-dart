/// The generated client code includes an interface for the client which makes
/// it easy to mock for testing and development.

import 'dart:convert';
import 'dart:math';

import 'package:flutter_app/generated/sdk.dart';

class MockExampleService implements ExampleService {
  final Map<String, Item> _items = Map.fromEntries(_startingItems.map((e) => MapEntry(e.id, e)));
  Duration _maxDelay = const Duration(milliseconds: 500);

  void putItem(Item item) {
    _items[item.id] = item;
  }

  void setMaxDelay(Duration duration) {
    _maxDelay = duration;
  }

  @override
  Future<void> createItem(CreateItemRequest item) {
    return Future.delayed(_delay(_maxDelay), () {
      final String id = _generateId();
      _items[id] = Item(
        id: id,
        name: item.name,
        tier: item.tier,
        count: 0,
        createdAt: DateTime.now(),
        lastUpdate: null,
      );
    });
  }

  @override
  Future<void> deleteItem(String itemId) {
    return Future.delayed(_delay(_maxDelay), () {
      if (_items.remove(itemId) == null) {
        throw WebrpcError.fromCode(ErrorId.noSuchItem.code);
      }
    });
  }

  @override
  Future<({Item item})> getItem(String itemId) {
    return Future.delayed(_delay(_maxDelay), () {
      final Item? item = _items[itemId];
      if (item == null) {
        throw WebrpcError.fromCode(ErrorId.noSuchItem.code);
      } else {
        return (item: item);
      }
    });
  }

  @override
  Future<({List<ItemSummary> items})> getItems() {
    return Future.delayed(
      _delay(_maxDelay),
      () => (items: _items.values.map((e) => ItemSummary(id: e.id, name: e.name)).toList()),
    );
  }

  @override
  Future<void> putOne(String itemId) {
    return Future.delayed(_delay(_maxDelay), () {
      final Item? item = _items[itemId];
      if (item == null) {
        throw WebrpcError.fromCode(ErrorId.noSuchItem.code);
      } else {
        _items[itemId] = Item(
          id: itemId,
          name: item.name,
          tier: item.tier,
          count: item.count + 1,
          createdAt: item.createdAt,
          lastUpdate: DateTime.now(),
        );
      }
    });
  }

  @override
  Future<void> takeOne(String itemId) {
    return Future.delayed(_delay(_maxDelay), () {
      final Item? item = _items[itemId];
      if (item == null) {
        throw WebrpcError.fromCode(ErrorId.noSuchItem.code);
      } else if (item.count == 0) {
        throw WebrpcError.fromCode(ErrorId.outOfStock.code);
      } else {
        _items[itemId] = Item(
          id: itemId,
          name: item.name,
          tier: item.tier,
          count: item.count - 1,
          createdAt: item.createdAt,
          lastUpdate: DateTime.now(),
        );
      }
    });
  }
}

final Random _rand = Random.secure();

String _generateId() {
  var values = List<int>.generate(10, (i) => _rand.nextInt(255));
  return base64UrlEncode(values);
}

Duration _delay(Duration maxDelay) {
  final int maxDelayMs = maxDelay.inMilliseconds;
  if (maxDelayMs == 0) {
    return Duration.zero;
  } else {
    return Duration(milliseconds: _rand.nextInt(maxDelayMs));
  }
}

final List<Item> _startingItems = [
  Item(
      id: _generateId(),
      name: "Cheese",
      tier: ItemTier.REGULAR,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "Romaine Lettuce",
      tier: ItemTier.PREMIUM,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "Iceberge Lettuce",
      tier: ItemTier.REGULAR,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "Heirloom Tomato",
      tier: ItemTier.PREMIUM,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "Hothouse Tomato",
      tier: ItemTier.REGULAR,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "White Bread",
      tier: ItemTier.REGULAR,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "Sourdough Bread",
      tier: ItemTier.PREMIUM,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
  Item(
      id: _generateId(),
      name: "Mayonnaise",
      tier: ItemTier.REGULAR,
      count: _rand.nextInt(3),
      createdAt: DateTime.now(),
      lastUpdate: null),
];
