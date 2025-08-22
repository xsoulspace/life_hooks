// DPug Language Specification: Advanced Features

This document covers advanced DPug features including imports, exports, class composition, and language-specific constructs.

## Imports and Exports

```dpug
// Core Dart imports
import 'dart:math'
import 'dart:convert'
import 'dart:io'

// Package imports
import 'package:flutter/material.dart'
import 'package:provider/provider.dart'

// Relative imports
import '../models/user.dart'
import 'utils/helpers.dart'

// Import with alias
import 'package:http/http.dart' as http

// Import specific members
import 'math_utils.dart' show add, multiply, pi
import 'string_utils.dart' hide trim, padLeft

// Deferred imports
import 'heavy_library.dart' deferred as heavy

// Usage of deferred import
Future<void> loadLibrary() async
  await heavy.loadLibrary()
  heavy.doSomething()
```

## Exports

```dpug
// Re-export all from a library
export 'user_model.dart'
export 'user_service.dart'

// Re-export specific members
export 'math_utils.dart' show Math, Calculator
export 'string_utils.dart' hide internalFunction

// Export with alias (not directly supported, use wrapper)
export 'external_lib.dart'
```

## Library Structure

```dpug
// File: lib/models/user.dart
class User
  String id
  String name
  String email

  User(this.id, this.name, this.email)

// File: lib/services/user_service.dart
import '../models/user.dart'

class UserService
  List<User> getUsers() => [
    User('1', 'Alice', 'alice@example.com'),
    User('2', 'Bob', 'bob@example.com')
  ]

// File: lib/main.dart
import 'models/user.dart'
import 'services/user_service.dart'

void main()
  UserService service = UserService()
  List<User> users = service.getUsers()
  print users
```

## Class Composition and Instances

```dpug
class DatabaseConfig
  String host
  int port
  String database
  String username
  String password

  DatabaseConfig(this.host, this.port, this.database, this.username, this.password)

class DatabaseService
  DatabaseConfig config
  bool _connected = false

  DatabaseService(this.config)

  Future<void> connect() async
    print 'Connecting to ${config.host}:${config.port}/${config.database}'
    _connected = true

  Future<void> disconnect() async
    print 'Disconnecting...'
    _connected = false

  bool get isConnected => _connected

// Usage with composition
class AppService
  DatabaseService database
  UserService userService

  AppService(DatabaseConfig config)
    database = DatabaseService(config)
    userService = UserService(database)

  Future<void> initialize() async
    await database.connect()
    print 'App initialized'
```

## Factory Constructors with Complex Logic

```dpug
class ConnectionPool
  List<Connection> _connections = []
  int maxConnections

  ConnectionPool._(this.maxConnections)

  factory ConnectionPool.create({int maxConnections = 10})
    if maxConnections <= 0
      throw ArgumentError('maxConnections must be positive')
    return ConnectionPool._(maxConnections)

  factory ConnectionPool.fromConfig(Map<String, dynamic> config)
    int max = config['maxConnections'] ?? 10
    ConnectionPool pool = ConnectionPool.create(maxConnections: max)
    pool._initializeFromConfig(config)
    return pool

  void _initializeFromConfig(Map<String, dynamic> config)
    // Initialize connections based on config
    print 'Initialized with config: $config'
```

## Singleton Pattern

```dpug
class AppConfig
  static AppConfig? _instance
  Map<String, dynamic> _settings = {}

  AppConfig._()

  factory AppConfig()
    _instance ??= AppConfig._()
    return _instance!

  static AppConfig get instance => AppConfig()

  dynamic get(String key) => _settings[key]
  void set(String key, dynamic value) => _settings[key] = value

// Usage
AppConfig config = AppConfig.instance
config.set('apiUrl', 'https://api.example.com')
String url = config.get('apiUrl')
```

## Method Cascades and Fluent Interfaces

