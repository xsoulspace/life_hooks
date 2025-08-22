import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Primitives Conversion', () {
    final converter = DpugConverter();

    group('Numbers (int, double, num)', () {
      test('converts basic int operations', () {
        const dpugCode = '''
int age = 25
double height = 1.75
num value = 42.5

int sum = 10 + 5
double result = 3.14 * 2
num calculation = (sum * 2.0) + 10
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('int age = 25;'));
        expect(dartCode, contains('double height = 1.75;'));
        expect(dartCode, contains('num value = 42.5;'));
        expect(dartCode, contains('int sum = 10 + 5;'));
        expect(dartCode, contains('double result = 3.14 * 2;'));
        expect(dartCode, contains('num calculation = (sum * 2.0) + 10;'));
      });

      test('converts numeric operations and methods', () {
        const dpugCode = '''
double circleArea = 3.14159 * radius * radius
int roundedAge = age.round()
double precise = 3.14159.toStringAsFixed(2)
num absolute = (-42).abs()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('double circleArea = 3.14159 * radius * radius;'));
        expect(dartCode, contains('int roundedAge = age.round();'));
        expect(dartCode, contains('double precise = 3.14159.toStringAsFixed(2);'));
        expect(dartCode, contains('num absolute = (-42).abs();'));
      });
    });

    group('Strings', () {
      test('converts basic string literals', () {
        const dpugCode = r'''
String name = 'John Doe'
String message = "Hello, World!"
String greeting = "Hello, $name"
String details = "Age: $age, Height: ${height.round()}"
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("String name = 'John Doe';"));
        expect(dartCode, contains('String message = "Hello, World!";'));
        expect(dartCode, contains(r'String greeting = "Hello, $name";'));
        expect(dartCode, contains(r'String details = "Age: $age, Height: ${height.round()}";'));
      });

      test('converts multiline and raw strings', () {
        const dpugCode = '''
String paragraph = '''
This is a multiline
string that spans
multiple lines
'''

String rawPath = r'C:UsersDocuments\file.txt'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('''String paragraph = '''
This is a multiline
string that spans
multiple lines
''';'''));
        expect(dartCode, contains(r"String rawPath = r'C:\\Users\\Documents\\file.txt';"));
      });

      test('converts string operations and methods', () {
        const dpugCode = '''
String upper = name.toUpperCase()
String lower = message.toLowerCase()
bool isEmpty = text.isEmpty
bool containsHello = greeting.contains('Hello')
int length = name.length
String substring = text.substring(0, 5)
String replaced = text.replaceAll('old', 'new')
List<String> parts = text.split(' ')
String trimmed = text.trim()
bool startsWith = text.startsWith('Hello')
bool endsWith = text.endsWith('World')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('String upper = name.toUpperCase();'));
        expect(dartCode, contains('String lower = message.toLowerCase();'));
        expect(dartCode, contains('bool isEmpty = text.isEmpty;'));
        expect(dartCode, contains("bool containsHello = greeting.contains('Hello');"));
        expect(dartCode, contains('int length = name.length;'));
        expect(dartCode, contains('String substring = text.substring(0, 5);'));
        expect(dartCode, contains("String replaced = text.replaceAll('old', 'new');"));
        expect(dartCode, contains("List<String> parts = text.split(' ');"));
        expect(dartCode, contains('String trimmed = text.trim();'));
        expect(dartCode, contains("bool startsWith = text.startsWith('Hello');"));
        expect(dartCode, contains("bool endsWith = text.endsWith('World');"));
      });
    });

    group('Booleans', () {
      test('converts boolean literals and operations', () {
        const dpugCode = '''
bool isActive = true
bool hasPermission = false
bool canEdit = user.role == 'admin'
bool isValid = age > 18 && isActive
bool shouldShow = !hasPermission || isAdmin
bool bothTrue = isActive && hasPermission
bool eitherTrue = isActive || hasPermission
bool isNotActive = !isActive
bool isEqual = value == expected
bool isNotEqual = value != expected
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('bool isActive = true;'));
        expect(dartCode, contains('bool hasPermission = false;'));
        expect(dartCode, contains("bool canEdit = user.role == 'admin';"));
        expect(dartCode, contains('bool isValid = age > 18 && isActive;'));
        expect(dartCode, contains('bool shouldShow = !hasPermission || isAdmin;'));
        expect(dartCode, contains('bool bothTrue = isActive && hasPermission;'));
        expect(dartCode, contains('bool eitherTrue = isActive || hasPermission;'));
        expect(dartCode, contains('bool isNotActive = !isActive;'));
        expect(dartCode, contains('bool isEqual = value == expected;'));
        expect(dartCode, contains('bool isNotEqual = value != expected;'));
      });

      test('converts comparison operations', () {
        const dpugCode = '''
bool greaterThan = a > b
bool lessThan = a < b
bool greaterOrEqual = a >= b
bool lessOrEqual = a <= b
bool isNull = value == null
bool isNotNull = value != null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('bool greaterThan = a > b;'));
        expect(dartCode, contains('bool lessThan = a < b;'));
        expect(dartCode, contains('bool greaterOrEqual = a >= b;'));
        expect(dartCode, contains('bool lessOrEqual = a <= b;'));
        expect(dartCode, contains('bool isNull = value == null;'));
        expect(dartCode, contains('bool isNotNull = value != null;'));
      });
    });

    group('Null and Nullable Types', () {
      test('converts nullable types and null-aware operators', () {
        const dpugCode = '''
String? optionalName = null
int? nullableAge
String displayName = optionalName ?? 'Unknown'
int length = optionalName?.length ?? 0
String definiteName = optionalName!
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('String? optionalName = null;'));
        expect(dartCode, contains('int? nullableAge;'));
        expect(dartCode, contains("String displayName = optionalName ?? 'Unknown';"));
        expect(dartCode, contains('int length = optionalName?.length ?? 0;'));
        expect(dartCode, contains('String definiteName = optionalName!;'));
      });

      test('converts null checks and assertions', () {
        const dpugCode = r'''
if optionalName != null
  String name = optionalName
  print 'Name: $name'

String safeName = optionalName ?? 'Guest'
int safeLength = optionalName?.length ?? 0
bool hasValue = optionalName != null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('if (optionalName != null) {'));
        expect(dartCode, contains('String name = optionalName;'));
        expect(dartCode, contains("String safeName = optionalName ?? 'Guest';"));
        expect(dartCode, contains('int safeLength = optionalName?.length ?? 0;'));
        expect(dartCode, contains('bool hasValue = optionalName != null;'));
      });
    });

    group('Type Inference', () {
      test('converts var and dynamic with type inference', () {
        const dpugCode = '''
var count = 10
var message = 'Hello'
var data = [1, 2, 3]
var mapping = {'a': 1, 'b': 2}
var flag = true

dynamic flexible = 'anything'
flexible = 42
flexible = true
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('var count = 10;'));
        expect(dartCode, contains("var message = 'Hello';"));
        expect(dartCode, contains('var data = [1, 2, 3];'));
        expect(dartCode, contains("var mapping = {'a': 1, 'b': 2};"));
        expect(dartCode, contains('var flag = true;'));
        expect(dartCode, contains("dynamic flexible = 'anything';"));
        expect(dartCode, contains('flexible = 42;'));
        expect(dartCode, contains('flexible = true;'));
      });
    });

    group('Constants', () {
      test('converts const and final declarations', () {
        const dpugCode = '''
const int maxRetries = 3
const String apiUrl = 'https://api.example.com'
const double pi = 3.14159
const List<String> colors = ['red', 'green', 'blue']

final String currentTime = DateTime.now().toString()
final User user = User(id: 1, name: 'John')
final int computed = calculateValue()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('const int maxRetries = 3;'));
        expect(dartCode, contains("const String apiUrl = 'https://api.example.com';"));
        expect(dartCode, contains('const double pi = 3.14159;'));
        expect(dartCode, contains("const List<String> colors = ['red', 'green', 'blue'];"));
        expect(dartCode, contains('final String currentTime = DateTime.now().toString();'));
        expect(dartCode, contains("final User user = User(id: 1, name: 'John');"));
        expect(dartCode, contains('final int computed = calculateValue();'));
      });
    });

    group('Type Casting and Checking', () {
      test('converts type checking operations', () {
        const dpugCode = '''
bool isString = value is String
bool isNotInt = value is! int
bool isList = items is List<String>
bool isNotMap = data is! Map<String, dynamic>
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('bool isString = value is String;'));
        expect(dartCode, contains('bool isNotInt = value is! int;'));
        expect(dartCode, contains('bool isList = items is List<String>;'));
        expect(dartCode, contains('bool isNotMap = data is! Map<String, dynamic>;'));
      });

      test('converts type casting operations', () {
        const dpugCode = r'''
if value is int
  int number = value as int
  print 'Number: $number'

if value is String
  String text = value as String
  int length = text.length

int? safeNumber = value as? int
if safeNumber != null
  print 'Safe number: $safeNumber'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('if (value is int) {'));
        expect(dartCode, contains('int number = value as int;'));
        expect(dartCode, contains('if (value is String) {'));
        expect(dartCode, contains('String text = value as String;'));
        expect(dartCode, contains('int? safeNumber = value as? int;'));
        expect(dartCode, contains('if (safeNumber != null) {'));
      });
    });

    group('Round-trip conversion', () {
      test('primitives maintain semantics through round-trip', () {
        const dpugCode = '''
String name = 'Alice'
int age = 25
double height = 1.75
bool isActive = true
String? optional = null
var dynamicVar = 'test'
const maxValue = 100
''';

        final dartCode = converter.dpugToDart(dpugCode);
        final backToDpug = converter.dartToDpug(dartCode);

        // Should contain the key elements (exact formatting may vary)
        expect(backToDpug, contains("String name = 'Alice'"));
        expect(backToDpug, contains('int age = 25'));
        expect(backToDpug, contains('double height = 1.75'));
        expect(backToDpug, contains('bool isActive = true'));
        expect(backToDpug, contains('String? optional = null'));
        expect(backToDpug, contains("var dynamicVar = 'test'"));
        expect(backToDpug, contains('const maxValue = 100'));
      });
    });
  });
}
