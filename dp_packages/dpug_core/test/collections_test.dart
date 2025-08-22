import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Collections Conversion', () {
    final converter = DpugConverter();

    group('Lists', () {
      test('converts basic list creation', () {
        const dpugCode = '''
List<int> numbers = [1, 2, 3, 4, 5]
List<String> names = ['Alice', 'Bob', 'Charlie']
List<dynamic> mixed = [1, 'text', true]
List<int> emptyInts = []
List<String> emptyStrings = <String>[]
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> numbers = [1, 2, 3, 4, 5];'));
        expect(
          dartCode,
          contains("List<String> names = ['Alice', 'Bob', 'Charlie'];"),
        );
        expect(dartCode, contains("List<dynamic> mixed = [1, 'text', true];"));
        expect(dartCode, contains('List<int> emptyInts = [];'));
        expect(dartCode, contains('List<String> emptyStrings = <String>[];'));
      });

      test('converts list operations', () {
        const dpugCode = '''
numbers.add(6)
numbers.addAll([7, 8, 9])
int first = numbers.first
int last = numbers.last
int? firstOrNull = numbers.firstOrNull
int length = numbers.length
bool isEmpty = numbers.isEmpty
bool containsFive = numbers.contains(5)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('numbers.add(6);'));
        expect(dartCode, contains('numbers.addAll([7, 8, 9]);'));
        expect(dartCode, contains('int first = numbers.first;'));
        expect(dartCode, contains('int last = numbers.last;'));
        expect(dartCode, contains('int? firstOrNull = numbers.firstOrNull;'));
        expect(dartCode, contains('int length = numbers.length;'));
        expect(dartCode, contains('bool isEmpty = numbers.isEmpty;'));
        expect(dartCode, contains('bool containsFive = numbers.contains(5);'));
      });

      test('converts list manipulation methods', () {
        const dpugCode = '''
int removed = numbers.removeLast()
bool wasRemoved = numbers.remove(3)
numbers.clear()
List<int> sublist = numbers.sublist(1, 3)
numbers.insert(0, 0)
numbers.insertAll(2, [10, 11])
int index = numbers.indexOf(5)
int lastIndex = numbers.lastIndexOf(3)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('int removed = numbers.removeLast();'));
        expect(dartCode, contains('bool wasRemoved = numbers.remove(3);'));
        expect(dartCode, contains('numbers.clear();'));
        expect(
          dartCode,
          contains('List<int> sublist = numbers.sublist(1, 3);'),
        );
        expect(dartCode, contains('numbers.insert(0, 0);'));
        expect(dartCode, contains('numbers.insertAll(2, [10, 11]);'));
        expect(dartCode, contains('int index = numbers.indexOf(5);'));
        expect(dartCode, contains('int lastIndex = numbers.lastIndexOf(3);'));
      });

      test('converts spread operator and collection if', () {
        const dpugCode = '''
List<int> combined = [0, ...numbers, 10]
List<int> conditional = [1, 2, if showMore ...[3, 4, 5], 6]
List<String> namesWithDefault = [...names, if names.isEmpty 'Default']
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> combined = [0, ...numbers, 10];'));
        expect(
          dartCode,
          contains(
            'List<int> conditional = [1, 2, if (showMore) ...[3, 4, 5], 6];',
          ),
        );
        expect(
          dartCode,
          contains(
            "List<String> namesWithDefault = [...names, if (names.isEmpty) 'Default'];",
          ),
        );
      });

      test('converts list comprehensions', () {
        const dpugCode = '''
List<int> squares = [for int i in 1..5 i * i]
List<String> upperNames = [for String name in names name.toUpperCase()]
List<int> evenNumbers = [for int n in numbers if n % 2 == 0 n]
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('List<int> squares = [for (int i = 1; i <= 5; i++) i * i];'),
        );
        expect(
          dartCode,
          contains(
            'List<String> upperNames = [for (String name in names) name.toUpperCase()];',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<int> evenNumbers = [for (int n in numbers) if (n % 2 == 0) n];',
          ),
        );
      });

      test('converts functional programming methods', () {
        const dpugCode = '''
List<int> doubled = numbers.map((n) => n * 2).toList()
List<String> filtered = names.where((name) => name.length > 3).toList()
int sum = numbers.fold(0, (prev, n) => prev + n)
int maxValue = numbers.reduce((a, b) => a > b ? a : b)
bool allPositive = numbers.every((n) => n > 0)
bool anyEven = numbers.any((n) => n % 2 == 0)
String joined = names.join(', ')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('List<int> doubled = numbers.map((n) => n * 2).toList();'),
        );
        expect(
          dartCode,
          contains(
            'List<String> filtered = names.where((name) => name.length > 3).toList();',
          ),
        );
        expect(
          dartCode,
          contains('int sum = numbers.fold(0, (prev, n) => prev + n);'),
        );
        expect(
          dartCode,
          contains('int maxValue = numbers.reduce((a, b) => a > b ? a : b);'),
        );
        expect(
          dartCode,
          contains('bool allPositive = numbers.every((n) => n > 0);'),
        );
        expect(
          dartCode,
          contains('bool anyEven = numbers.any((n) => n % 2 == 0);'),
        );
        expect(dartCode, contains("String joined = names.join(', ');"));
      });
    });

    group('Maps', () {
      test('converts basic map creation', () {
        const dpugCode = '''
Map<String, int> ages = {'Alice': 25, 'Bob': 30, 'Charlie': 35}
Map<String, dynamic> user = {
  'id': 1,
  'name': 'John',
  'email': 'john@example.com'
}
Map<String, String> emptyMap = {}
Map<int, bool> flags = <int, bool>{}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            "Map<String, int> ages = {'Alice': 25, 'Bob': 30, 'Charlie': 35};",
          ),
        );
        expect(dartCode, contains('Map<String, dynamic> user = {'));
        expect(dartCode, contains("'id': 1,"));
        expect(dartCode, contains("'name': 'John',"));
        expect(dartCode, contains("'email': 'john@example.com'"));
        expect(dartCode, contains('Map<String, String> emptyMap = {};'));
        expect(dartCode, contains('Map<int, bool> flags = <int, bool>{};'));
      });

      test('converts map operations', () {
        const dpugCode = '''
int? aliceAge = ages['Alice']
ages['David'] = 28
ages.remove('Bob')
List<String> keys = ages.keys.toList()
List<int> values = ages.values.toList()
bool hasAlice = ages.containsKey('Alice')
bool hasValue30 = ages.containsValue(30)
bool isEmpty = ages.isEmpty
int length = ages.length
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("int? aliceAge = ages['Alice'];"));
        expect(dartCode, contains("ages['David'] = 28;"));
        expect(dartCode, contains("ages.remove('Bob');"));
        expect(dartCode, contains('List<String> keys = ages.keys.toList();'));
        expect(dartCode, contains('List<int> values = ages.values.toList();'));
        expect(
          dartCode,
          contains("bool hasAlice = ages.containsKey('Alice');"),
        );
        expect(dartCode, contains('bool hasValue30 = ages.containsValue(30);'));
        expect(dartCode, contains('bool isEmpty = ages.isEmpty;'));
        expect(dartCode, contains('int length = ages.length;'));
      });

      test('converts map spread operations', () {
        const dpugCode = '''
Map<String, int> updatedAges = {
  ...ages,
  'Eve': 22,
  if showExtra 'Frank': 40
}
Map<String, dynamic> merged = {
  ...user,
  ...config,
  'updatedAt': DateTime.now()
}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Map<String, int> updatedAges = {'));
        expect(dartCode, contains('...ages,'));
        expect(dartCode, contains("'Eve': 22,"));
        expect(dartCode, contains("if (showExtra) 'Frank': 40"));
        expect(dartCode, contains('Map<String, dynamic> merged = {'));
        expect(dartCode, contains('...user,'));
        expect(dartCode, contains('...config,'));
      });

      test('converts map comprehensions', () {
        const dpugCode = '''
Map<String, int> nameLengths = {
  for String name in names
  name: name.length
}
Map<int, String> indexedNames = {
  for int i in 0..names.length-1
  i: names[i]
}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Map<String, int> nameLengths = {'));
        expect(dartCode, contains('for (String name in names)'));
        expect(dartCode, contains('name: name.length'));
        expect(dartCode, contains('Map<int, String> indexedNames = {'));
        expect(dartCode, contains('for (int i = 0; i < names.length; i++)'));
        expect(dartCode, contains('i: names[i]'));
      });
    });

    group('Sets', () {
      test('converts basic set creation', () {
        const dpugCode = '''
Set<int> numbers = {1, 2, 3, 4, 5}
Set<String> uniqueNames = {'Alice', 'Bob', 'Alice'}
Set<dynamic> mixedSet = {1, 'text', true}
Set<String> emptySet = {}
Set<int> intSet = <int>{}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Set<int> numbers = {1, 2, 3, 4, 5};'));
        expect(
          dartCode,
          contains("Set<String> uniqueNames = {'Alice', 'Bob', 'Alice'};"),
        );
        expect(
          dartCode,
          contains("Set<dynamic> mixedSet = {1, 'text', true};"),
        );
        expect(dartCode, contains('Set<String> emptySet = {};'));
        expect(dartCode, contains('Set<int> intSet = <int>{};'));
      });

      test('converts set operations', () {
        const dpugCode = '''
numbers.add(6)
numbers.remove(3)
bool containsFive = numbers.contains(5)
int length = numbers.length
bool isEmpty = numbers.isEmpty
numbers.clear()
int first = numbers.first
int last = numbers.last
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('numbers.add(6);'));
        expect(dartCode, contains('numbers.remove(3);'));
        expect(dartCode, contains('bool containsFive = numbers.contains(5);'));
        expect(dartCode, contains('int length = numbers.length;'));
        expect(dartCode, contains('bool isEmpty = numbers.isEmpty;'));
        expect(dartCode, contains('numbers.clear();'));
        expect(dartCode, contains('int first = numbers.first;'));
        expect(dartCode, contains('int last = numbers.last;'));
      });

      test('converts set mathematical operations', () {
        const dpugCode = '''
Set<int> setA = {1, 2, 3, 4}
Set<int> setB = {3, 4, 5, 6}
Set<int> union = setA.union(setB)
Set<int> intersection = setA.intersection(setB)
Set<int> difference = setA.difference(setB)
Set<int> symmetricDifference = setA.difference(setB).union(setB.difference(setA))
bool isSubset = setA.difference(setB).isEmpty
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Set<int> setA = {1, 2, 3, 4};'));
        expect(dartCode, contains('Set<int> setB = {3, 4, 5, 6};'));
        expect(dartCode, contains('Set<int> union = setA.union(setB);'));
        expect(
          dartCode,
          contains('Set<int> intersection = setA.intersection(setB);'),
        );
        expect(
          dartCode,
          contains('Set<int> difference = setA.difference(setB);'),
        );
        expect(
          dartCode,
          contains(
            'Set<int> symmetricDifference = setA.difference(setB).union(setB.difference(setA));',
          ),
        );
        expect(
          dartCode,
          contains('bool isSubset = setA.difference(setB).isEmpty;'),
        );
      });
    });

    group('Iterables and Collections', () {
      test('converts iterable operations', () {
        const dpugCode = '''
Iterable<int> range = 1..100
Iterable<String> filtered = names.where((name) => name.startsWith('A'))
Iterable<int> mapped = numbers.map((n) => n * 2)
Iterable<int> taken = numbers.take(5)
Iterable<int> skipped = numbers.skip(2)
List<int> listFromIterable = range.toList()
Set<String> setFromIterable = names.toSet()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'Iterable<int> range = Iterable.generate(100, (i) => i + 1);',
          ),
        );
        expect(
          dartCode,
          contains(
            "Iterable<String> filtered = names.where((name) => name.startsWith('A'));",
          ),
        );
        expect(
          dartCode,
          contains('Iterable<int> mapped = numbers.map((n) => n * 2);'),
        );
        expect(dartCode, contains('Iterable<int> taken = numbers.take(5);'));
        expect(dartCode, contains('Iterable<int> skipped = numbers.skip(2);'));
        expect(
          dartCode,
          contains('List<int> listFromIterable = range.toList();'),
        );
        expect(
          dartCode,
          contains('Set<String> setFromIterable = names.toSet();'),
        );
      });

      test('converts collection transformations', () {
        const dpugCode = '''
Map<String, int> mapFromEntries = Map.fromEntries(
  names.map((name) => MapEntry(name, name.length))
)
List<int> sortedNumbers = numbers.sorted((a, b) => a.compareTo(b))
List<String> sortedNames = names.sorted((a, b) => b.compareTo(a))
List<List<String>> groups = names.groupBy((name) => name[0])
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('Map<String, int> mapFromEntries = Map.fromEntries('),
        );
        expect(
          dartCode,
          contains('names.map((name) => MapEntry(name, name.length))'),
        );
        expect(
          dartCode,
          contains(
            'List<int> sortedNumbers = numbers.sorted((a, b) => a.compareTo(b));',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<String> sortedNames = names.sorted((a, b) => b.compareTo(a));',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<List<String>> groups = names.groupBy((name) => name[0]);',
          ),
        );
      });
    });

    group('Collection Literals with Type Inference', () {
      test('converts type-inferred collections', () {
        const dpugCode = '''
var numbers = [1, 2, 3, 4, 5]
var names = ['Alice', 'Bob']
var mapping = {'a': 1, 'b': 2}
var unique = {1, 2, 3}
List<dynamic> mixed = [1, 'text', true]
Map<String, dynamic> flexible = {
  'number': 42,
  'text': 'hello',
  'flag': true
}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('var numbers = [1, 2, 3, 4, 5];'));
        expect(dartCode, contains("var names = ['Alice', 'Bob'];"));
        expect(dartCode, contains("var mapping = {'a': 1, 'b': 2};"));
        expect(dartCode, contains('var unique = {1, 2, 3};'));
        expect(dartCode, contains("List<dynamic> mixed = [1, 'text', true];"));
        expect(dartCode, contains('Map<String, dynamic> flexible = {'));
        expect(dartCode, contains("'number': 42,"));
        expect(dartCode, contains("'text': 'hello',"));
        expect(dartCode, contains("'flag': true"));
      });
    });

    group('Advanced Collection Operations', () {
      test('converts complex collection chaining', () {
        const dpugCode = '''
List<String> result = names
  .where((name) => name.length > 3)
  .map((name) => name.toUpperCase())
  .toList()

List<int> processed = numbers
  .where((n) => n % 2 == 0)
  .map((n) => n * n)
  .take(5)
  .toList()

Map<String, List<String>> grouped = names
  .groupBy((name) => name.length.toString())
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<String> result = names'));
        expect(dartCode, contains('.where((name) => name.length > 3)'));
        expect(dartCode, contains('.map((name) => name.toUpperCase())'));
        expect(dartCode, contains('.toList();'));
        expect(dartCode, contains('List<int> processed = numbers'));
        expect(dartCode, contains('.where((n) => n % 2 == 0)'));
        expect(dartCode, contains('.map((n) => n * n)'));
        expect(dartCode, contains('.take(5)'));
        expect(dartCode, contains('.toList();'));
      });

      test('converts partitioning operations', () {
        const dpugCode = '''
List<List<String>> parts = names.partition((name) => name.length > 3)
List<String> shortNames = parts[0]
List<String> longNames = parts[1]

List<List<int>> evenOdd = numbers.partition((n) => n % 2 == 0)
List<int> even = evenOdd[0]
List<int> odd = evenOdd[1]
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'List<List<String>> parts = names.partition((name) => name.length > 3);',
          ),
        );
        expect(dartCode, contains('List<String> shortNames = parts[0];'));
        expect(dartCode, contains('List<String> longNames = parts[1];'));
        expect(
          dartCode,
          contains(
            'List<List<int>> evenOdd = numbers.partition((n) => n % 2 == 0);',
          ),
        );
        expect(dartCode, contains('List<int> even = evenOdd[0];'));
        expect(dartCode, contains('List<int> odd = evenOdd[1];'));
      });
    });

    group('Round-trip Collection Conversion', () {
      test('collections maintain semantics through round-trip', () {
        const dpugCode = '''
List<int> numbers = [1, 2, 3, 4, 5]
Map<String, int> ages = {'Alice': 25, 'Bob': 30}
Set<String> names = {'Alice', 'Bob', 'Charlie'}
List<String> result = [for String name in names if name.length > 3 name.toUpperCase()]
''';

        final dartCode = converter.dpugToDart(dpugCode);
        final backToDpug = converter.dartToDpug(dartCode);

        // Should contain the key elements
        expect(backToDpug, contains('List<int> numbers = [1, 2, 3, 4, 5]'));
        expect(
          backToDpug,
          contains("Map<String, int> ages = {'Alice': 25, 'Bob': 30}"),
        );
        expect(
          backToDpug,
          contains("Set<String> names = {'Alice', 'Bob', 'Charlie'}"),
        );
        expect(backToDpug, contains('for String name in names'));
        expect(backToDpug, contains('if name.length > 3'));
        expect(backToDpug, contains('name.toUpperCase()'));
      });
    });
  });
}
