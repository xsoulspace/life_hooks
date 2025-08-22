import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Classes and Inheritance Conversion', () {
    final converter = DpugConverter();

    group('Basic Classes', () {
      test('converts simple class with fields and methods', () {
        const dpugCode = r'''
class Person
  String name
  int age

  Person(this.name, this.age)

  void greet() =>
    print 'Hello, I am $name, age $age'

  String toString() =>
    'Person(name: $name, age: $age)'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Person {'));
        expect(dartCode, contains('String name;'));
        expect(dartCode, contains('int age;'));
        expect(dartCode, contains('Person(this.name, this.age);'));
        expect(
          dartCode,
          contains(r"void greet() => print('Hello, I am $name, age $age');"),
        );
        expect(
          dartCode,
          contains(r"String toString() => 'Person(name: $name, age: $age)';"),
        );
      });

      test('converts class with getters and setters', () {
        const dpugCode = '''
class Calculator
  double _value = 0

  double get value => _value

  set value(double newValue) => _value = newValue

  void add(double n) => _value += n
  void subtract(double n) => _value -= n
  void multiply(double n) => _value *= n
  void divide(double n) => _value /= n

  void clear() => _value = 0

  double calculateComplex(double a, double b)
    double result = a * 2
    result += b / 3
    return result
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Calculator {'));
        expect(dartCode, contains('double _value = 0;'));
        expect(dartCode, contains('double get value => _value;'));
        expect(
          dartCode,
          contains('set value(double newValue) => _value = newValue;'),
        );
        expect(dartCode, contains('void add(double n) => _value += n;'));
        expect(dartCode, contains('void subtract(double n) => _value -= n;'));
        expect(dartCode, contains('void multiply(double n) => _value *= n;'));
        expect(dartCode, contains('void divide(double n) => _value /= n;'));
        expect(dartCode, contains('void clear() => _value = 0;'));
        expect(
          dartCode,
          contains('double calculateComplex(double a, double b) {'),
        );
        expect(dartCode, contains('double result = a * 2;'));
        expect(dartCode, contains('result += b / 3;'));
        expect(dartCode, contains('return result;'));
        expect(dartCode, contains('}'));
      });
    });

    group('Constructors', () {
      test('converts named constructors', () {
        const dpugCode = '''
class User
  String name
  String email
  int? age

  User(this.name, this.email, [this.age])

  User.guest()
    name = 'Guest'
    email = 'guest@example.com'

  User.fromJson(Map<String, dynamic> json)
    name = json['name']
    email = json['email']
    age = json['age']

  factory User.admin() =>
    User('Admin', 'admin@system.com')

  factory User.fromConfig(Map<String, dynamic> config)
    String name = config['name'] ?? 'Default'
    String email = config['email'] ?? 'default@example.com'
    return User(name, email)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class User {'));
        expect(dartCode, contains('String name;'));
        expect(dartCode, contains('String email;'));
        expect(dartCode, contains('int? age;'));
        expect(dartCode, contains('User(this.name, this.email, [this.age]);'));
        expect(dartCode, contains('User.guest() {'));
        expect(dartCode, contains("name = 'Guest';"));
        expect(dartCode, contains("email = 'guest@example.com';"));
        expect(dartCode, contains('}'));
        expect(
          dartCode,
          contains('User.fromJson(Map<String, dynamic> json) {'),
        );
        expect(dartCode, contains("name = json['name'];"));
        expect(dartCode, contains("email = json['email'];"));
        expect(dartCode, contains("age = json['age'];"));
        expect(dartCode, contains('}'));
        expect(
          dartCode,
          contains(
            "factory User.admin() => User('Admin', 'admin@system.com');",
          ),
        );
        expect(
          dartCode,
          contains('factory User.fromConfig(Map<String, dynamic> config) {'),
        );
        expect(
          dartCode,
          contains("String name = config['name'] ?? 'Default';"),
        );
        expect(
          dartCode,
          contains("String email = config['email'] ?? 'default@example.com';"),
        );
        expect(dartCode, contains('return User(name, email);'));
        expect(dartCode, contains('}'));
      });
    });

    group('Static Members', () {
      test('converts static fields and methods', () {
        const dpugCode = '''
class MathUtils
  static const double pi = 3.14159
  static const double e = 2.71828

  static double square(double x) => x * x
  static double cube(double x) => x * x * x

  static double get randomValue => math.Random().nextDouble()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class MathUtils {'));
        expect(dartCode, contains('static const double pi = 3.14159;'));
        expect(dartCode, contains('static const double e = 2.71828;'));
        expect(dartCode, contains('static double square(double x) => x * x;'));
        expect(
          dartCode,
          contains('static double cube(double x) => x * x * x;'),
        );
        expect(
          dartCode,
          contains(
            'static double get randomValue => math.Random().nextDouble();',
          ),
        );
      });
    });

    group('Inheritance', () {
      test('converts basic inheritance', () {
        const dpugCode = r'''
class Animal
  String name

  Animal(this.name)

  void makeSound() => print 'Some sound'

class Dog extends Animal
  String breed

  Dog(String name, this.breed) : super(name)

  @override
  void makeSound() => print 'Woof!'

  void fetch() => print '$name is fetching!'

class Cat extends Animal
  Cat(String name) : super(name)

  @override
  void makeSound() => print 'Meow!'

  void scratch() => print '$name is scratching!'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Animal {'));
        expect(dartCode, contains('String name;'));
        expect(dartCode, contains('Animal(this.name);'));
        expect(dartCode, contains("void makeSound() => print('Some sound');"));
        expect(dartCode, contains('class Dog extends Animal {'));
        expect(dartCode, contains('String breed;'));
        expect(
          dartCode,
          contains('Dog(String name, this.breed) : super(name);'),
        );
        expect(dartCode, contains('@override'));
        expect(dartCode, contains("void makeSound() => print('Woof!');"));
        expect(
          dartCode,
          contains(r"void fetch() => print('$name is fetching!');"),
        );
        expect(dartCode, contains('class Cat extends Animal {'));
        expect(dartCode, contains('Cat(String name) : super(name);'));
        expect(dartCode, contains('@override'));
        expect(dartCode, contains("void makeSound() => print('Meow!');"));
        expect(
          dartCode,
          contains(r"void scratch() => print('$name is scratching!');"),
        );
      });
    });

    group('Abstract Classes and Interfaces', () {
      test('converts abstract classes', () {
        const dpugCode = '''
abstract class Shape
  double get area
  double get perimeter

  void draw() => print 'Drawing shape'

class Circle extends Shape
  double radius

  Circle(this.radius)

  @override
  double get area => pi * radius * radius

  @override
  double get perimeter => 2 * pi * radius

class Rectangle extends Shape
  double width
  double height

  Rectangle(this.width, this.height)

  @override
  double get area => width * height

  @override
  double get perimeter => 2 * (width + height)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('abstract class Shape {'));
        expect(dartCode, contains('double get area;'));
        expect(dartCode, contains('double get perimeter;'));
        expect(dartCode, contains("void draw() => print('Drawing shape');"));
        expect(dartCode, contains('class Circle extends Shape {'));
        expect(dartCode, contains('double radius;'));
        expect(dartCode, contains('Circle(this.radius);'));
        expect(dartCode, contains('@override'));
        expect(dartCode, contains('double get area => pi * radius * radius;'));
        expect(dartCode, contains('double get perimeter => 2 * pi * radius;'));
        expect(dartCode, contains('class Rectangle extends Shape {'));
        expect(dartCode, contains('double width;'));
        expect(dartCode, contains('double height;'));
        expect(dartCode, contains('Rectangle(this.width, this.height);'));
        expect(dartCode, contains('double get area => width * height;'));
        expect(
          dartCode,
          contains('double get perimeter => 2 * (width + height);'),
        );
      });
    });

    group('Mixins', () {
      test('converts mixin classes', () {
        const dpugCode = r'''
mixin Logger
  void log(String message) => print '[LOG] $message'

mixin Serializable
  Map<String, dynamic> toJson()
  static T fromJson<T>(Map<String, dynamic> json) => throw UnimplementedError()

class User with Logger, Serializable
  String name
  String email

  User(this.name, this.email)

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email
  }

  void save()
    log 'Saving user: $name'
    // Save to database
    log 'User saved successfully'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('mixin Logger {'));
        expect(
          dartCode,
          contains(r"void log(String message) => print('[LOG] $message');"),
        );
        expect(dartCode, contains('mixin Serializable {'));
        expect(dartCode, contains('Map<String, dynamic> toJson();'));
        expect(
          dartCode,
          contains(
            'static T fromJson<T>(Map<String, dynamic> json) => throw UnimplementedError();',
          ),
        );
        expect(dartCode, contains('class User with Logger, Serializable {'));
        expect(dartCode, contains('String name;'));
        expect(dartCode, contains('String email;'));
        expect(dartCode, contains('User(this.name, this.email);'));
        expect(dartCode, contains('@override'));
        expect(
          dartCode,
          contains(
            "Map<String, dynamic> toJson() => {'name': name, 'email': email};",
          ),
        );
        expect(dartCode, contains('void save() {'));
        expect(dartCode, contains(r"log('Saving user: $name');"));
        expect(dartCode, contains("log('User saved successfully');"));
        expect(dartCode, contains('}'));
      });
    });

    group('Enums', () {
      test('converts basic enums', () {
        const dpugCode = '''
enum Status
  pending,
  active,
  inactive,
  deleted

enum Priority
  low(1),
  medium(2),
  high(3)

  final int value

  const Priority(this.value)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('enum Status {'));
        expect(dartCode, contains('pending,'));
        expect(dartCode, contains('active,'));
        expect(dartCode, contains('inactive,'));
        expect(dartCode, contains('deleted'));
        expect(dartCode, contains('}'));
        expect(dartCode, contains('enum Priority {'));
        expect(dartCode, contains('low(1),'));
        expect(dartCode, contains('medium(2),'));
        expect(dartCode, contains('high(3)'));
        expect(dartCode, contains('final int value;'));
        expect(dartCode, contains('const Priority(this.value);'));
        expect(dartCode, contains('}'));
      });
    });

    group('Generics', () {
      test('converts generic classes', () {
        const dpugCode = '''
class Stack<T>
  List<T> _items = []

  void push(T item) => _items.add(item)
  T pop() => _items.removeLast()
  T peek() => _items.last
  bool get isEmpty => _items.isEmpty
  int get length => _items.length

class Pair<T, U>
  T first
  U second

  Pair(this.first, this.second)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Stack<T> {'));
        expect(dartCode, contains('List<T> _items = [];'));
        expect(dartCode, contains('void push(T item) => _items.add(item);'));
        expect(dartCode, contains('T pop() => _items.removeLast();'));
        expect(dartCode, contains('T peek() => _items.last;'));
        expect(dartCode, contains('bool get isEmpty => _items.isEmpty;'));
        expect(dartCode, contains('int get length => _items.length;'));
        expect(dartCode, contains('class Pair<T, U> {'));
        expect(dartCode, contains('T first;'));
        expect(dartCode, contains('U second;'));
        expect(dartCode, contains('Pair(this.first, this.second);'));
      });
    });

    group('Extension Methods', () {
      test('converts extension methods', () {
        const dpugCode = r'''
extension StringExtensions on String
  bool get isEmail => contains('@') && contains('.')
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}'
  String get reversed => split('').reversed.join()

extension NumberFormatting on num
  String toCurrency() => '$${toStringAsFixed(2)}'
  String toPercentage() => '${(this * 100).toFixed(1)}%'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('extension StringExtensions on String {'));
        expect(
          dartCode,
          contains("bool get isEmail => contains('@') && contains('.');"),
        );
        expect(
          dartCode,
          contains(
            r"String capitalize() => '${this[0].toUpperCase()}${substring(1)}';",
          ),
        );
        expect(
          dartCode,
          contains("String get reversed => split('').reversed.join();"),
        );
        expect(dartCode, contains('extension NumberFormatting on num {'));
        expect(
          dartCode,
          contains(r"String toCurrency() => '$${toStringAsFixed(2)}';"),
        );
        expect(
          dartCode,
          contains(r"String toPercentage() => '${(this * 100).toFixed(1)}%';"),
        );
      });
    });

    group('Operator Overloading', () {
      test('converts operator overloading', () {
        const dpugCode = r'''
class Vector
  double x, y

  Vector(this.x, this.y)

  Vector operator +(Vector other) => Vector(x + other.x, y + other.y)
  Vector operator -(Vector other) => Vector(x - other.x, y - other.y)
  Vector operator *(double scalar) => Vector(x * scalar, y * scalar)

  @override
  String toString() => '($x, $y)'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Vector {'));
        expect(dartCode, contains('double x, y;'));
        expect(dartCode, contains('Vector(this.x, this.y);'));
        expect(
          dartCode,
          contains(
            'Vector operator +(Vector other) => Vector(x + other.x, y + other.y);',
          ),
        );
        expect(
          dartCode,
          contains(
            'Vector operator -(Vector other) => Vector(x - other.x, y - other.y);',
          ),
        );
        expect(
          dartCode,
          contains(
            'Vector operator *(double scalar) => Vector(x * scalar, y * scalar);',
          ),
        );
        expect(dartCode, contains('@override'));
        expect(dartCode, contains(r"String toString() => '($x, $y)';"));
      });
    });

    group('Round-trip Class Conversion', () {
      test('classes maintain semantics through round-trip', () {
        const dpugCode = r'''
class User
  String name
  int age

  User(this.name, this.age)

  void greet() => print 'Hello, $name!'

  String toString() => 'User(name: $name, age: $age)'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        final backToDpug = converter.dartToDpug(dartCode);

        // Should contain the key elements
        expect(backToDpug, contains('class User'));
        expect(backToDpug, contains('String name;'));
        expect(backToDpug, contains('int age;'));
        expect(backToDpug, contains('User(this.name, this.age);'));
        expect(
          backToDpug,
          contains(r"void greet() => print('Hello, $name!');"),
        );
        expect(
          backToDpug,
          contains(r"String toString() => 'User(name: $name, age: $age)';"),
        );
      });
    });

    group('Class Edge Cases and Error Conditions', () {
      test('handles very large classes with many members', () {
        final manyFields = List.generate(
          100,
          (final i) => 'field$i',
        ).join('\n  int ');
        final manyMethods = List.generate(
          50,
          (final i) => 'void method$i() => print "Method $i"',
        ).join('\n\n  ');

        final dpugCode =
            '''
class LargeClass
  int $manyFields

  LargeClass()

  $manyMethods
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class LargeClass'));
        expect(dartCode, contains('int field0;'));
        expect(dartCode, contains('int field99;'));
        expect(dartCode, contains('void method0() => print("Method 0");'));
        expect(dartCode, contains('void method49() => print("Method 49");'));
      });

      test('handles deeply nested class hierarchies', () {
        const dpugCode = '''
class A
  String value

  A(this.value)

class B extends A
  int number

  B(String value, this.number) : super(value)

class C extends B
  double rate

  C(String value, int number, this.rate) : super(value, number)

class D extends C
  bool flag

  D(String value, int number, double rate, this.flag) : super(value, number, rate)

class E extends D
  List<String> items

  E(String value, int number, double rate, bool flag, this.items) : super(value, number, rate, flag)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class A'));
        expect(dartCode, contains('class B extends A'));
        expect(dartCode, contains('class C extends B'));
        expect(dartCode, contains('class D extends C'));
        expect(dartCode, contains('class E extends D'));
        expect(dartCode, contains('super(value)'));
        expect(dartCode, contains('super(value, number)'));
        expect(dartCode, contains('super(value, number, rate)'));
        expect(dartCode, contains('super(value, number, rate, flag)'));
      });

      test('handles classes with complex generic type parameters', () {
        const dpugCode = '''
class Container<T>
  T value

  Container(this.value)

class Pair<T, U>
  T first
  U second

  Pair(this.first, this.second)

class Triple<A, B, C>
  A item1
  B item2
  C item3

  Triple(this.item1, this.item2, this.item3)

class ComplexGeneric<T extends num, U, V extends List<U>>
  T number
  U data
  V list

  ComplexGeneric(this.number, this.data, this.list)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Container<T>'));
        expect(dartCode, contains('class Pair<T, U>'));
        expect(dartCode, contains('class Triple<A, B, C>'));
        expect(
          dartCode,
          contains('class ComplexGeneric<T extends num, U, V extends List<U>>'),
        );
        expect(dartCode, contains('T value;'));
        expect(dartCode, contains('T first;'));
        expect(dartCode, contains('U second;'));
        expect(dartCode, contains('A item1;'));
        expect(dartCode, contains('B item2;'));
        expect(dartCode, contains('C item3;'));
        expect(dartCode, contains('T number;'));
        expect(dartCode, contains('U data;'));
        expect(dartCode, contains('V list;'));
      });

      test('handles classes with private members and name conflicts', () {
        const dpugCode = '''
class TestClass
  String _privateField = 'secret'
  int publicField = 42

  String get _privateGetter => _privateField.toUpperCase()
  String get publicGetter => publicField.toString()

  set _privateSetter(String value) => _privateField = value
  set publicSetter(int value) => publicField = value

  void _privateMethod() => print 'Private method'
  void publicMethod() => print 'Public method'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class TestClass'));
        expect(dartCode, contains("String _privateField = 'secret';"));
        expect(dartCode, contains('int publicField = 42;'));
        expect(
          dartCode,
          contains('String get _privateGetter => _privateField.toUpperCase();'),
        );
        expect(
          dartCode,
          contains('String get publicGetter => publicField.toString();'),
        );
        expect(
          dartCode,
          contains(
            'set _privateSetter(String value) => _privateField = value;',
          ),
        );
        expect(
          dartCode,
          contains('set publicSetter(int value) => publicField = value;'),
        );
        expect(
          dartCode,
          contains("void _privateMethod() => print('Private method');"),
        );
        expect(
          dartCode,
          contains("void publicMethod() => print('Public method');"),
        );
      });

      test('handles classes with covariant and contravariant generics', () {
        const dpugCode = '''
class Producer<out T>
  T produce()

class Consumer<in T>
  void consume(T value)

class ProducerConsumer<in T, out U>
  void consume(T input)
  U produce()
''';

        // These might not be directly supported but should handle gracefully
        expect(() => converter.dpugToDart(dpugCode), returnsNormally);
      });

      test('handles classes with complex method signatures', () {
        const dpugCode =
            '''
class ComplexMethods
  void simple() => print 'Simple'

  int add(int a, int b) => a + b

  String? optionalReturn() => null

  List<int> complexReturn(List<String> input, Map<String, dynamic> config)
    List<int> result = []
    for String item in input
      int? value = config[item] as? int
      if value != null
        result.add(value)
    return result

  T genericMethod<T>(T value) => value

  T genericMethodWithBound<T extends num>(T value) => value

  void methodWithFunctionParam(void Function(int) callback)
    callback(42)

  void Function(String) methodReturningFunction()
    return (String s) => print 'Hello $s'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ComplexMethods'));
        expect(dartCode, contains("void simple() => print('Simple');"));
        expect(dartCode, contains('int add(int a, int b) => a + b;'));
        expect(dartCode, contains('String? optionalReturn() => null;'));
        expect(
          dartCode,
          contains(
            'List<int> complexReturn(List<String> input, Map<String, dynamic> config) {',
          ),
        );
        expect(dartCode, contains('T genericMethod<T>(T value) => value;'));
        expect(
          dartCode,
          contains(
            'T genericMethodWithBound<T extends num>(T value) => value;',
          ),
        );
        expect(
          dartCode,
          contains(
            'void methodWithFunctionParam(void Function(int) callback) {',
          ),
        );
        expect(
          dartCode,
          contains('void Function(String) methodReturningFunction() {'),
        );
      });

      test('handles classes with factory constructors and redirects', () {
        const dpugCode = '''
class DatabaseConnection
  String host
  int port
  String database

  DatabaseConnection._(this.host, this.port, this.database)

  factory DatabaseConnection.localhost()
    return DatabaseConnection._('localhost', 5432, 'mydb')

  factory DatabaseConnection.remote(String host, int port, String db)
    return DatabaseConnection._(host, port, db)

  factory DatabaseConnection.fromUrl(String url)
    // Parse URL and create connection
    return DatabaseConnection._('parsed-host', 5432, 'parsed-db')

  DatabaseConnection.redirect() : this._('redirect-host', 5432, 'redirect-db')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class DatabaseConnection'));
        expect(
          dartCode,
          contains(
            'DatabaseConnection._(this.host, this.port, this.database);',
          ),
        );
        expect(dartCode, contains('factory DatabaseConnection.localhost() =>'));
        expect(
          dartCode,
          contains("DatabaseConnection._('localhost', 5432, 'mydb');"),
        );
        expect(
          dartCode,
          contains(
            'factory DatabaseConnection.remote(String host, int port, String db) =>',
          ),
        );
        expect(dartCode, contains('DatabaseConnection._(host, port, db);'));
        expect(
          dartCode,
          contains('factory DatabaseConnection.fromUrl(String url) {'),
        );
        expect(
          dartCode,
          contains("DatabaseConnection._('parsed-host', 5432, 'parsed-db');"),
        );
        expect(
          dartCode,
          contains(
            "DatabaseConnection.redirect() : this._('redirect-host', 5432, 'redirect-db');",
          ),
        );
      });

      test('handles classes with operator overloading', () {
        const dpugCode =
            '''
class Vector2D
  double x, y

  Vector2D(this.x, this.y)

  Vector2D operator +(Vector2D other) => Vector2D(x + other.x, y + other.y)
  Vector2D operator -(Vector2D other) => Vector2D(x - other.x, y - other.y)
  Vector2D operator *(double scalar) => Vector2D(x * scalar, y * scalar)
  Vector2D operator /(double scalar) => Vector2D(x / scalar, y / scalar)

  bool operator ==(Object other)
    if other is Vector2D
      return x == other.x && y == other.y
    return false

  int get hashCode => x.hashCode ^ y.hashCode

  @override
  String toString() => 'Vector2D($x, $y)'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Vector2D'));
        expect(dartCode, contains('double x, y;'));
        expect(dartCode, contains('Vector2D(this.x, this.y);'));
        expect(
          dartCode,
          contains(
            'Vector2D operator +(Vector2D other) => Vector2D(x + other.x, y + other.y);',
          ),
        );
        expect(
          dartCode,
          contains(
            'Vector2D operator -(Vector2D other) => Vector2D(x - other.x, y - other.y);',
          ),
        );
        expect(
          dartCode,
          contains(
            'Vector2D operator *(double scalar) => Vector2D(x * scalar, y * scalar);',
          ),
        );
        expect(
          dartCode,
          contains(
            'Vector2D operator /(double scalar) => Vector2D(x / scalar, y / scalar);',
          ),
        );
        expect(dartCode, contains('bool operator ==(Object other) {'));
        expect(dartCode, contains('if (other is Vector2D) {'));
        expect(dartCode, contains('return x == other.x && y == other.y;'));
        expect(
          dartCode,
          contains('int get hashCode => x.hashCode ^ y.hashCode;'),
        );
        expect(dartCode, contains('@override'));
        expect(dartCode, contains(r"String toString() => 'Vector2D($x, $y)';"));
      });

      test('handles classes with async and generator methods', () {
        const dpugCode = '''
class AsyncMethods
  Future<int> asyncMethod() async
    await Future.delayed(Duration(seconds: 1))
    return 42

  Stream<int> numberStream() async*
    for int i = 0; i < 10; i++
      yield i
      await Future.delayed(Duration(milliseconds: 100))

  Future<void> asyncVoidMethod() async
    await Future.delayed(Duration(seconds: 1))
    print 'Async void completed'

  Stream<String> stringStream() async*
    List<String> words = ['hello', 'world', 'async', 'generators']
    for String word in words
      yield word
      await Future.delayed(Duration(milliseconds: 200))
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class AsyncMethods'));
        expect(dartCode, contains('Future<int> asyncMethod() async {'));
        expect(
          dartCode,
          contains('await Future.delayed(Duration(seconds: 1));'),
        );
        expect(dartCode, contains('return 42;'));
        expect(dartCode, contains('Stream<int> numberStream() async* {'));
        expect(dartCode, contains('for (int i = 0; i < 10; i++) {'));
        expect(dartCode, contains('yield i;'));
        expect(
          dartCode,
          contains('await Future.delayed(Duration(milliseconds: 100));'),
        );
        expect(dartCode, contains('Future<void> asyncVoidMethod() async {'));
        expect(dartCode, contains("print('Async void completed');"));
        expect(dartCode, contains('Stream<String> stringStream() async* {'));
        expect(
          dartCode,
          contains(
            "List<String> words = ['hello', 'world', 'async', 'generators'];",
          ),
        );
        expect(dartCode, contains('for (String word in words) {'));
        expect(dartCode, contains('yield word;'));
        expect(
          dartCode,
          contains('await Future.delayed(Duration(milliseconds: 200));'),
        );
      });

      test('handles classes with complex inheritance and method overrides', () {
        const dpugCode =
            '''
class Base
  String name

  Base(this.name)

  void greet() => print 'Hello from Base'
  String get description => 'Base class'

class Derived1 extends Base
  int value

  Derived1(String name, this.value) : super(name)

  @override
  void greet() => print 'Hello from Derived1'
  @override
  String get description => 'Derived1 class with value $value'

class Derived2 extends Base
  bool flag

  Derived2(String name, this.flag) : super(name)

  @override
  void greet() => print 'Hello from Derived2'
  @override
  String get description => 'Derived2 class with flag $flag'

class MultiDerived extends Derived1
  double rate

  MultiDerived(String name, int value, this.rate) : super(name, value)

  @override
  void greet() => print 'Hello from MultiDerived'
  @override
  String get description => 'MultiDerived with value $value and rate $rate'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Base'));
        expect(dartCode, contains('class Derived1 extends Base'));
        expect(dartCode, contains('class Derived2 extends Base'));
        expect(dartCode, contains('class MultiDerived extends Derived1'));
        expect(dartCode, contains('super(name)'));
        expect(dartCode, contains('super(name, value)'));
        expect(dartCode, contains('@override'));
        expect(dartCode, contains("void greet() => print('Hello from Base');"));
        expect(
          dartCode,
          contains("void greet() => print('Hello from Derived1');"),
        );
        expect(
          dartCode,
          contains("void greet() => print('Hello from Derived2');"),
        );
        expect(
          dartCode,
          contains("void greet() => print('Hello from MultiDerived');"),
        );
        expect(dartCode, contains("String get description => 'Base class';"));
        expect(
          dartCode,
          contains(
            r"String get description => 'Derived1 class with value $value';",
          ),
        );
        expect(
          dartCode,
          contains(
            r"String get description => 'Derived2 class with flag $flag';",
          ),
        );
        expect(
          dartCode,
          contains(
            r"String get description => 'MultiDerived with value $value and rate $rate';",
          ),
        );
      });

      test('handles classes with const constructors and literals', () {
        const dpugCode =
            '''
class ImmutablePoint
  final int x
  final int y

  const ImmutablePoint(this.x, this.y)

  ImmutablePoint.origin() : this(0, 0)

  ImmutablePoint operator +(ImmutablePoint other)
    return ImmutablePoint(x + other.x, y + other.y)

  @override
  String toString() => 'Point($x, $y)'

  @override
  bool operator ==(Object other)
    if other is ImmutablePoint
      return x == other.x && y == other.y
    return false

  @override
  int get hashCode => x.hashCode ^ y.hashCode
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ImmutablePoint'));
        expect(dartCode, contains('final int x;'));
        expect(dartCode, contains('final int y;'));
        expect(dartCode, contains('const ImmutablePoint(this.x, this.y);'));
        expect(dartCode, contains('ImmutablePoint.origin() : this(0, 0);'));
        expect(
          dartCode,
          contains('ImmutablePoint operator +(ImmutablePoint other) =>'),
        );
        expect(dartCode, contains('ImmutablePoint(x + other.x, y + other.y);'));
        expect(dartCode, contains(r"String toString() => 'Point($x, $y)';"));
        expect(dartCode, contains('bool operator ==(Object other) {'));
        expect(dartCode, contains('if (other is ImmutablePoint) {'));
        expect(dartCode, contains('return x == other.x && y == other.y;'));
        expect(
          dartCode,
          contains('int get hashCode => x.hashCode ^ y.hashCode;'),
        );
      });

      test('handles classes with error conditions and exception handling', () {
        const dpugCode = '''
class ErrorProneClass
  int value

  ErrorProneClass(this.value)

  int divideBy(int divisor)
    if divisor == 0
      throw ArgumentError('Cannot divide by zero')
    return value ~/ divisor

  int accessAt(List<int> list, int index)
    if index < 0 || index >= list.length
      throw RangeError('Index out of bounds')
    return list[index]

  String parseString(String? input)
    if input == null
      throw ArgumentError('Input cannot be null')
    if input.isEmpty
      throw ArgumentError('Input cannot be empty')
    return input.toUpperCase()

  void riskyOperation() throws Exception
    if value < 0
      throw Exception('Value cannot be negative')
    if value > 1000
      throw Exception('Value too large')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ErrorProneClass'));
        expect(dartCode, contains('int divideBy(int divisor) {'));
        expect(dartCode, contains('if (divisor == 0) {'));
        expect(
          dartCode,
          contains("throw ArgumentError('Cannot divide by zero');"),
        );
        expect(dartCode, contains('return value ~/ divisor;'));
        expect(dartCode, contains('int accessAt(List<int> list, int index) {'));
        expect(dartCode, contains('if (index < 0 || index >= list.length) {'));
        expect(dartCode, contains("throw RangeError('Index out of bounds');"));
        expect(dartCode, contains('String parseString(String? input) {'));
        expect(dartCode, contains('if (input == null) {'));
        expect(
          dartCode,
          contains("throw ArgumentError('Input cannot be null');"),
        );
        expect(dartCode, contains('if (input.isEmpty) {'));
        expect(
          dartCode,
          contains("throw ArgumentError('Input cannot be empty');"),
        );
        expect(dartCode, contains('return input.toUpperCase();'));
        expect(dartCode, contains('void riskyOperation() {'));
        expect(dartCode, contains('if (value < 0) {'));
        expect(
          dartCode,
          contains("throw Exception('Value cannot be negative');"),
        );
        expect(dartCode, contains('if (value > 1000) {'));
        expect(dartCode, contains("throw Exception('Value too large');"));
      });

      test('handles memory and resource management patterns', () {
        const dpugCode = '''
class ResourceManager
  List<StreamSubscription> subscriptions = []
  Map<String, Timer> timers = {}
  bool disposed = false

  void addSubscription(StreamSubscription subscription)
    if disposed
      subscription.cancel()
      return
    subscriptions.add(subscription)

  void setTimer(String key, Timer timer)
    if disposed
      timer.cancel()
      return
    timers[key] = timer

  Timer? getTimer(String key) => timers[key]

  void cancelTimer(String key)
    Timer? timer = timers.remove(key)
    timer?.cancel()

  void dispose()
    if disposed return
    disposed = true

    for StreamSubscription sub in subscriptions
      sub.cancel()
    subscriptions.clear()

    for Timer timer in timers.values
      timer.cancel()
    timers.clear()

  bool get isDisposed => disposed
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ResourceManager'));
        expect(
          dartCode,
          contains('List<StreamSubscription> subscriptions = [];'),
        );
        expect(dartCode, contains('Map<String, Timer> timers = {};'));
        expect(dartCode, contains('bool disposed = false;'));
        expect(
          dartCode,
          contains('void addSubscription(StreamSubscription subscription) {'),
        );
        expect(dartCode, contains('if (disposed) {'));
        expect(dartCode, contains('subscription.cancel();'));
        expect(dartCode, contains('return;'));
        expect(dartCode, contains('subscriptions.add(subscription);'));
        expect(dartCode, contains('void setTimer(String key, Timer timer) {'));
        expect(dartCode, contains('timers[key] = timer;'));
        expect(
          dartCode,
          contains('Timer? getTimer(String key) => timers[key];'),
        );
        expect(dartCode, contains('void cancelTimer(String key) {'));
        expect(dartCode, contains('Timer? timer = timers.remove(key);'));
        expect(dartCode, contains('timer?.cancel();'));
        expect(dartCode, contains('void dispose() {'));
        expect(dartCode, contains('if (disposed) return;'));
        expect(dartCode, contains('disposed = true;'));
        expect(
          dartCode,
          contains('for (StreamSubscription sub in subscriptions) {'),
        );
        expect(dartCode, contains('sub.cancel();'));
        expect(dartCode, contains('subscriptions.clear();'));
        expect(dartCode, contains('for (Timer timer in timers.values) {'));
        expect(dartCode, contains('timer.cancel();'));
        expect(dartCode, contains('timers.clear();'));
        expect(dartCode, contains('bool get isDisposed => disposed;'));
      });

      test('handles classes with complex initialization patterns', () {
        const dpugCode = '''
class ComplexInit
  late String lazyValue
  String? nullableField
  final String finalField

  ComplexInit(this.finalField)

  ComplexInit.withLazy(String finalValue, String lazy) : finalField = finalValue
    lazyValue = lazy

  ComplexInit.withNullable(String finalValue, String? nullable) :
    finalField = finalValue,
    nullableField = nullable

  void initLazyValue()
    lazyValue = 'initialized'

  bool get isLazyInitialized
    try
      return lazyValue != null
    catch
      return false
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ComplexInit'));
        expect(dartCode, contains('late String lazyValue;'));
        expect(dartCode, contains('String? nullableField;'));
        expect(dartCode, contains('final String finalField;'));
        expect(dartCode, contains('ComplexInit(this.finalField);'));
        expect(
          dartCode,
          contains(
            'ComplexInit.withLazy(String finalValue, String lazy) : finalField = finalValue {',
          ),
        );
        expect(dartCode, contains('lazyValue = lazy;'));
        expect(
          dartCode,
          contains(
            'ComplexInit.withNullable(String finalValue, String? nullable) :',
          ),
        );
        expect(dartCode, contains('finalField = finalValue,'));
        expect(dartCode, contains('nullableField = nullable;'));
        expect(dartCode, contains('void initLazyValue() {'));
        expect(dartCode, contains("lazyValue = 'initialized';"));
        expect(dartCode, contains('bool get isLazyInitialized {'));
        expect(dartCode, contains('try {'));
        expect(dartCode, contains('return lazyValue != null;'));
        expect(dartCode, contains('} catch {'));
        expect(dartCode, contains('return false;'));
      });
    });
  });
}
