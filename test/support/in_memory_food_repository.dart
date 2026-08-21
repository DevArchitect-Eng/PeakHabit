import 'dart:async';

import 'package:peakhabit/features/nutrition/data/food_repository.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';

/// A [FoodRepository] that keeps the catalogue in memory.
///
/// Same reason as the other fakes next to it: a widget test cannot drive the
/// real database, and what the database does with the rows is covered by the
/// repository tests.
class InMemoryFoodRepository implements FoodRepository {
  InMemoryFoodRepository({
    Iterable<Food> foods = const [],
    Iterable<CompositeFood> dishes = const [],
    this.failing = false,
  }) {
    for (final food in foods) {
      final saved = food.id == null ? food.withId(_nextId++) : food;
      _nextId = saved.id! >= _nextId ? saved.id! + 1 : _nextId;
      _foods[saved.id!] = saved;
    }
    for (final dish in dishes) {
      final saved = dish.id == null ? dish.withId(_nextId++) : dish;
      _nextId = saved.id! >= _nextId ? saved.id! + 1 : _nextId;
      _dishes[saved.id!] = saved;
    }
  }

  /// Lets every read fail, for the case a screen has to tell "could not be
  /// read" apart from "nothing there yet".
  final bool failing;

  /// Lets every write fail, for the case a screen has to report a failed save.
  bool unwritable = false;

  final _foods = <int, Food>{};
  final _dishes = <int, CompositeFood>{};
  final _changes = StreamController<void>.broadcast();
  int _nextId = 1;

  /// The catalogue as it currently stands, by name.
  List<Food> get foods {
    final sorted = _foods.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  @override
  Future<List<Food>> readFoods({Iterable<int>? ids}) async {
    _failIfAsked();
    if (ids == null) return foods;
    final wanted = ids.toSet();
    return foods.where((food) => wanted.contains(food.id)).toList();
  }

  @override
  Stream<List<Food>> watchFoods() => _watch().asyncMap((_) => readFoods());

  @override
  Future<Food?> readFood(int id) async {
    _failIfAsked();
    return _foods[id];
  }

  @override
  Future<Food> saveFood(Food food) async {
    if (unwritable) throw StateError('the food cannot be saved');
    final saved = food.id == null ? food.withId(_nextId++) : food;
    _foods[saved.id!] = saved;
    _changes.add(null);
    return saved;
  }

  @override
  Future<void> deleteFood(int id) async {
    _foods.remove(id);
    _changes.add(null);
  }

  @override
  Future<List<CompositeFood>> readCompositeFoods({Iterable<int>? ids}) async {
    _failIfAsked();
    final sorted = _dishes.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (ids == null) return sorted;
    final wanted = ids.toSet();
    return sorted.where((dish) => wanted.contains(dish.id)).toList();
  }

  @override
  Stream<List<CompositeFood>> watchCompositeFoods() =>
      _watch().asyncMap((_) => readCompositeFoods());

  @override
  Future<CompositeFood?> readCompositeFood(int id) async {
    _failIfAsked();
    return _dishes[id];
  }

  @override
  Future<CompositeFood> saveCompositeFood(CompositeFood dish) async {
    if (unwritable) throw StateError('the dish cannot be saved');
    final saved = dish.id == null ? dish.withId(_nextId++) : dish;
    _dishes[saved.id!] = saved;
    _changes.add(null);
    return saved;
  }

  @override
  Future<void> deleteCompositeFood(int id) async {
    _dishes.remove(id);
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();

  Stream<void> _watch() async* {
    _failIfAsked();
    yield null;
    yield* _changes.stream;
  }

  void _failIfAsked() {
    if (failing) throw StateError('the catalogue cannot be read');
  }
}
