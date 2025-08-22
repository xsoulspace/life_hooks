// DPug Language Specification: Collections

DPug provides concise syntax for working with Dart's collection types: Lists, Maps, and Sets.

## Lists

```dpug
// Basic list creation
List<int> numbers = [1, 2, 3, 4, 5]
List<String> names = ['Alice', 'Bob', 'Charlie']
List<dynamic> mixed = [1, 'text', true]

// Empty lists
List<int> emptyInts = []
List<String> emptyStrings = <String>[]

// List operations
List<int> doubled = numbers.map((n) => n * 2).toList()
List<String> filtered = names.where((name) => name.length > 3).toList()

// Adding elements
numbers.add(6)
numbers.addAll([7, 8, 9])

// Spread operator
List<int> combined = [0, ...numbers, 10]
List<int> conditional = [1, 2, if showMore ...[3, 4, 5], 6]

// List comprehension style
List<int> squares = [for int i in 1..5 i * i]
List<String> upperNames = [for String name in names name.toUpperCase()]
```

## Maps

```dpug
// Basic map creation
Map<String, int> ages = {'Alice': 25, 'Bob': 30, 'Charlie': 35}
Map<String, dynamic> user = {
  'id': 1,
  'name': 'John',
  'email': 'john@example.com'
}

// Empty maps
Map<String, String> emptyMap = {}
Map<int, bool> flags = <int, bool>{}

// Map operations
int? aliceAge = ages['Alice']
ages['David'] = 28
ages.remove('Bob')

// Map methods
List<String> keys = ages.keys.toList()
List<int> values = ages.values.toList()
bool hasAlice = ages.containsKey('Alice')
bool hasValue30 = ages.containsValue(30)

// Spread operator
Map<String, int> updatedAges = {
  ...ages,
  'Eve': 22,
  if showExtra 'Frank': 40
}

// Map comprehension style
Map<String, int> nameLengths = {
  for String name in names
  name: name.length
}
```

## Sets

```dpug
// Basic set creation
Set<int> numbers = {1, 2, 3, 4, 5}
Set<String> uniqueNames = {'Alice', 'Bob', 'Alice'}  // Results in: Alice, Bob
Set<dynamic> mixedSet = {1, 'text', true}

// Empty sets
Set<String> emptySet = {}
Set<int> intSet = <int>{}

// Set operations
numbers.add(6)
numbers.remove(3)
bool containsFive = numbers.contains(5)

// Set methods
Set<int> evens = numbers.where((n) => n % 2 == 0).toSet()
int count = numbers.length

// Set operations (union, intersection, difference)
Set<int> setA = {1, 2, 3, 4}
Set<int> setB = {3, 4, 5, 6}

Set<int> union = setA.union(setB)           // {1, 2, 3, 4, 5, 6}
Set<int> intersection = setA.intersection(setB)  // {3, 4}
Set<int> difference = setA.difference(setB)      // {1, 2}
```

## Iterables and Collections

```dpug
// Working with iterables
Iterable<int> range = 1..100
Iterable<String> filtered = names.where((name) => name.startsWith('A'))

// Converting between types
List<int> listFromSet = numbers.toList()
Set<String> setFromList = names.toSet()
Map<String, int> mapFromEntries = Map.fromEntries(
  names.map((name) => MapEntry(name, name.length))
)

// Common collection patterns
bool allPositive = numbers.every((n) => n > 0)
bool anyEven = numbers.any((n) => n % 2 == 0)
int first = numbers.first
int last = numbers.last
int? firstOrNull = numbers.firstOrNull
int sum = numbers.fold(0, (prev, n) => prev + n)
```

## Collection Literals with Type Inference

```dpug
// Type is inferred from context
var numbers = [1, 2, 3, 4, 5]           // List<int>
var names = ['Alice', 'Bob']            // List<String>
var mapping = {'a': 1, 'b': 2}          // Map<String, int>
var unique = {1, 2, 3}                  // Set<int>

// Mixed types require explicit typing
List<dynamic> mixed = [1, 'text', true]
Map<String, dynamic> flexible = {
  'number': 42,
  'text': 'hello',
  'flag': true
}
```

## Advanced Collection Operations

```dpug
// Chaining operations
List<String> result = names
  .where((name) => name.length > 3)
  .map((name) => name.toUpperCase())
  .toList()

// Grouping
Map<int, List<String>> byLength = names.groupBy((name) => name.length)

// Sorting
List<String> sorted = names.sorted((a, b) => a.compareTo(b))
List<int> descending = numbers.sorted((a, b) => b.compareTo(a))

// Partitioning
List<List<String>> parts = names.partition((name) => name.length > 3)
// parts[0] = names where length <= 3
// parts[1] = names where length > 3
```
