// DPug Language Specification: Primitives

DPug supports all Dart primitive types with a clean, indentation-based syntax.

## Numbers (int, double, num)

```dpug
int age = 25
double height = 1.75
num value = 42.5

// Operations
int sum = 10 + 5
double result = 3.14 * 2
num calculation = (sum * 2.0) + 10
```

## Strings

```dpug
String name = 'John Doe'
String message = "Hello, World!"

// String interpolation
String greeting = "Hello, $name"
String details = "Age: $age, Height: ${height.round()}"

// Multiline strings
String paragraph = '''
This is a multiline
string that spans
multiple lines
'''

// Raw strings
String rawPath = r'C:\Users\Documents\file.txt'
```

## Booleans

```dpug
bool isActive = true
bool hasPermission = false
bool canEdit = user.role == 'admin'

// Boolean operations
bool isValid = age > 18 && isActive
bool shouldShow = !hasPermission || isAdmin
```

## Null and Nullable Types

```dpug
String? optionalName = null
int? nullableAge

// Null-aware operators
String displayName = optionalName ?? 'Unknown'
int length = optionalName?.length ?? 0

// Null assertion
String definiteName = optionalName!
```

## Type Inference

```dpug
// Dart's var and dynamic
var count = 10          // Inferred as int
var message = 'Hello'   // Inferred as String
var data = [1, 2, 3]    // Inferred as List<int>

dynamic flexible = 'anything'
flexible = 42  // Error: Cannot assign 'int' to 'String'
```

## Constants

```dpug
const int maxRetries = 3
const String apiUrl = 'https://api.example.com'
const double pi = 3.14159

final String currentTime = DateTime.now().toString()
final User user = User(id: 1, name: 'John')
```

## Type Casting and Checking

```dpug
// Type checking
bool isString = value is String
bool isNotInt = value is! int

// Type casting
if value is int
  int number = value as int
  print 'Number: $number'

// Safe casting
int? safeNumber = value as? int
if safeNumber != null
  print 'Safe number: $safeNumber'
```
