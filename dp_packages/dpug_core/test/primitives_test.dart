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
        expect(
          dartCode,
          contains('double circleArea = 3.14159 * radius * radius;'),
        );
        expect(dartCode, contains('int roundedAge = age.round();'));
        expect(
          dartCode,
          contains('double precise = 3.14159.toStringAsFixed(2);'),
        );
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
        expect(
          dartCode,
          contains(r'String details = "Age: $age, Height: ${height.round()}";'),
        );
      });

      test('converts multiline and raw strings', () {
        const dpugCode = r'''
String paragraph = """
This is a multiline
string that spans
multiple lines
"""

String rawPath = r'C:\Users\Documents\file.txt'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('''
String paragraph = """
This is a multiline
string that spans
multiple lines
""";'''),
        );
        expect(
          dartCode,
          contains(
            r"String rawPath = r'C:\\\\Users\\\\Documents\\\\file.txt';",
          ),
        );
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
        expect(
          dartCode,
          contains("bool containsHello = greeting.contains('Hello');"),
        );
        expect(dartCode, contains('int length = name.length;'));
        expect(dartCode, contains('String substring = text.substring(0, 5);'));
        expect(
          dartCode,
          contains("String replaced = text.replaceAll('old', 'new');"),
        );
        expect(dartCode, contains("List<String> parts = text.split(' ');"));
        expect(dartCode, contains('String trimmed = text.trim();'));
        expect(
          dartCode,
          contains("bool startsWith = text.startsWith('Hello');"),
        );
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
        expect(
          dartCode,
          contains('bool shouldShow = !hasPermission || isAdmin;'),
        );
        expect(
          dartCode,
          contains('bool bothTrue = isActive && hasPermission;'),
        );
        expect(
          dartCode,
          contains('bool eitherTrue = isActive || hasPermission;'),
        );
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
        expect(
          dartCode,
          contains("String displayName = optionalName ?? 'Unknown';"),
        );
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
        expect(
          dartCode,
          contains("String safeName = optionalName ?? 'Guest';"),
        );
        expect(
          dartCode,
          contains('int safeLength = optionalName?.length ?? 0;'),
        );
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
        expect(
          dartCode,
          contains("const String apiUrl = 'https://api.example.com';"),
        );
        expect(dartCode, contains('const double pi = 3.14159;'));
        expect(
          dartCode,
          contains("const List<String> colors = ['red', 'green', 'blue'];"),
        );
        expect(
          dartCode,
          contains('final String currentTime = DateTime.now().toString();'),
        );
        expect(
          dartCode,
          contains("final User user = User(id: 1, name: 'John');"),
        );
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
        expect(
          dartCode,
          contains('bool isNotMap = data is! Map<String, dynamic>;'),
        );
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

    group('Edge Cases and Error Conditions', () {
      test('handles very large numbers', () {
        const dpugCode = '''
int maxInt = 9223372036854775807
int minInt = -9223372036854775808
double maxDouble = 1.7976931348623157e+308
double minDouble = -1.7976931348623157e+308
double infinity = 1.0 / 0.0
double negativeInfinity = -1.0 / 0.0
double nan = 0.0 / 0.0
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('int maxInt = 9223372036854775807;'));
        expect(dartCode, contains('int minInt = -9223372036854775808;'));
        expect(
          dartCode,
          contains('double maxDouble = 1.7976931348623157e+308;'),
        );
        expect(
          dartCode,
          contains('double minDouble = -1.7976931348623157e+308;'),
        );
        expect(dartCode, contains('double infinity = 1.0 / 0.0;'));
        expect(dartCode, contains('double negativeInfinity = -1.0 / 0.0;'));
        expect(dartCode, contains('double nan = 0.0 / 0.0;'));
      });

      test('handles very small numbers and precision', () {
        const dpugCode = '''
double tiny = 1e-323
double epsilon = 2.220446049250313e-16
double negativeTiny = -1e-323
int zero = 0
double zeroDouble = 0.0
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('double tiny = 1e-323;'));
        expect(dartCode, contains('double epsilon = 2.220446049250313e-16;'));
        expect(dartCode, contains('double negativeTiny = -1e-323;'));
        expect(dartCode, contains('int zero = 0;'));
        expect(dartCode, contains('double zeroDouble = 0.0;'));
      });

      test('handles scientific notation and special formats', () {
        const dpugCode = '''
double scientific1 = 1.23e10
double scientific2 = 1.23e-10
double scientific3 = 1.23E+10
double scientific4 = 1.23E-10
int hexInt = 0xFF
int binaryInt = 0b1010
int octalInt = 0o755
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('double scientific1 = 1.23e10;'));
        expect(dartCode, contains('double scientific2 = 1.23e-10;'));
        expect(dartCode, contains('double scientific3 = 1.23E+10;'));
        expect(dartCode, contains('double scientific4 = 1.23E-10;'));
        expect(dartCode, contains('int hexInt = 0xFF;'));
        expect(dartCode, contains('int binaryInt = 0b1010;'));
        expect(dartCode, contains('int octalInt = 0o755;'));
      });

      test('handles empty and whitespace strings', () {
        const dpugCode = '''
String empty = ''
String whitespace = '   '
String tabbed = '\t\t'
String newlined = '\n\n'
String mixedWhitespace = ' \t\n '
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("String empty = '';"));
        expect(dartCode, contains("String whitespace = '   ';"));
        expect(dartCode, contains(r"String tabbed = '\t\t';"));
        expect(dartCode, contains(r"String newlined = '\n\n';"));
        expect(dartCode, contains(r"String mixedWhitespace = ' \t\n ';"));
      });

      test('handles Unicode and special characters', () {
        const dpugCode = '''
String emoji = '🚀🌟✨'
String accented = 'café naïve résumé'
String symbols = '©®™€£¥'
String mixed = 'Hello 世界 🌍'
String controlChars = '\u0000\u0001\u0002'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("String emoji = '🚀🌟✨';"));
        expect(dartCode, contains("String accented = 'café naïve résumé';"));
        expect(dartCode, contains("String symbols = '©®™€£¥';"));
        expect(dartCode, contains("String mixed = 'Hello 世界 🌍';"));
        expect(
          dartCode,
          contains(r"String controlChars = '\u0000\u0001\u0002';"),
        );
      });

      test('handles extremely long strings', () {
        final longString = 'a' * 10000;
        final dpugCode = "String longText = '$longString'";

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('String longText = '));
        expect(dartCode, contains(longString));
      });

      test('handles string concatenation edge cases', () {
        const dpugCode = '''
String concatenated = 'Hello' + ' ' + 'World'
String withNumbers = 'Count: ' + 42.toString()
String withBool = 'Active: ' + true.toString()
String nested = ('Hello' + ' ') + ('World' + '!')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains("String concatenated = 'Hello' + ' ' + 'World';"),
        );
        expect(
          dartCode,
          contains("String withNumbers = 'Count: ' + 42.toString();"),
        );
        expect(
          dartCode,
          contains("String withBool = 'Active: ' + true.toString();"),
        );
        expect(
          dartCode,
          contains("String nested = ('Hello' + ' ') + ('World' + '!');"),
        );
      });

      test('handles boolean edge cases', () {
        const dpugCode = '''
bool fromIntZero = 0 as bool
bool fromIntOne = 1 as bool
bool fromDoubleZero = 0.0 as bool
bool fromDoubleNonZero = 1.0 as bool
bool fromEmptyString = '' as bool
bool fromNonEmptyString = 'hello' as bool
bool nullBool = null as bool
''';

        // This tests type conversion edge cases - may throw or handle gracefully
        expect(() => converter.dpugToDart(dpugCode), returnsNormally);
      });

      test('handles arithmetic operator precedence and associativity', () {
        const dpugCode = '''
int result1 = 2 + 3 * 4
int result2 = (2 + 3) * 4
int result3 = 2 * 3 + 4 * 5
double result4 = 2.0 + 3.0 * 4.0 / 2.0
bool complexBool = (2 > 1 && 3 < 4) || (5 == 5 && 6 != 7)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('int result1 = 2 + 3 * 4;'));
        expect(dartCode, contains('int result2 = (2 + 3) * 4;'));
        expect(dartCode, contains('int result3 = 2 * 3 + 4 * 5;'));
        expect(dartCode, contains('double result4 = 2.0 + 3.0 * 4.0 / 2.0;'));
        expect(
          dartCode,
          contains(
            'bool complexBool = (2 > 1 && 3 < 4) || (5 == 5 && 6 != 7);',
          ),
        );
      });

      test('handles division by zero and infinity', () {
        const dpugCode = '''
double divByZero = 1.0 / 0.0
double negativeDivByZero = -1.0 / 0.0
double zeroDivByZero = 0.0 / 0.0
double infinityPlus = 1.0 / 0.0 + 1.0
double infinityMinus = 1.0 / 0.0 - 1.0
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('double divByZero = 1.0 / 0.0;'));
        expect(dartCode, contains('double negativeDivByZero = -1.0 / 0.0;'));
        expect(dartCode, contains('double zeroDivByZero = 0.0 / 0.0;'));
        expect(dartCode, contains('double infinityPlus = 1.0 / 0.0 + 1.0;'));
        expect(dartCode, contains('double infinityMinus = 1.0 / 0.0 - 1.0;'));
      });

      test('handles null safety edge cases', () {
        const dpugCode = '''
String? nullable = null
String definite = nullable ?? 'default'
String chained = nullable?.length.toString() ?? '0'
bool isNull = nullable == null
bool isNotNull = nullable != null
int length = nullable?.length ?? 0
String upper = nullable?.toUpperCase() ?? ''
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('String? nullable = null;'));
        expect(dartCode, contains("String definite = nullable ?? 'default';"));
        expect(
          dartCode,
          contains("String chained = nullable?.length.toString() ?? '0';"),
        );
        expect(dartCode, contains('bool isNull = nullable == null;'));
        expect(dartCode, contains('bool isNotNull = nullable != null;'));
        expect(dartCode, contains('int length = nullable?.length ?? 0;'));
        expect(
          dartCode,
          contains("String upper = nullable?.toUpperCase() ?? '';"),
        );
      });

      test('handles cascade operator edge cases', () {
        const dpugCode = '''
StringBuffer buffer = StringBuffer()
  ..write('Hello')
  ..write(' ')
  ..write('World')
  ..write('!')

List<int> numbers = [1, 2, 3]
  ..add(4)
  ..add(5)
  ..sort()
  ..clear()

Map<String, int> map = {'a': 1}
  ..['b'] = 2
  ..['c'] = 3
  ..remove('a')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('StringBuffer buffer = StringBuffer()'));
        expect(dartCode, contains("..write('Hello')"));
        expect(dartCode, contains("..write(' ')"));
        expect(dartCode, contains("..write('World')"));
        expect(dartCode, contains("..write('!')"));
        expect(dartCode, contains('List<int> numbers = [1, 2, 3]'));
        expect(dartCode, contains('..add(4)'));
        expect(dartCode, contains('..add(5)'));
        expect(dartCode, contains('..sort()'));
        expect(dartCode, contains('..clear()'));
        expect(dartCode, contains("Map<String, int> map = {'a': 1}"));
        expect(dartCode, contains("..['b'] = 2"));
        expect(dartCode, contains("..['c'] = 3"));
        expect(dartCode, contains("..remove('a')"));
      });

      test('handles late initialization edge cases', () {
        const dpugCode = '''
late String lateString
late int lateInt
late double lateDouble
late bool lateBool
late List<String> lateList
late Map<String, int> lateMap
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('late String lateString;'));
        expect(dartCode, contains('late int lateInt;'));
        expect(dartCode, contains('late double lateDouble;'));
        expect(dartCode, contains('late bool lateBool;'));
        expect(dartCode, contains('late List<String> lateList;'));
        expect(dartCode, contains('late Map<String, int> lateMap;'));
      });

      test('handles final vs const edge cases', () {
        const dpugCode = '''
const int constInt = 42
final int finalInt = 42
const String constString = 'hello'
final String finalString = 'hello'
const List<int> constList = [1, 2, 3]
final List<int> finalList = [1, 2, 3]
const Map<String, int> constMap = {'a': 1}
final Map<String, int> finalMap = {'a': 1}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('const int constInt = 42;'));
        expect(dartCode, contains('final int finalInt = 42;'));
        expect(dartCode, contains("const String constString = 'hello';"));
        expect(dartCode, contains("final String finalString = 'hello';"));
        expect(dartCode, contains('const List<int> constList = [1, 2, 3];'));
        expect(dartCode, contains('final List<int> finalList = [1, 2, 3];'));
        expect(
          dartCode,
          contains("const Map<String, int> constMap = {'a': 1};"),
        );
        expect(
          dartCode,
          contains("final Map<String, int> finalMap = {'a': 1};"),
        );
      });

      test('handles complex type casting scenarios', () {
        const dpugCode = '''
num flexibleNumber = 42
int castInt = flexibleNumber as int
double castDouble = flexibleNumber as double

dynamic anything = 'hello'
String? castString = anything as String?
int? castIntFromDynamic = anything as int?

Object object = 42
int unboxedInt = object as int
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('num flexibleNumber = 42;'));
        expect(dartCode, contains('int castInt = flexibleNumber as int;'));
        expect(
          dartCode,
          contains('double castDouble = flexibleNumber as double;'),
        );
        expect(dartCode, contains("dynamic anything = 'hello';"));
        expect(dartCode, contains('String? castString = anything as String?;'));
        expect(
          dartCode,
          contains('int? castIntFromDynamic = anything as int?;'),
        );
        expect(dartCode, contains('Object object = 42;'));
        expect(dartCode, contains('int unboxedInt = object as int;'));
      });

      test('handles runtime type checking', () {
        const dpugCode =
            "dynamic value = 'hello'\n"
            'bool isString = value is String\n'
            'bool isNotInt = value is! int\n'
            'bool isList = value is List<String>\n'
            'bool isMap = value is Map<String, dynamic>\n\n'
            'if value is String\n'
            '  String str = value\n'
            "  print 'String length: \${str.length}'\n\n"
            'String? safeCast = value as? String\n'
            'if safeCast != null\n'
            "  print 'Safe cast successful'";

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("dynamic value = 'hello';"));
        expect(dartCode, contains('bool isString = value is String;'));
        expect(dartCode, contains('bool isNotInt = value is! int;'));
        expect(dartCode, contains('bool isList = value is List<String>;'));
        expect(
          dartCode,
          contains('bool isMap = value is Map<String, dynamic>;'),
        );
        expect(dartCode, contains('if (value is String) {'));
        expect(dartCode, contains('String str = value;'));
        expect(dartCode, contains(r"print('String length: ${str.length}');"));
        expect(dartCode, contains('String? safeCast = value as? String;'));
        expect(dartCode, contains('if (safeCast != null) {'));
        expect(dartCode, contains("print('Safe cast successful');"));
      });

      test('handles memory and performance edge cases', () {
        // Test with large data structures that could cause memory issues
        final largeList = List.generate(1000, (final i) => i).join(',');
        final dpugCode = 'List<int> largeList = [$largeList]';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> largeList = ['));
        expect(dartCode, contains('0,1,2,3,4,5,6,7,8,9,'));
      });

      test('handles concurrent access patterns', () {
        const dpugCode = '''
List<int> sharedList = [1, 2, 3]
Map<String, int> sharedMap = {'a': 1, 'b': 2}
StringBuffer sharedBuffer = StringBuffer('hello')

// These would be used in concurrent contexts
int listLength = sharedList.length
bool mapContains = sharedMap.containsKey('a')
String bufferContent = sharedBuffer.toString()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> sharedList = [1, 2, 3];'));
        expect(
          dartCode,
          contains("Map<String, int> sharedMap = {'a': 1, 'b': 2};"),
        );
        expect(
          dartCode,
          contains("StringBuffer sharedBuffer = StringBuffer('hello');"),
        );
        expect(dartCode, contains('int listLength = sharedList.length;'));
        expect(
          dartCode,
          contains("bool mapContains = sharedMap.containsKey('a');"),
        );
        expect(
          dartCode,
          contains('String bufferContent = sharedBuffer.toString();'),
        );
      });

      test('handles resource cleanup edge cases', () {
        const dpugCode = '''
StreamController<int> controller = StreamController<int>()
Timer? timer
Random random = Random()

void cleanup()
  controller.close()
  timer?.cancel()
  timer = null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'StreamController<int> controller = StreamController<int>();',
          ),
        );
        expect(dartCode, contains('Timer? timer;'));
        expect(dartCode, contains('Random random = Random();'));
        expect(dartCode, contains('void cleanup() {'));
        expect(dartCode, contains('controller.close();'));
        expect(dartCode, contains('timer?.cancel();'));
        expect(dartCode, contains('timer = null;'));
      });

      test('handles circular references and self-references', () {
        const dpugCode = '''
Object self = self
dynamic circular
circular = circular

Map<String, dynamic> selfMap = {'self': selfMap}
List<dynamic> selfList = [selfList]
''';

        // These should either work or handle gracefully
        expect(() => converter.dpugToDart(dpugCode), returnsNormally);
      });

      test('handles deeply nested expressions', () {
        const dpugCode =
            'int deeplyNested = (((2 + 3) * 4) - 1) ~/ 2\n'
            'bool complexCondition = (((a > b && c < d) || (e == f && g != h)) && (i >= j || k <= l))\n'
            r"String nestedString = 'Hello ${'World ${'Nested'.toUpperCase()}'}'.toLowerCase()";

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('int deeplyNested = (((2 + 3) * 4) - 1) ~/ 2;'),
        );
        expect(
          dartCode,
          contains(
            'bool complexCondition = (((a > b && c < d) || (e == f && g != h)) && (i >= j || k <= l));',
          ),
        );
        expect(
          dartCode,
          contains(
            r"String nestedString = 'Hello ${'World ${'Nested'.toUpperCase()}'}'.toLowerCase();",
          ),
        );
      });
    });
  });
}