```dpug
class QueryBuilder
  String table
  List<String> _wheres = []
  List<String> _selects = []
  int? _limit

  QueryBuilder(this.table)

  QueryBuilder select(List<String> columns)
    _selects = columns
    return this

  QueryBuilder where(String condition)
    _wheres.add(condition)
    return this

  QueryBuilder limit(int count)
    _limit = count
    return this

  String build()
    String query = 'SELECT ${_selects.join(', ')} FROM $table'
    if _wheres.isNotEmpty
      query += ' WHERE ${_wheres.join(' AND ')}'
    if _limit != null
      query += ' LIMIT $_limit'
    return query

// Usage with method cascades
String query = QueryBuilder('users')
  ..select(['id', 'name', 'email'])
  ..where('active = 1')
  ..where('age > 18')
  ..limit(100)
  .build()
```

## Async/Await Patterns

```dpug
class ApiService
  Future<User> fetchUser(String id) async
    await Future.delayed(Duration(seconds: 1))
    return User(id, 'User $id', 'user$id@example.com')

  Future<List<User>> fetchUsers() async
    List<Future<User>> futures = []
    for int i in 1..5
      futures.add(fetchUser(i.toString()))

    return await Future.wait(futures)

# Usage with async/await
Future<void> main() async
  ApiService api = ApiService()

  // Single user
  User user = await api.fetchUser('1')
  print 'Fetched: $user'

  // Multiple users
  List<User> users = await api.fetchUsers()
  print 'Fetched ${users.length} users'

# Usage with then/catchError
api.fetchUser('1')
  .then((user) => print 'User: $user')
  .catchError((error) => print 'Error: $error')
```

## Error Handling and Exceptions

```dpug
class CustomException implements Exception
  String message
  CustomException(this.message)

  @override
  String toString() => 'CustomException: $message'

class DataProcessor
  void process(String data) throws CustomException
    if data.isEmpty
      throw CustomException('Data cannot be empty')

    if !data.contains('@')
      throw FormatException('Invalid data format')

    print 'Processing: $data'

# Usage with try/catch
try
  DataProcessor processor = DataProcessor()
  processor.process('')
catch CustomException e
  print 'Custom error: $e'
catch FormatException e
  print 'Format error: $e'
catch e
  print 'Unknown error: $e'
finally
  print 'Cleanup completed'
```

## Metadata and Annotations

```dpug
@deprecated
@Deprecated('Use newMethod instead')
void oldMethod() => print 'Old method'

@JsonSerializable()
class Product
  @JsonKey(name: 'product_id')
  String id

  @JsonKey(defaultValue: 'Unknown')
  String name

  Product(this.id, this.name)

  factory Product.fromJson(Map<String, dynamic> json) =>
    _$ProductFromJson(json)

  Map<String, dynamic> toJson() => _$ProductToJson(this)
```

## Type Aliases and Function Types

```dpug
// Type aliases
typedef JsonMap = Map<String, dynamic>
typedef UserId = String
typedef UserCallback = void Function(User user)

// Function type aliases
typedef MathOperation = int Function(int a, int b)
typedef AsyncUserFetcher = Future<User> Function(String id)

class Calculator
  MathOperation operation

  Calculator(this.operation)

  int calculate(int a, int b) => operation(a, b)

// Usage
MathOperation add = (a, b) => a + b
Calculator calc = Calculator(add)
int result = calc.calculate(5, 3)  // 8
```

## Libraries and Parts

```dpug
// File: lib/utils/math_utils.dart
part of 'utils.dart'

double calculateArea(double radius) => pi * radius * radius

// File: lib/utils/string_utils.dart
part of 'utils.dart'

String capitalize(String text) =>
  '${text[0].toUpperCase()}${text.substring(1)}'

// File: lib/utils.dart
library utils

part 'math_utils.dart'
part 'string_utils.dart'

// Usage
import 'utils.dart'

double area = calculateArea(5.0)
String title = capitalize('hello world')
```
