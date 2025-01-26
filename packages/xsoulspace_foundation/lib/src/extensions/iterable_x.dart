import 'dart:math';

import 'package:collection/collection.dart';

/// A function that converts an old item to a new item.
typedef IterableConverter<TOld, TNew> = Future<TNew> Function(TOld item);

/// Extension methods for [Iterable] to provide additional functionality.
///
/// This extension adds useful methods for manipulating and converting
/// iterables, enhancing their capabilities for various use cases.
///
/// @ai Use this extension to simplify operations on iterables in your code.
extension XSIterableX<E> on Iterable<E> {
  /// Converts the iterable to a map with indexed keys.
  ///
  /// This method creates a map where the keys are generated from the provided
  /// [toId] function, and the values are the indices of the items in the
  /// iterable.
  ///
  /// [toId] A function that generates a key from each item.
  /// @returns A map with keys and their corresponding indices.
  ///
  /// @ai Use this method to create indexed maps for easier lookups.
  Map<TId, int> toIndexedMap<TId>(final TId Function(E e) toId) {
    final iterableEntries =
        mapIndexed((final index, final e) => MapEntry(toId(e), index));

    return Map.fromEntries(iterableEntries);
  }

  /// Returns a random element from the iterable.
  ///
  /// If the iterable is empty, returns null.
  ///
  /// @returns A random element or null if the iterable is empty.
  ///
  /// @ai Use this method to retrieve random items from collections.
  E? randomElement() {
    if (isEmpty) return null;

    final rand = Random();

    return elementAt(rand.nextInt(length));
  }

  /// Converts the iterable to a map using the provided key and value functions.
  ///
  /// [toKey] A function that generates a key from each item.
  /// [toValue] A function that generates a value from each item.
  /// @returns A map with keys and their corresponding values.
  ///
  /// @ai Use this method to create maps from collections for easier access.
  Map<TKey, TMapType> toMap<TKey, TMapType>({
    required final TKey Function(E item) toKey,
    required final TMapType Function(E item) toValue,
  }) {
    final iterableEntries = map((final e) {
      final key = toKey(e);
      final value = toValue(e);

      return MapEntry(key, value);
    });

    return Map.fromEntries(iterableEntries);
  }

  /// Converts the items in the iterable using the provided converter function.
  ///
  /// [converter] A function that converts each item to a new type.
  /// @returns A future iterable of converted items.
  ///
  /// @ai Use this method to transform collections asynchronously.
  Future<Iterable<TNew>> convert<TNew>(
    final IterableConverter<E, TNew> converter,
  ) async {
    final list = <TNew>[];
    for (final item in this) {
      list.add(await converter(item));
    }
    return list;
  }
}
