export 'prefs_db.dart';

/// An interface defining the contract for local database operations.
///
/// This interface provides methods for initializing the database and performing
/// various data storage and retrieval operations for different data types.
///
/// Implementations of this interface should ensure efficient handling of data
/// persistence and retrieval, allowing for seamless interaction with local
/// storage mechanisms.
///
/// Example usage:
/// ```dart
/// class MyLocalDb implements LocalDbI {
///   // Implementation details...
/// }
/// ```
///
/// @ai When implementing this interface, ensure that all methods are properly
/// implemented to handle data persistence and retrieval efficiently.
abstract interface class LocalDbI {
  /// Initializes the local database.
  ///
  /// This method should be called before any other database operations are
  /// performed to ensure that the database is ready for use.
  ///
  /// @ai Ensure this method is called early in the application lifecycle
  /// to avoid any uninitialized access errors.
  Future<void> init();

  /// Stores a map of key-value pairs in the database.
  ///
  /// This method serializes the provided map and stores it under the specified
  /// key for later retrieval.
  ///
  /// [key] The unique identifier for the stored map.
  /// [value] The map to be stored.
  ///
  /// @ai Implement this method to efficiently serialize and store the map.
  Future<void> setMap({
    required final String key,
    required final Map<String, dynamic> value,
  });

  /// Retrieves a map of key-value pairs from the database.
  ///
  /// This method fetches the serialized map stored under the specified key
  /// and deserializes it for use.
  ///
  /// [key] The unique identifier for the stored map.
  /// @returns A [Future] that completes with the retrieved map.
  ///
  /// @ai Implement this method to deserialize and return the stored map.
  Future<Map<String, dynamic>> getMap(
    final String key,
  );

  /// Stores a string value in the database.
  ///
  /// This method saves the provided string under the specified key for later
  /// retrieval.
  ///
  /// [key] The unique identifier for the stored string.
  /// [value] The string to be stored.
  ///
  /// @ai Ensure this method handles empty strings appropriately to avoid
  /// unexpected behavior.
  Future<void> setString({
    required final String key,
    required final String value,
  });

  /// Retrieves a string value from the database.
  ///
  /// This method fetches the string stored under the specified key.
  ///
  /// [key] The unique identifier for the stored string.
  /// [defaultValue] The value to return if the key is not found.
  /// @returns A [Future] that completes with the retrieved string.
  ///
  /// @ai Implement proper error handling for cases where the key is not found
  /// to ensure a smooth user experience.
  Future<String> getString({
    required final String key,
    final String defaultValue = '',
  });

  /// Stores a boolean value in the database.
  ///
  /// This method saves the provided boolean under the specified key for later
  /// retrieval.
  ///
  /// [key] The unique identifier for the stored boolean.
  /// [value] The boolean to be stored.
  ///
  /// @ai Ensure that the boolean value is correctly stored and retrieved.
  Future<void> setBool({
    required final String key,
    required final bool value,
  });

  /// Retrieves a boolean value from the database.
  ///
  /// This method fetches the boolean stored under the specified key.
  ///
  /// [key] The unique identifier for the stored boolean.
  /// [defaultValue] The value to return if the key is not found.
  /// @returns A [Future] that completes with the retrieved boolean.
  ///
  /// @ai Ensure that the default value is returned correctly when the key is
  /// not found.
  Future<bool> getBool({
    required final String key,
    final bool defaultValue = false,
  });

  /// Stores an integer value in the database.
  ///
  /// This method saves the provided integer under the specified key for later
  /// retrieval.
  ///
  /// [key] The unique identifier for the stored integer.
  /// [value] The integer to be stored.
  ///
  /// @ai Ensure that the integer value is correctly stored and retrieved.
  Future<void> setInt({
    required final String key,
    final int value = 0,
  });

  /// Retrieves an integer value from the database.
  ///
  /// This method fetches the integer stored under the specified key.
  ///
  /// [key] The unique identifier for the stored integer.
  /// [defaultValue] The value to return if the key is not found.
  /// @returns A [Future] that completes with the retrieved integer.
  ///
  /// @ai Ensure that the default value is returned correctly when the key is
  /// not found.
  Future<int> getInt({
    required final String key,
    final int defaultValue = 0,
  });

