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

    group('Collection Edge Cases and Error Conditions', () {
      test('handles empty collections of all types', () {
        const dpugCode = '''
List<int> emptyList = []
List<String> emptyStringList = <String>[]
Set<int> emptySet = {}
Set<String> emptyStringSet = <String>{}
Map<String, int> emptyMap = {}
Map<int, bool> emptyIntBoolMap = <int, bool>{}
Iterable<int> emptyIterable = [].map((x) => x)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> emptyList = [];'));
        expect(
          dartCode,
          contains('List<String> emptyStringList = <String>[];'),
        );
        expect(dartCode, contains('Set<int> emptySet = {};'));
        expect(dartCode, contains('Set<String> emptyStringSet = <String>{};'));
        expect(dartCode, contains('Map<String, int> emptyMap = {};'));
        expect(
          dartCode,
          contains('Map<int, bool> emptyIntBoolMap = <int, bool>{};'),
        );
        expect(
          dartCode,
          contains('Iterable<int> emptyIterable = [].map((x) => x);'),
        );
      });

      test('handles null values in collections', () {
        const dpugCode = '''
List<String?> nullableList = ['hello', null, 'world']
Map<String, int?> nullableMap = {'a': 1, 'b': null, 'c': 3}
Set<String?> nullableSet = {'hello', null, 'world'}

String? firstNonNull = nullableList.firstWhere((x) => x != null, orElse: () => null)
int? valueOrNull = nullableMap['missing']
bool hasNull = nullableList.contains(null)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains("List<String?> nullableList = ['hello', null, 'world'];"),
        );
        expect(
          dartCode,
          contains(
            "Map<String, int?> nullableMap = {'a': 1, 'b': null, 'c': 3};",
          ),
        );
        expect(
          dartCode,
          contains("Set<String?> nullableSet = {'hello', null, 'world'};"),
        );
        expect(
          dartCode,
          contains(
            'String? firstNonNull = nullableList.firstWhere((x) => x != null, orElse: () => null);',
          ),
        );
        expect(
          dartCode,
          contains("int? valueOrNull = nullableMap['missing'];"),
        );
        expect(
          dartCode,
          contains('bool hasNull = nullableList.contains(null);'),
        );
      });

      test('handles very large collections', () {
        final largeList = List.generate(10000, (final i) => i).join(',');
        final dpugCode = 'List<int> largeList = [$largeList]';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> largeList = ['));
        expect(dartCode, contains('0,1,2,3,4,5,6,7,8,9,'));
      });

      test('handles deeply nested collections', () {
        const dpugCode = '''
List<List<List<int>>> deeplyNested = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]
Map<String, Map<String, List<int>>> nestedMap = {
  'group1': {
    'subgroup1': [1, 2, 3],
    'subgroup2': [4, 5, 6]
  },
  'group2': {
    'subgroup1': [7, 8, 9],
    'subgroup2': [10, 11, 12]
  }
}
Set<Set<int>> setOfSets = {{1, 2, 3}, {3, 4, 5}, {5, 6, 7}}
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'List<List<List<int>>> deeplyNested = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]];',
          ),
        );
        expect(
          dartCode,
          contains('Map<String, Map<String, List<int>>> nestedMap = {'),
        );
        expect(dartCode, contains("'group1': {"));
        expect(dartCode, contains("'subgroup1': [1, 2, 3],"));
        expect(
          dartCode,
          contains(
            'Set<Set<int>> setOfSets = {{1, 2, 3}, {3, 4, 5}, {5, 6, 7}};',
          ),
        );
      });

      test('handles collection operations that might fail', () {
        const dpugCode = '''
List<int> numbers = [1, 2, 3]
int firstOrDefault = numbers.firstOrNull ?? -1
int lastOrDefault = numbers.lastOrNull ?? -1
int singleOrDefault = numbers.singleOrNull ?? -1

List<int> empty = []
int? emptyFirst = empty.firstOrNull
int? emptyLast = empty.lastOrNull
int? emptySingle = empty.singleOrNull

// Operations that might throw on empty collections
bool isEmpty = numbers.isEmpty
bool isNotEmpty = numbers.isNotEmpty
int length = numbers.length
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> numbers = [1, 2, 3];'));
        expect(
          dartCode,
          contains('int firstOrDefault = numbers.firstOrNull ?? -1;'),
        );
        expect(
          dartCode,
          contains('int lastOrDefault = numbers.lastOrNull ?? -1;'),
        );
        expect(
          dartCode,
          contains('int singleOrDefault = numbers.singleOrNull ?? -1;'),
        );
        expect(dartCode, contains('List<int> empty = [];'));
        expect(dartCode, contains('int? emptyFirst = empty.firstOrNull;'));
        expect(dartCode, contains('int? emptyLast = empty.lastOrNull;'));
        expect(dartCode, contains('int? emptySingle = empty.singleOrNull;'));
        expect(dartCode, contains('bool isEmpty = numbers.isEmpty;'));
        expect(dartCode, contains('bool isNotEmpty = numbers.isNotEmpty;'));
        expect(dartCode, contains('int length = numbers.length;'));
      });

      test('handles out of bounds access patterns', () {
        const dpugCode = '''
List<int> numbers = [10, 20, 30]
Map<String, int> map = {'a': 1, 'b': 2}

int? safeGet(List<int> list, int index) => index < list.length ? list[index] : null
int? safeGetMap(Map<String, int> map, String key) => map[key]

int? outOfBounds1 = safeGet(numbers, 5)
int? outOfBounds2 = safeGet(numbers, -1)
int? missingKey = safeGetMap(map, 'missing')
int? existingKey = safeGetMap(map, 'a')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> numbers = [10, 20, 30];'));
        expect(dartCode, contains("Map<String, int> map = {'a': 1, 'b': 2};"));
        expect(
          dartCode,
          contains(
            'int? safeGet(List<int> list, int index) => index < list.length ? list[index] : null;',
          ),
        );
        expect(
          dartCode,
          contains(
            'int? safeGetMap(Map<String, int> map, String key) => map[key];',
          ),
        );
        expect(dartCode, contains('int? outOfBounds1 = safeGet(numbers, 5);'));
        expect(dartCode, contains('int? outOfBounds2 = safeGet(numbers, -1);'));
        expect(
          dartCode,
          contains("int? missingKey = safeGetMap(map, 'missing');"),
        );
        expect(dartCode, contains("int? existingKey = safeGetMap(map, 'a');"));
      });

      test('handles concurrent collection access patterns', () {
        const dpugCode = '''
List<int> sharedList = [1, 2, 3, 4, 5]
Map<String, int> sharedMap = {'key1': 10, 'key2': 20}
Set<String> sharedSet = {'a', 'b', 'c'}

// Concurrent access patterns
int listLength = sharedList.length
bool listContains = sharedList.contains(3)
List<int> listCopy = List.from(sharedList)

int mapSize = sharedMap.length
bool mapContains = sharedMap.containsKey('key1')
List<String> mapKeys = sharedMap.keys.toList()

int setSize = sharedSet.length
bool setContains = sharedSet.contains('a')
Set<String> setCopy = Set.from(sharedSet)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> sharedList = [1, 2, 3, 4, 5];'));
        expect(
          dartCode,
          contains("Map<String, int> sharedMap = {'key1': 10, 'key2': 20};"),
        );
        expect(dartCode, contains("Set<String> sharedSet = {'a', 'b', 'c'};"));
        expect(dartCode, contains('int listLength = sharedList.length;'));
        expect(
          dartCode,
          contains('bool listContains = sharedList.contains(3);'),
        );
        expect(
          dartCode,
          contains('List<int> listCopy = List.from(sharedList);'),
        );
        expect(dartCode, contains('int mapSize = sharedMap.length;'));
        expect(
          dartCode,
          contains("bool mapContains = sharedMap.containsKey('key1');"),
        );
        expect(
          dartCode,
          contains('List<String> mapKeys = sharedMap.keys.toList();'),
        );
        expect(dartCode, contains('int setSize = sharedSet.length;'));
        expect(
          dartCode,
          contains("bool setContains = sharedSet.contains('a');"),
        );
        expect(
          dartCode,
          contains('Set<String> setCopy = Set.from(sharedSet);'),
        );
      });

      test('handles collection modification during iteration patterns', () {
        const dpugCode =
            'List<int> numbers = [1, 2, 3, 4, 5]\n'
            'List<int> safeCopy = List.from(numbers)\n\n'
            'void safeIterate(List<int> list)\n'
            '  for int i = 0; i < list.length; i++\n'
            '    if list[i] % 2 == 0\n'
            "      // This is safe because we're iterating over a copy\n"
            "      print 'Even number: \${list[i]}'\n\n"
            'void unsafeIterate(List<int> list)\n'
            '  for int i = 0; i < list.length; i++\n'
            '    if list[i] == 3\n'
            '      // This could cause issues in real iteration\n'
            '      list.removeAt(i)\n\n'
            'safeIterate(safeCopy)\n'
            'unsafeIterate(numbers)';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('List<int> numbers = [1, 2, 3, 4, 5];'));
        expect(dartCode, contains('List<int> safeCopy = List.from(numbers);'));
        expect(dartCode, contains('void safeIterate(List<int> list) {'));
        expect(dartCode, contains('for (int i = 0; i < list.length; i++) {'));
        expect(dartCode, contains('if (list[i] % 2 == 0) {'));
        expect(dartCode, contains('void unsafeIterate(List<int> list) {'));
        expect(dartCode, contains('if (list[i] == 3) {'));
        expect(dartCode, contains('list.removeAt(i);'));
        expect(dartCode, contains('safeIterate(safeCopy);'));
        expect(dartCode, contains('unsafeIterate(numbers);'));
      });

      test('handles resource cleanup with collections', () {
        const dpugCode =
            'StreamController<List<int>> listController = StreamController<List<int>>()\n'
            'StreamController<Map<String, int>> mapController = StreamController<Map<String, int>>()\n\n'
            'List<StreamSubscription> subscriptions = []\n\n'
            'void initStreams()\n'
            '  subscriptions.add(\n'
            "    listController.stream.listen((data) => print('Received list: \$data'))\n"
            '  )\n'
            '  subscriptions.add(\n'
            "    mapController.stream.listen((data) => print('Received map: \$data'))\n"
            '  )\n\n'
            'void cleanupStreams()\n'
            '  for StreamSubscription sub in subscriptions\n'
            '    sub.cancel()\n'
            '  subscriptions.clear()\n'
            '  listController.close()\n'
            '  mapController.close()\n\n'
            'void addData()\n'
            '  listController.add([1, 2, 3])\n'
            "  mapController.add({'a': 1, 'b': 2})";

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains(
            'StreamController<List<int>> listController = StreamController<List<int>>();',
          ),
        );
        expect(
          dartCode,
          contains(
            'StreamController<Map<String, int>> mapController = StreamController<Map<String, int>>();',
          ),
        );
        expect(
          dartCode,
          contains('List<StreamSubscription> subscriptions = [];'),
        );
        expect(dartCode, contains('void initStreams() {'));
        expect(dartCode, contains('subscriptions.add('));
        expect(
          dartCode,
          contains(
            r"listController.stream.listen((data) => print('Received list: $data'))",
          ),
        );
        expect(dartCode, contains('void cleanupStreams() {'));
        expect(
          dartCode,
          contains('for (StreamSubscription sub in subscriptions) {'),
        );
        expect(dartCode, contains('sub.cancel();'));
        expect(dartCode, contains('subscriptions.clear();'));
        expect(dartCode, contains('listController.close();'));
        expect(dartCode, contains('mapController.close();'));
        expect(dartCode, contains('void addData() {'));
        expect(dartCode, contains('listController.add([1, 2, 3]);'));
        expect(dartCode, contains("mapController.add({'a': 1, 'b': 2});"));
      });

      test('handles collection transformations and chaining', () {
        const dpugCode = '''
List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

// Complex chaining operations
List<int> complexChain = numbers
  .where((n) => n % 2 == 0)
  .map((n) => n * n)
  .where((n) => n > 10)
  .toList()

Map<int, String> numberMap = numbers
  .where((n) => n % 3 == 0)
  .map((n) => MapEntry(n, n.toString()))
  .toMap()

Set<int> numberSet = numbers
  .where((n) => n > 5)
  .toSet()

List<List<int>> grouped = numbers
  .groupBy((n) => n % 3)
  .values
  .toList()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];'),
        );
        expect(dartCode, contains('List<int> complexChain = numbers'));
        expect(dartCode, contains('.where((n) => n % 2 == 0)'));
        expect(dartCode, contains('.map((n) => n * n)'));
        expect(dartCode, contains('.where((n) => n > 10)'));
        expect(dartCode, contains('.toList();'));
        expect(dartCode, contains('Map<int, String> numberMap = numbers'));
        expect(dartCode, contains('.where((n) => n % 3 == 0)'));
        expect(dartCode, contains('.map((n) => MapEntry(n, n.toString()))'));
        expect(dartCode, contains('.toMap();'));
        expect(dartCode, contains('Set<int> numberSet = numbers'));
        expect(dartCode, contains('.where((n) => n > 5)'));
        expect(dartCode, contains('.toSet();'));
        expect(dartCode, contains('List<List<int>> grouped = numbers'));
        expect(dartCode, contains('.groupBy((n) => n % 3)'));
        expect(dartCode, contains('.values'));
        expect(dartCode, contains('.toList();'));
      });

      test('handles collection sorting and ordering', () {
        const dpugCode = '''
List<int> numbers = [3, 1, 4, 1, 5, 9, 2, 6]
List<String> words = ['zebra', 'apple', 'banana', 'cherry']

List<int> ascending = numbers.sorted((a, b) => a.compareTo(b))
List<int> descending = numbers.sorted((a, b) => b.compareTo(a))
List<String> alphabetical = words.sorted((a, b) => a.compareTo(b))
List<String> reverseAlpha = words.sorted((a, b) => b.compareTo(a))

List<int> evenFirst = numbers.sorted((a, b) {
  if a % 2 == 0 && b % 2 != 0 return -1
  if a % 2 != 0 && b % 2 == 0 return 1
  return a.compareTo(b)
})

List<String> byLength = words.sorted((a, b) => a.length.compareTo(b.length))
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('List<int> numbers = [3, 1, 4, 1, 5, 9, 2, 6];'),
        );
        expect(
          dartCode,
          contains(
            "List<String> words = ['zebra', 'apple', 'banana', 'cherry'];",
          ),
        );
        expect(
          dartCode,
          contains(
            'List<int> ascending = numbers.sorted((a, b) => a.compareTo(b));',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<int> descending = numbers.sorted((a, b) => b.compareTo(a));',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<String> alphabetical = words.sorted((a, b) => a.compareTo(b));',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<String> reverseAlpha = words.sorted((a, b) => b.compareTo(a));',
          ),
        );
        expect(
          dartCode,
          contains('List<int> evenFirst = numbers.sorted((a, b) {'),
        );
        expect(dartCode, contains('if (a % 2 == 0 && b % 2 != 0) return -1;'));
        expect(dartCode, contains('if (a % 2 != 0 && b % 2 == 0) return 1;'));
        expect(dartCode, contains('return a.compareTo(b);'));
        expect(
          dartCode,
          contains(
            'List<String> byLength = words.sorted((a, b) => a.length.compareTo(b.length));',
          ),
        );
      });

      test('handles collection partitioning and splitting', () {
        const dpugCode = '''
List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
List<String> words = ['hello', 'world', 'apple', 'banana', 'cat', 'dog']

// Partition by predicate
List<List<int>> evenOdd = numbers.partition((n) => n % 2 == 0)
List<int> evenNumbers = evenOdd[0]
List<int> oddNumbers = evenOdd[1]

// Partition by length
List<List<String>> shortLong = words.partition((word) => word.length <= 3)
List<String> shortWords = shortLong[0]
List<String> longWords = shortLong[1]

// Split into chunks
List<List<int>> chunks = numbers.chunk(3)
List<List<String>> wordChunks = words.chunk(2)

// Group by criteria
Map<int, List<int>> byParity = numbers.groupBy((n) => n % 2)
Map<int, List<String>> byLength = words.groupBy((word) => word.length)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];'),
        );
        expect(
          dartCode,
          contains(
            "List<String> words = ['hello', 'world', 'apple', 'banana', 'cat', 'dog'];",
          ),
        );
        expect(
          dartCode,
          contains(
            'List<List<int>> evenOdd = numbers.partition((n) => n % 2 == 0);',
          ),
        );
        expect(dartCode, contains('List<int> evenNumbers = evenOdd[0];'));
        expect(dartCode, contains('List<int> oddNumbers = evenOdd[1];'));
        expect(
          dartCode,
          contains(
            'List<List<String>> shortLong = words.partition((word) => word.length <= 3);',
          ),
        );
        expect(dartCode, contains('List<String> shortWords = shortLong[0];'));
        expect(dartCode, contains('List<String> longWords = shortLong[1];'));
        expect(
          dartCode,
          contains('List<List<int>> chunks = numbers.chunk(3);'),
        );
        expect(
          dartCode,
          contains('List<List<String>> wordChunks = words.chunk(2);'),
        );
        expect(
          dartCode,
          contains(
            'Map<int, List<int>> byParity = numbers.groupBy((n) => n % 2);',
          ),
        );
        expect(
          dartCode,
          contains(
            'Map<int, List<String>> byLength = words.groupBy((word) => word.length);',
          ),
        );
      });

      test('handles collection search and find operations', () {
        const dpugCode = '''
List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
List<String> words = ['hello', 'world', 'apple', 'banana', 'cat', 'dog']

// Find operations
int? firstEven = numbers.firstWhereOrNull((n) => n % 2 == 0)
int? lastEven = numbers.lastWhereOrNull((n) => n % 2 == 0)
int? singleEven = numbers.singleWhereOrNull((n) => n == 4)
int? noMatch = numbers.firstWhereOrNull((n) => n > 100)

String? longWord = words.firstWhereOrNull((word) => word.length > 5)
String? shortWord = words.firstWhereOrNull((word) => word.length < 3)
String? appleWord = words.firstWhereOrNull((word) => word == 'apple')

// Index operations
int? firstEvenIndex = numbers.indexWhere((n) => n % 2 == 0)
int? lastEvenIndex = numbers.lastIndexWhere((n) => n % 2 == 0)
int? appleIndex = words.indexWhere((word) => word == 'apple')
int? missingIndex = words.indexWhere((word) => word == 'missing')
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];'),
        );
        expect(
          dartCode,
          contains(
            "List<String> words = ['hello', 'world', 'apple', 'banana', 'cat', 'dog'];",
          ),
        );
        expect(
          dartCode,
          contains(
            'int? firstEven = numbers.firstWhereOrNull((n) => n % 2 == 0);',
          ),
        );
        expect(
          dartCode,
          contains(
            'int? lastEven = numbers.lastWhereOrNull((n) => n % 2 == 0);',
          ),
        );
        expect(
          dartCode,
          contains(
            'int? singleEven = numbers.singleWhereOrNull((n) => n == 4);',
          ),
        );
        expect(
          dartCode,
          contains('int? noMatch = numbers.firstWhereOrNull((n) => n > 100);'),
        );
        expect(
          dartCode,
          contains(
            'String? longWord = words.firstWhereOrNull((word) => word.length > 5);',
          ),
        );
        expect(
          dartCode,
          contains(
            'String? shortWord = words.firstWhereOrNull((word) => word.length < 3);',
          ),
        );
        expect(
          dartCode,
          contains(
            "String? appleWord = words.firstWhereOrNull((word) => word == 'apple');",
          ),
        );
        expect(
          dartCode,
          contains(
            'int? firstEvenIndex = numbers.indexWhere((n) => n % 2 == 0);',
          ),
        );
        expect(
          dartCode,
          contains(
            'int? lastEvenIndex = numbers.lastIndexWhere((n) => n % 2 == 0);',
          ),
        );
        expect(
          dartCode,
          contains(
            "int? appleIndex = words.indexWhere((word) => word == 'apple');",
          ),
        );
        expect(
          dartCode,
          contains(
            "int? missingIndex = words.indexWhere((word) => word == 'missing');",
          ),
        );
      });

      test('handles collection type casting and conversion', () {
        const dpugCode = '''
List<dynamic> dynamicList = [1, 'hello', 3.14, true]
List<int> intList = dynamicList.whereType<int>().toList()
List<String> stringList = dynamicList.whereType<String>().toList()
List<double> doubleList = dynamicList.whereType<double>().toList()
List<bool> boolList = dynamicList.whereType<bool>().toList()

Map<dynamic, dynamic> dynamicMap = {'a': 1, 'b': 'hello', 'c': 3.14}
Map<String, int> stringIntMap = dynamicMap.whereType<String, int>()
Map<String, String> stringStringMap = dynamicMap.whereType<String, String>()

List<num> numbers = [1, 2.5, 3, 4.0]
List<int> ints = numbers.whereType<int>().toList()
List<double> doubles = numbers.whereType<double>().toList()

// Cast operations
List<Object?> objects = [1, 'hello', null]
List<String?> strings = objects.whereType<String?>().toList()
List<int?> nullableInts = objects.whereType<int?>().toList()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains("List<dynamic> dynamicList = [1, 'hello', 3.14, true];"),
        );
        expect(
          dartCode,
          contains(
            'List<int> intList = dynamicList.whereType<int>().toList();',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<String> stringList = dynamicList.whereType<String>().toList();',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<double> doubleList = dynamicList.whereType<double>().toList();',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<bool> boolList = dynamicList.whereType<bool>().toList();',
          ),
        );
        expect(
          dartCode,
          contains(
            "Map<dynamic, dynamic> dynamicMap = {'a': 1, 'b': 'hello', 'c': 3.14};",
          ),
        );
        expect(
          dartCode,
          contains(
            'Map<String, int> stringIntMap = dynamicMap.whereType<String, int>();',
          ),
        );
        expect(
          dartCode,
          contains(
            'Map<String, String> stringStringMap = dynamicMap.whereType<String, String>();',
          ),
        );
        expect(dartCode, contains('List<num> numbers = [1, 2.5, 3, 4.0];'));
        expect(
          dartCode,
          contains('List<int> ints = numbers.whereType<int>().toList();'),
        );
        expect(
          dartCode,
          contains(
            'List<double> doubles = numbers.whereType<double>().toList();',
          ),
        );
        expect(
          dartCode,
          contains("List<Object?> objects = [1, 'hello', null];"),
        );
        expect(
          dartCode,
          contains(
            'List<String?> strings = objects.whereType<String?>().toList();',
          ),
        );
        expect(
          dartCode,
          contains(
            'List<int?> nullableInts = objects.whereType<int?>().toList();',
          ),
        );
      });

      test('handles collection memory management patterns', () {
        const dpugCode = '''
// Weak collections (conceptual)
Map<String, dynamic> cache = {}
List<WeakReference> weakRefs = []

void addToCache(String key, dynamic value)
  if cache.length > 100
    cache.clear()  // Simple cleanup strategy
  cache[key] = value

void cleanupWeakRefs()
  weakRefs.removeWhere((ref) => ref.target == null)

dynamic getFromCache(String key) => cache[key]

void clearCache() => cache.clear()

// Memory-efficient operations
List<int> processLargeList(List<int> data)
  // Process in chunks to manage memory
  List<int> result = []
  for int i = 0; i < data.length; i += 1000
    int end = (i + 1000).clamp(0, data.length)
    List<int> chunk = data.sublist(i, end)
    result.addAll(chunk.map((n) => n * 2).toList())
  return result
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('Map<String, dynamic> cache = {};'));
        expect(dartCode, contains('List<WeakReference> weakRefs = [];'));
        expect(
          dartCode,
          contains('void addToCache(String key, dynamic value) {'),
        );
        expect(dartCode, contains('if (cache.length > 100) {'));
        expect(dartCode, contains('cache.clear();'));
        expect(dartCode, contains('cache[key] = value;'));
        expect(dartCode, contains('void cleanupWeakRefs() {'));
        expect(
          dartCode,
          contains('weakRefs.removeWhere((ref) => ref.target == null);'),
        );
        expect(
          dartCode,
          contains('dynamic getFromCache(String key) => cache[key];'),
        );
        expect(dartCode, contains('void clearCache() => cache.clear();'));
        expect(
          dartCode,
          contains('List<int> processLargeList(List<int> data) {'),
        );
        expect(dartCode, contains('List<int> result = [];'));
        expect(
          dartCode,
          contains('for (int i = 0; i < data.length; i += 1000) {'),
        );
        expect(
          dartCode,
          contains('int end = (i + 1000).clamp(0, data.length);'),
        );
        expect(dartCode, contains('List<int> chunk = data.sublist(i, end);'));
        expect(
          dartCode,
          contains('result.addAll(chunk.map((n) => n * 2).toList());'),
        );
        expect(dartCode, contains('return result;'));
      });
    });
  });
}
