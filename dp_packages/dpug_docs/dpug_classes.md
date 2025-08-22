// DPug Language Specification: Classes

DPug supports all Dart class features with a clean, indentation-based syntax focused on readability.

## Basic Classes

```dpug
class Person
  String name
  int age

  Person(this.name, this.age)

  void greet() =>
    print 'Hello, I am $name, age $age'

  String toString() =>
    'Person(name: $name, age: $age)'

// Usage
Person person = Person('Alice', 25)
person.greet()
```

## Constructors

```dpug
class User
  String name
  String email
  int? age

  // Default constructor
  User(this.name, this.email, [this.age])

  // Named constructors
  User.guest()
    name = 'Guest'
    email = 'guest@example.com'

  User.fromJson(Map<String, dynamic> json)
    name = json['name']
    email = json['email']
    age = json['age']

  // Factory constructors
  factory User.admin() =>
    User('Admin', 'admin@system.com')

// Usage
User user1 = User('John', 'john@example.com', 30)
User guest = User.guest()
User admin = User.admin()
```

## Methods and Getters/Setters

```dpug
class Calculator
  double _value = 0

  // Getter
  double get value => _value

  // Setter
  set value(double newValue) => _value = newValue

  // Methods
  void add(double n) => _value += n
  void subtract(double n) => _value -= n
  void multiply(double n) => _value *= n
  void divide(double n) => _value /= n

  void clear() => _value = 0

  // Method with multiple statements
  double calculateComplex(double a, double b)
    double result = a * 2
    result += b / 3
    return result

// Usage
Calculator calc = Calculator()
calc.add(10)
calc.multiply(2)
print 'Result: ${calc.value}'
```

## Static Members

```dpug
class MathUtils
  static const double pi = 3.14159
  static const double e = 2.71828

  static double square(double x) => x * x
  static double cube(double x) => x * x * x

  static double get randomValue => math.Random().nextDouble()

// Usage
double area = MathUtils.pi * MathUtils.square(radius)
double volume = MathUtils.cube(side)
```

## Inheritance

```dpug
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
```

## Abstract Classes and Interfaces

```dpug
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
```

## Mixins

```dpug
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
```

## Enums

```dpug
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

// Usage
Status userStatus = Status.active
Priority taskPriority = Priority.high

if userStatus == Status.active
  print 'User is active'

print 'Priority value: ${taskPriority.value}'
```

## Generics

```dpug
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

// Usage
Stack<int> intStack = Stack()
intStack.push(1)
intStack.push(2)
int value = intStack.pop()

Pair<String, int> person = Pair('Alice', 25)
```

## Extension Methods

```dpug
extension StringExtensions on String
  bool get isEmail => contains('@') && contains('.')
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}'
  String get reversed => split('').reversed.join()

extension NumberFormatting on num
  String toCurrency() => '\$${toStringAsFixed(2)}'
  String toPercentage() => '${(this * 100).toFixed(1)}%'

// Usage
String email = 'user@example.com'
if email.isEmail
  print 'Valid email'

String name = 'alice'.capitalize()  // 'Alice'
double price = 29.99.toCurrency()   // '$29.99'
```

## Operator Overloading

```dpug
class Vector
  double x, y

  Vector(this.x, this.y)

  Vector operator +(Vector other) => Vector(x + other.x, y + other.y)
  Vector operator -(Vector other) => Vector(x - other.x, y - other.y)
  Vector operator *(double scalar) => Vector(x * scalar, y * scalar)

  @override
  String toString() => '($x, $y)'

// Usage
Vector v1 = Vector(1, 2)
Vector v2 = Vector(3, 4)
Vector sum = v1 + v2          // (4, 6)
Vector scaled = v1 * 2         // (2, 4)
```