  /// Stores a generic item in the database.
  ///
  /// This method serializes the provided item and stores it under the specified
  /// key for later retrieval.
  ///
  /// [key] The unique identifier for the stored item.
  /// [value] The item to be stored.
  /// [toJson] A function to serialize the item to a map.
  ///
  /// @ai Ensure that the serialization function is efficient and handles all
  /// necessary fields.
  Future<void> setItem<T>({
    required final String key,
    required final T value,
    required final Map<String, dynamic> Function(T) toJson,
  });

  /// Retrieves a generic item from the database.
  ///
  /// This method fetches the serialized item stored under the specified key
  /// and deserializes it for use.
  ///
  /// [key] The unique identifier for the stored item.
  /// [fromJson] A function to deserialize the map to the desired item type.
  /// [defaultValue] The default value to return if the key is not found.
  /// @returns A [Future] that completes with the retrieved item.
  ///
  /// @ai Ensure that the deserialization function is efficient and handles
  /// all necessary fields.
  Future<T> getItem<T>({
    required final String key,
    required final T? Function(Map<String, dynamic>) fromJson,
    required final T defaultValue,
  });

  /// Stores a list of generic items in the database.
  ///
  /// This method serializes the provided list and stores it under the specified
  /// key for later retrieval.
  ///
  /// [key] The unique identifier for the stored list.
  /// [value] The list of items to be stored.
  /// [toJson] A function to serialize each item to a map.
  ///
  /// @ai Ensure that the serialization function is efficient and handles all
  /// necessary fields.
  Future<void> setItemsList<T>({
    required final String key,
    required final List<T> value,
    required final Map<String, dynamic> Function(T) toJson,
  });

  /// Retrieves a list of generic items from the database.
  ///
  /// This method fetches the serialized list stored under the specified key
  /// and deserializes it for use.
  ///
  /// [key] The unique identifier for the stored list.
  /// [fromJson] A function to deserialize the map to the desired item type.
  /// [defaultValue] The default list to return if the key is not found.
  /// @returns A [Future] that completes with an [Iterable] of the retrieved
  /// items.
  ///
  /// @ai Ensure that the deserialization function is efficient and handles
  /// all necessary fields.
  Future<Iterable<T>> getItemsIterable<T>({
    required final String key,
    required final T Function(Map<String, dynamic>) fromJson,
    final List<T> defaultValue = const [],
  });

  /// Stores a list of maps in the database.
  ///
  /// This method serializes the provided list of maps and stores it under the
  /// specified key for later retrieval.
  ///
  /// [key] The unique identifier for the stored list of maps.
  /// [value] The list of maps to be stored.
  ///
  /// @ai Ensure that the serialization is efficient and handles all necessary
  /// fields.
  Future<void> setMapList({
    required final String key,
    required final List<Map<String, dynamic>> value,
  });

  /// Retrieves a list of maps from the database.
  ///
  /// This method fetches the serialized list of maps stored under the specified
  /// key and deserializes it for use.
  ///
  /// [key] The unique identifier for the stored list of maps.
  /// [defaultValue] The default list to return if the key is not found.
  /// @returns A [Future] that completes with an [Iterable] of the retrieved
  /// maps.
  ///
  /// @ai Ensure that the deserialization is efficient and handles all necessary
  /// fields.
  Future<Iterable<Map<String, dynamic>>> getMapIterable({
    required final String key,
    final List<Map<String, dynamic>> defaultValue = const [],
  });

  /// Stores a list of strings in the database.
  ///
  /// This method saves the provided list of strings under the specified key
  /// for later retrieval.
  ///
  /// [key] The unique identifier for the stored list of strings.
  /// [value] The list of strings to be stored.
  ///
  /// @ai Ensure that the list is correctly serialized and stored.
  Future<void> setStringList({
    required final String key,
    required final List<String> value,
  });

  /// Retrieves a list of strings from the database.
  ///
  /// This method fetches the list of strings stored under the specified key.
  ///
  /// [key] The unique identifier for the stored list of strings.
  /// [defaultValue] The default list to return if the key is not found.
  /// @returns A [Future] that completes with an [Iterable] of the retrieved
  /// strings.
  ///
  /// @ai Ensure that the default value is returned correctly when the key is
  /// not found.
  Future<Iterable<String>> getStringsIterable({
    required final String key,
    final List<String> defaultValue = const [],
  });
}
