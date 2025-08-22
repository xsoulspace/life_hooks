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
  });
}
