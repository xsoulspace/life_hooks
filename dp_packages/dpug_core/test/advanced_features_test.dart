import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Advanced Features Conversion', () {
    final converter = DpugConverter();

    group('Imports and Exports', () {
      test('converts core Dart imports', () {
        const dpugCode = '''
import 'dart:math'
import 'dart:convert'
import 'dart:io'
import 'dart:async'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("import 'dart:math';"));
        expect(dartCode, contains("import 'dart:convert';"));
        expect(dartCode, contains("import 'dart:io';"));
        expect(dartCode, contains("import 'dart:async';"));
      });

      test('converts package imports', () {
        const dpugCode = '''
import 'package:flutter/material.dart'
import 'package:provider/provider.dart'
import 'package:dpug_core/compiler/dpug_converter.dart'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("import 'package:flutter/material.dart';"));
        expect(dartCode, contains("import 'package:provider/provider.dart';"));
        expect(
          dartCode,
          contains("import 'package:dpug_core/compiler/dpug_converter.dart';"),
        );
      });

      test('converts relative imports', () {
        const dpugCode = '''
import '../models/user.dart'
import 'utils/helpers.dart'
import '../../widgets/custom_button.dart'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("import '../models/user.dart';"));
        expect(dartCode, contains("import 'utils/helpers.dart';"));
        expect(
          dartCode,
          contains("import '../../widgets/custom_button.dart';"),
        );
      });

      test('converts imports with alias', () {
        const dpugCode = '''
import 'package:http/http.dart' as http
import 'package:collection/collection.dart' as coll
import 'dart:math' as math
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("import 'package:http/http.dart' as http;"));
        expect(
          dartCode,
          contains("import 'package:collection/collection.dart' as coll;"),
        );
        expect(dartCode, contains("import 'dart:math' as math;"));
      });

      test('converts selective imports', () {
        const dpugCode = '''
import 'math_utils.dart' show add, multiply, pi
import 'string_utils.dart' hide trim, padLeft
import 'package:flutter/material.dart' show Text, Container, Column
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains("import 'math_utils.dart' show add, multiply, pi;"),
        );
        expect(
          dartCode,
          contains("import 'string_utils.dart' hide trim, padLeft;"),
        );
        expect(
          dartCode,
          contains(
            "import 'package:flutter/material.dart' show Text, Container, Column;",
          ),
        );
      });

      test('converts deferred imports', () {
        const dpugCode = '''
import 'heavy_library.dart' deferred as heavy
import 'analytics.dart' deferred as analytics
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains("import 'heavy_library.dart' deferred as heavy;"),
        );
        expect(
          dartCode,
          contains("import 'analytics.dart' deferred as analytics;"),
        );
      });

      test('converts exports', () {
        const dpugCode = '''
export 'user_model.dart'
export 'user_service.dart'
export 'math_utils.dart' show Math, Calculator
export 'string_utils.dart' hide internalFunction
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("export 'user_model.dart';"));
        expect(dartCode, contains("export 'user_service.dart';"));
        expect(
          dartCode,
          contains("export 'math_utils.dart' show Math, Calculator;"),
        );
        expect(
          dartCode,
          contains("export 'string_utils.dart' hide internalFunction;"),
        );
      });
    });

    group('Library Structure', () {
      test('converts library declarations', () {
        const dpugCode = '''
library my_app.utils

import 'dart:math'
import 'package:flutter/material.dart'

export 'math_utils.dart'
export 'string_utils.dart'

part 'internal_utils.dart'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('library my_app.utils;'));
        expect(dartCode, contains("import 'dart:math';"));
        expect(dartCode, contains("import 'package:flutter/material.dart';"));
        expect(dartCode, contains("export 'math_utils.dart';"));
        expect(dartCode, contains("export 'string_utils.dart';"));
        expect(dartCode, contains("part 'internal_utils.dart';"));
      });

      test('converts part declarations', () {
        const dpugCode = '''
part of 'utils.dart'

part of my_app.utils
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("part of 'utils.dart';"));
        expect(dartCode, contains('part of my_app.utils;'));
      });
    });

    group('Async/Await Patterns', () {
      test('converts basic async/await', () {
        const dpugCode = r'''
Future<String> fetchData() async
  await Future.delayed(Duration(seconds: 1))
  return 'Data loaded'

Future<void> processData() async
  String data = await fetchData()
  print 'Processing: $data'
  await saveData(data)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Future<String> fetchData() async {'));
        expect(
          dartCode,
          contains('await Future.delayed(Duration(seconds: 1));'),
        );
        expect(dartCode, contains("return 'Data loaded';"));
        expect(dartCode, contains('Future<void> processData() async {'));
        expect(dartCode, contains('String data = await fetchData();'));
        expect(dartCode, contains(r"print('Processing: $data');"));
        expect(dartCode, contains('await saveData(data);'));
      });

      test('converts async with error handling', () {
        const dpugCode = '''
Future<String> fetchWithRetry() async
  int attempts = 0
  while attempts < 3
    try
      return await fetchData()
    catch e
      attempts++
      if attempts == 3
        throw Exception('Failed after 3 attempts')
      await Future.delayed(Duration(seconds: 1))
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Future<String> fetchWithRetry() async {'));
        expect(dartCode, contains('int attempts = 0;'));
        expect(dartCode, contains('while (attempts < 3) {'));
        expect(dartCode, contains('try {'));
        expect(dartCode, contains('return await fetchData();'));
        expect(dartCode, contains('} catch (e) {'));
        expect(dartCode, contains('attempts++;'));
        expect(
          dartCode,
          contains("throw Exception('Failed after 3 attempts');"),
        );
        expect(
          dartCode,
          contains('await Future.delayed(Duration(seconds: 1));'),
        );
      });

      test('converts Future methods', () {
        const dpugCode = r'''
Future<List<String>> fetchAllData() async
  List<Future<String>> futures = []
  for int i in 1..5
    futures.add(fetchData(i.toString()))

  return await Future.wait(futures)

Future<String> fetchData(String id) async
  return 'Data for $id'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('Future<List<String>> fetchAllData() async {'),
        );
        expect(dartCode, contains('List<Future<String>> futures = [];'));
        expect(dartCode, contains('for (int i = 1; i <= 5; i++) {'));
        expect(dartCode, contains('futures.add(fetchData(i.toString()));'));
        expect(dartCode, contains('return await Future.wait(futures);'));
        expect(
          dartCode,
          contains('Future<String> fetchData(String id) async {'),
        );
        expect(dartCode, contains(r"return 'Data for $id';"));
      });

      test('converts Stream operations', () {
        const dpugCode = r'''
Stream<int> countStream() async*
  for int i in 1..10
    await Future.delayed(Duration(seconds: 1))
    yield i

Future<void> processStream() async
  await for int value in countStream()
    print 'Received: $value'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Stream<int> countStream() async* {'));
        expect(dartCode, contains('for (int i = 1; i <= 10; i++) {'));
        expect(
          dartCode,
          contains('await Future.delayed(Duration(seconds: 1));'),
        );
        expect(dartCode, contains('yield i;'));
        expect(dartCode, contains('Future<void> processStream() async {'));
        expect(dartCode, contains('await for (int value in countStream()) {'));
        expect(dartCode, contains(r"print('Received: $value');"));
      });
    });

    group('Error Handling and Exceptions', () {
      test('converts try-catch blocks', () {
        const dpugCode = r'''
void processData(String input)
  try
    int value = int.parse(input)
    print 'Parsed value: $value'
  catch FormatException e
    print 'Invalid number format: $e'
  catch e
    print 'Unknown error: $e'
  finally
    print 'Cleanup completed'

String validateInput(String input)
  if input.isEmpty
    throw ArgumentError('Input cannot be empty')
  if input.length < 3
    throw Exception('Input too short')
  return input.toUpperCase()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('void processData(String input) {'));
        expect(dartCode, contains('try {'));
        expect(dartCode, contains('int value = int.parse(input);'));
        expect(dartCode, contains(r"print('Parsed value: $value');"));
        expect(dartCode, contains('} catch (FormatException e) {'));
        expect(dartCode, contains(r"print('Invalid number format: $e');"));
        expect(dartCode, contains('} catch (e) {'));
        expect(dartCode, contains(r"print('Unknown error: $e');"));
        expect(dartCode, contains('} finally {'));
        expect(dartCode, contains("print('Cleanup completed');"));
        expect(dartCode, contains('String validateInput(String input) {'));
        expect(
          dartCode,
          contains("throw ArgumentError('Input cannot be empty');"),
        );
        expect(dartCode, contains("throw Exception('Input too short');"));
        expect(dartCode, contains('return input.toUpperCase();'));
      });

      test('converts custom exceptions', () {
        const dpugCode = r'''
class CustomException implements Exception
  String message

  CustomException(this.message)

  @override
  String toString() => 'CustomException: $message'

class ValidationError extends CustomException
  String field

  ValidationError(String message, this.field) : super(message)

  String get errorMessage => 'Field $field: $message'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('class CustomException implements Exception {'),
        );
        expect(dartCode, contains('String message;'));
        expect(dartCode, contains('CustomException(this.message);'));
        expect(dartCode, contains('@override'));
        expect(
          dartCode,
          contains(r"String toString() => 'CustomException: $message';"),
        );
        expect(
          dartCode,
          contains('class ValidationError extends CustomException {'),
        );
        expect(dartCode, contains('String field;'));
        expect(
          dartCode,
          contains(
            'ValidationError(String message, this.field) : super(message);',
          ),
        );
        expect(
          dartCode,
          contains(r"String get errorMessage => 'Field $field: $message';"),
        );
      });
    });

    group('Generics and Type Parameters', () {
      test('converts generic classes', () {
        const dpugCode = r'''
class Container<T>
  T value

  Container(this.value)

  T getValue() => value
  void setValue(T newValue) => value = newValue

class Pair<K, V>
  K key
  V value

  Pair(this.key, this.value)

  String toString() => '$key: $value'

class Result<T, E>
  T? data
  E? error
  bool get isSuccess => data != null
  bool get isError => error != null

  Result.success(this.data)
  Result.error(this.error)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Container<T> {'));
        expect(dartCode, contains('T value;'));
        expect(dartCode, contains('Container(this.value);'));
        expect(dartCode, contains('T getValue() => value;'));
        expect(
          dartCode,
          contains('void setValue(T newValue) => value = newValue;'),
        );
        expect(dartCode, contains('class Pair<K, V> {'));
        expect(dartCode, contains('K key;'));
        expect(dartCode, contains('V value;'));
        expect(dartCode, contains('Pair(this.key, this.value);'));
        expect(dartCode, contains(r"String toString() => '$key: $value';"));
        expect(dartCode, contains('class Result<T, E> {'));
        expect(dartCode, contains('T? data;'));
        expect(dartCode, contains('E? error;'));
        expect(dartCode, contains('bool get isSuccess => data != null;'));
        expect(dartCode, contains('bool get isError => error != null;'));
        expect(dartCode, contains('Result.success(this.data);'));
        expect(dartCode, contains('Result.error(this.error);'));
      });

      test('converts generic methods', () {
        const dpugCode = '''
class DataProcessor
  List<T> processItems<T>(List<T> items, T Function(T) processor)
    List<T> result = []
    for T item in items
      result.add(processor(item))
    return result

  Map<K, List<V>> groupBy<K, V>(List<V> items, K Function(V) keyExtractor)
    Map<K, List<V>> groups = {}
    for V item in items
      K key = keyExtractor(item)
      groups[key] ??= []
      groups[key]!.add(item)
    return groups

  T? findFirst<T>(List<T> items, bool Function(T) predicate)
    for T item in items
      if predicate(item)
        return item
    return null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'List<T> processItems<T>(List<T> items, T Function(T) processor) {',
          ),
        );
        expect(dartCode, contains('List<T> result = [];'));
        expect(dartCode, contains('for (T item in items) {'));
        expect(dartCode, contains('result.add(processor(item));'));
        expect(dartCode, contains('return result;'));
        expect(
          dartCode,
          contains(
            'Map<K, List<V>> groupBy<K, V>(List<V> items, K Function(V) keyExtractor) {',
          ),
        );
        expect(dartCode, contains('Map<K, List<V>> groups = {};'));
        expect(dartCode, contains('K key = keyExtractor(item);'));
        expect(dartCode, contains('groups[key] ??= [];'));
        expect(dartCode, contains('groups[key]!.add(item);'));
        expect(
          dartCode,
          contains(
            'T? findFirst<T>(List<T> items, bool Function(T) predicate) {',
          ),
        );
        expect(dartCode, contains('if (predicate(item)) {'));
        expect(dartCode, contains('return item;'));
        expect(dartCode, contains('return null;'));
      });
    });

    group('Function Types and Callbacks', () {
      test('converts function type aliases', () {
        const dpugCode = '''
typedef MathOperation = int Function(int a, int b)
typedef UserCallback = void Function(User user)
typedef AsyncUserFetcher = Future<User> Function(String id)
typedef Predicate<T> = bool Function(T item)
typedef Transformer<T, U> = U Function(T input)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('typedef MathOperation = int Function(int a, int b);'),
        );
        expect(
          dartCode,
          contains('typedef UserCallback = void Function(User user);'),
        );
        expect(
          dartCode,
          contains(
            'typedef AsyncUserFetcher = Future<User> Function(String id);',
          ),
        );
        expect(
          dartCode,
          contains('typedef Predicate<T> = bool Function(T item);'),
        );
        expect(
          dartCode,
          contains('typedef Transformer<T, U> = U Function(T input);'),
        );
      });

      test('converts higher-order functions', () {
        const dpugCode = '''
class FunctionUtils
  List<T> filter<T>(List<T> items, bool Function(T) predicate)
    List<T> result = []
    for T item in items
      if predicate(item)
        result.add(item)
    return result

  List<U> map<T, U>(List<T> items, U Function(T) transform)
    List<U> result = []
    for T item in items
      result.add(transform(item))
    return result

  void forEach<T>(List<T> items, void Function(T) action)
    for T item in items
      action(item)

  T? find<T>(List<T> items, bool Function(T) predicate)
    for T item in items
      if predicate(item)
        return item
    return null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'List<T> filter<T>(List<T> items, bool Function(T) predicate) {',
          ),
        );
        expect(dartCode, contains('if (predicate(item)) {'));
        expect(
          dartCode,
          contains(
            'List<U> map<T, U>(List<T> items, U Function(T) transform) {',
          ),
        );
        expect(dartCode, contains('result.add(transform(item));'));
        expect(
          dartCode,
          contains('void forEach<T>(List<T> items, void Function(T) action) {'),
        );
        expect(dartCode, contains('action(item);'));
        expect(
          dartCode,
          contains('T? find<T>(List<T> items, bool Function(T) predicate) {'),
        );
        expect(dartCode, contains('if (predicate(item)) {'));
        expect(dartCode, contains('return item;'));
      });
    });

    group('Metadata and Annotations', () {
      test('converts basic annotations', () {
        const dpugCode = '''
@deprecated
void oldFunction() => print 'This function is deprecated'

@Deprecated('Use newFunction instead')
void anotherOldFunction() => print 'Also deprecated with message'

@override
void customImplementation() => print 'Overriding parent method'

@visibleForTesting
String internalHelper() => 'Internal helper'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@deprecated'));
        expect(
          dartCode,
          contains(
            "void oldFunction() => print('This function is deprecated');",
          ),
        );
        expect(dartCode, contains("@Deprecated('Use newFunction instead')"));
        expect(
          dartCode,
          contains(
            "void anotherOldFunction() => print('Also deprecated with message');",
          ),
        );
        expect(dartCode, contains('@override'));
        expect(
          dartCode,
          contains(
            "void customImplementation() => print('Overriding parent method');",
          ),
        );
        expect(dartCode, contains('@visibleForTesting'));
        expect(
          dartCode,
          contains("String internalHelper() => 'Internal helper';"),
        );
      });

      test('converts complex annotations', () {
        const dpugCode = r'''
@JsonSerializable()
class Product
  @JsonKey(name: 'product_id')
  String id

  @JsonKey(defaultValue: 'Unknown')
  String name

  @JsonKey(ignore: true)
  String password

  Product(this.id, this.name, this.password)

  @JsonKey(ignore: true)
  @observable bool isLoading = false

  factory Product.fromJson(Map<String, dynamic> json) =>
    _$ProductFromJson(json)

  Map<String, dynamic> toJson() => _$ProductToJson(this)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@JsonSerializable()'));
        expect(dartCode, contains('class Product {'));
        expect(dartCode, contains("@JsonKey(name: 'product_id')"));
        expect(dartCode, contains('String id;'));
        expect(dartCode, contains("@JsonKey(defaultValue: 'Unknown')"));
        expect(dartCode, contains('String name;'));
        expect(dartCode, contains('@JsonKey(ignore: true)'));
        expect(dartCode, contains('String password;'));
        expect(
          dartCode,
          contains('Product(this.id, this.name, this.password);'),
        );
        expect(dartCode, contains('@JsonKey(ignore: true)'));
        expect(dartCode, contains('@observable'));
        expect(dartCode, contains('bool isLoading = false;'));
        expect(
          dartCode,
          contains('factory Product.fromJson(Map<String, dynamic> json) =>'),
        );
        expect(dartCode, contains(r'_$ProductFromJson(json);'));
        expect(
          dartCode,
          contains(r'Map<String, dynamic> toJson() => _$ProductToJson(this);'),
        );
      });
    });

    group('Round-trip Advanced Features', () {
      test('advanced features maintain semantics through round-trip', () {
        const dpugCode = r'''
import 'package:flutter/material.dart'

@JsonSerializable()
class AdvancedClass<T>
  @JsonKey(name: 'id')
  String id

  T data

  AdvancedClass(this.id, this.data)

  @JsonKey(ignore: true)
  Future<void> asyncMethod() async
    await Future.delayed(Duration(seconds: 1))
    print 'Async operation completed'

  @override
  String toString() => 'AdvancedClass(id: $id, data: $data)'

  factory AdvancedClass.fromJson(Map<String, dynamic> json) =>
    AdvancedClass(json['id'], json['data'])
''';

        final dartCode = converter.dpugToDart(dpugCode);
        final backToDpug = converter.dartToDpug(dartCode);

        // Should contain the key elements
        expect(backToDpug, contains("import 'package:flutter/material.dart'"));
        expect(backToDpug, contains('@JsonSerializable()'));
        expect(backToDpug, contains('class AdvancedClass<T>'));
        expect(backToDpug, contains("@JsonKey(name: 'id')"));
        expect(backToDpug, contains('String id;'));
        expect(backToDpug, contains('T data;'));
        expect(backToDpug, contains('AdvancedClass(this.id, this.data);'));
        expect(backToDpug, contains('Future<void> asyncMethod() async'));
        expect(backToDpug, contains('await Future.delayed'));
        expect(backToDpug, contains('@override'));
        expect(
          backToDpug,
          contains(
            r"String toString() => 'AdvancedClass(id: $id, data: $data)'",
          ),
        );
        expect(backToDpug, contains('factory AdvancedClass.fromJson'));
      });
    });
  });
}
