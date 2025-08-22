import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Annotations Conversion', () {
    final converter = DpugConverter();

    group('Basic Annotations', () {
      test('converts simple annotations', () {
        const dpugCode = '''
@deprecated
void oldFunction() => print 'This function is deprecated'

@Deprecated('Use newFunction instead')
void anotherOldFunction() => print 'Also deprecated with message'

@override
void customImplementation() => print 'Overriding parent method'

@visibleForTesting
String internalHelper() => 'Internal helper'

@protected
int protectedField = 42

@mustCallSuper
void lifecycleMethod() => print 'Lifecycle method'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@deprecated'));
        expect(
          dartCode,
          contains(
            "void oldFunction() => print('This function is deprecated');",
          ),
        );
        expect(dartCode, contains("@Deprecated('Use newFunction instead')"));
        expect(
          dartCode,
          contains(
            "void anotherOldFunction() => print('Also deprecated with message');",
          ),
        );
        expect(dartCode, contains('@override'));
        expect(
          dartCode,
          contains(
            "void customImplementation() => print('Overriding parent method');",
          ),
        );
        expect(dartCode, contains('@visibleForTesting'));
        expect(
          dartCode,
          contains("String internalHelper() => 'Internal helper';"),
        );
        expect(dartCode, contains('@protected'));
        expect(dartCode, contains('int protectedField = 42;'));
        expect(dartCode, contains('@mustCallSuper'));
        expect(
          dartCode,
          contains("void lifecycleMethod() => print('Lifecycle method');"),
        );
      });
    });

    group('Class Annotations', () {
      test('converts class-level annotations', () {
        const dpugCode = '''
@JsonSerializable()
@Entity()
@Table(name: 'users')
class User
  @Id()
  @GeneratedValue()
  int id

  @Column(name: 'username', nullable: false)
  String username

  @Column(name: 'email')
  String email

  User(this.id, this.username, this.email)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@JsonSerializable()'));
        expect(dartCode, contains('@Entity()'));
        expect(dartCode, contains("@Table(name: 'users')"));
        expect(dartCode, contains('class User {'));
        expect(dartCode, contains('@Id()'));
        expect(dartCode, contains('@GeneratedValue()'));
        expect(dartCode, contains('int id;'));
        expect(
          dartCode,
          contains("@Column(name: 'username', nullable: false)"),
        );
        expect(dartCode, contains('String username;'));
        expect(dartCode, contains("@Column(name: 'email')"));
        expect(dartCode, contains('String email;'));
      });

      test('converts complex annotation parameters', () {
        const dpugCode = r'''
@Route('/users/:id', methods: ['GET', 'POST'])
@Controller('/api')
class UserController
  @GetMapping('/profile')
  void getProfile() => print 'Getting profile'

  @PostMapping('/update')
  @RequestBody()
  void updateUser(@PathVariable('id') String id, @RequestParam('name') String name) =>
    print 'Updating user $id with name $name'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains("@Route('/users/:id', methods: ['GET', 'POST'])"),
        );
        expect(dartCode, contains("@Controller('/api')"));
        expect(dartCode, contains('class UserController {'));
        expect(dartCode, contains("@GetMapping('/profile')"));
        expect(
          dartCode,
          contains("void getProfile() => print('Getting profile');"),
        );
        expect(dartCode, contains("@PostMapping('/update')"));
        expect(dartCode, contains('@RequestBody()'));
        expect(
          dartCode,
          contains(
            "void updateUser(@PathVariable('id') String id, @RequestParam('name') String name) =>",
          ),
        );
        expect(
          dartCode,
          contains(r"print('Updating user $id with name $name');"),
        );
      });
    });

    group('Method Annotations', () {
      test('converts method-level annotations', () {
        const dpugCode = '''
class ApiService
  @GetMapping('/users')
  Future<List<User>> getUsers() async => await userRepository.findAll()

  @PostMapping('/users')
  @RequestBody()
  Future<User> createUser(@Valid() User user) async =>
    await userRepository.save(user)

  @GetMapping('/users/{id}')
  Future<User> getUser(@PathVariable('id') String id) async =>
    await userRepository.findById(id)

  @DeleteMapping('/users/{id}')
  @ResponseStatus(HttpStatus.NO_CONTENT)
  Future<void> deleteUser(@PathVariable('id') String id) async =>
    await userRepository.deleteById(id)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ApiService {'));
        expect(dartCode, contains("@GetMapping('/users')"));
        expect(
          dartCode,
          contains(
            'Future<List<User>> getUsers() async => await userRepository.findAll();',
          ),
        );
        expect(dartCode, contains("@PostMapping('/users')"));
        expect(dartCode, contains('@RequestBody()'));
        expect(
          dartCode,
          contains('Future<User> createUser(@Valid() User user) async =>'),
        );
        expect(dartCode, contains("@GetMapping('/users/{id}')"));
        expect(
          dartCode,
          contains(
            "Future<User> getUser(@PathVariable('id') String id) async =>",
          ),
        );
        expect(dartCode, contains("@DeleteMapping('/users/{id}')"));
        expect(dartCode, contains('@ResponseStatus(HttpStatus.NO_CONTENT)'));
        expect(
          dartCode,
          contains(
            "Future<void> deleteUser(@PathVariable('id') String id) async =>",
          ),
        );
      });
    });

    group('Dependency Injection Annotations', () {
      test('converts DI annotations', () {
        const dpugCode = '''
@Component()
class UserService
  @Autowired()
  UserRepository userRepository

  @Autowired()
  EmailService emailService

  UserService()

@Service()
class UserRepository
  @Autowired()
  DatabaseConfig config

  UserRepository()

@Controller()
class UserController
  @Autowired()
  UserService userService

  UserController()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@Component()'));
        expect(dartCode, contains('class UserService {'));
        expect(dartCode, contains('@Autowired()'));
        expect(dartCode, contains('UserRepository userRepository;'));
        expect(dartCode, contains('EmailService emailService;'));
        expect(dartCode, contains('@Service()'));
        expect(dartCode, contains('class UserRepository {'));
        expect(dartCode, contains('@Autowired()'));
        expect(dartCode, contains('DatabaseConfig config;'));
        expect(dartCode, contains('@Controller()'));
        expect(dartCode, contains('class UserController {'));
        expect(dartCode, contains('@Autowired()'));
        expect(dartCode, contains('UserService userService;'));
      });

      test('converts Spring-style annotations', () {
        const dpugCode = '''
@RestController()
@RequestMapping('/api/v1')
class ProductController
  @Autowired()
  ProductService productService

  @GetMapping('/products')
  @ResponseBody()
  List<Product> getAllProducts() => productService.findAll()

  @GetMapping('/products/{id}')
  @ResponseBody()
  Product getProduct(@PathVariable('id') Long id) =>
    productService.findById(id)

  @PostMapping('/products')
  @RequestBody()
  @Valid()
  Product createProduct(@RequestBody() @Valid() Product product) =>
    productService.save(product)

  @PutMapping('/products/{id}')
  @RequestBody()
  Product updateProduct(@PathVariable('id') Long id, @RequestBody() @Valid() Product product) =>
    productService.update(id, product)

  @DeleteMapping('/products/{id}')
  @ResponseStatus(HttpStatus.NO_CONTENT)
  void deleteProduct(@PathVariable('id') Long id) =>
    productService.deleteById(id)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@RestController()'));
        expect(dartCode, contains("@RequestMapping('/api/v1')"));
        expect(dartCode, contains('class ProductController {'));
        expect(dartCode, contains('@Autowired()'));
        expect(dartCode, contains('ProductService productService;'));
        expect(dartCode, contains("@GetMapping('/products')"));
        expect(dartCode, contains('@ResponseBody()'));
        expect(
          dartCode,
          contains(
            'List<Product> getAllProducts() => productService.findAll();',
          ),
        );
        expect(dartCode, contains("@PostMapping('/products')"));
        expect(dartCode, contains('@RequestBody()'));
        expect(dartCode, contains('@Valid()'));
        expect(
          dartCode,
          contains(
            'Product createProduct(@RequestBody() @Valid() Product product) =>',
          ),
        );
        expect(dartCode, contains("@PutMapping('/products/{id}')"));
        expect(dartCode, contains("@DeleteMapping('/products/{id}')"));
      });
    });

    group('Validation Annotations', () {
      test('converts validation annotations', () {
        const dpugCode = r'''
class RegistrationForm
  @NotNull()
  @Size(min: 3, max: 50)
  String username

  @NotNull()
  @Email()
  String email

  @NotNull()
  @Min(18)
  @Max(120)
  int age

  @NotNull()
  @Pattern(regexp: r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
  String password

  @AssertTrue(message: 'Terms must be accepted')
  bool acceptTerms

  RegistrationForm(this.username, this.email, this.age, this.password, this.acceptTerms)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class RegistrationForm {'));
        expect(dartCode, contains('@NotNull()'));
        expect(dartCode, contains('@Size(min: 3, max: 50)'));
        expect(dartCode, contains('String username;'));
        expect(dartCode, contains('@Email()'));
        expect(dartCode, contains('String email;'));
        expect(dartCode, contains('@Min(18)'));
        expect(dartCode, contains('@Max(120)'));
        expect(dartCode, contains('int age;'));
        expect(
          dartCode,
          contains(
            r"@Pattern(regexp: r'^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$')",
          ),
        );
        expect(dartCode, contains('String password;'));
        expect(
          dartCode,
          contains("@AssertTrue(message: 'Terms must be accepted')"),
        );
        expect(dartCode, contains('bool acceptTerms;'));
        expect(
          dartCode,
          contains(
            'RegistrationForm(this.username, this.email, this.age, this.password, this.acceptTerms);',
          ),
        );
      });
    });

    group('State Management Annotations', () {
      test('converts Riverpod annotations', () {
        const dpugCode = r'''
@riverpod
class CounterNotifier extends _$CounterNotifier
  @override
  int build() => 0

  void increment() => state++
  void decrement() => state--

@riverpod
Future<List<User>> userList(UserListRef ref) async
  final userService = ref.watch(userServiceProvider)
  return await userService.fetchUsers()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@riverpod'));
        expect(
          dartCode,
          contains(r'class CounterNotifier extends _$CounterNotifier {'),
        );
        expect(dartCode, contains('@override'));
        expect(dartCode, contains('int build() => 0;'));
        expect(dartCode, contains('void increment() => state++;'));
        expect(dartCode, contains('void decrement() => state--;'));
        expect(dartCode, contains('@riverpod'));
        expect(
          dartCode,
          contains('Future<List<User>> userList(UserListRef ref) async {'),
        );
        expect(
          dartCode,
          contains('final userService = ref.watch(userServiceProvider);'),
        );
        expect(dartCode, contains('return await userService.fetchUsers();'));
      });

      test('converts Freezed annotations', () {
        const dpugCode = r'''
@freezed
class UserState with _$UserState
  const factory UserState.initial() = Initial
  const factory UserState.loading() = Loading
  const factory UserState.loaded(List<User> users) = Loaded
  const factory UserState.error(String message) = Error
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@freezed'));
        expect(dartCode, contains(r'class UserState with _$UserState {'));
        expect(
          dartCode,
          contains('const factory UserState.initial() = Initial;'),
        );
        expect(
          dartCode,
          contains('const factory UserState.loading() = Loading;'),
        );
        expect(
          dartCode,
          contains(
            'const factory UserState.loaded(List<User> users) = Loaded;',
          ),
        );
        expect(
          dartCode,
          contains('const factory UserState.error(String message) = Error;'),
        );
      });

      test('converts MobX annotations', () {
        const dpugCode = r'''
@observable
class TodoStore extends _$TodoStore
  @observable List<Todo> todos = []

  @observable String filter = 'all'

  @computed
  List<Todo> get filteredTodos
    switch filter
      case 'completed' => todos.where((todo) => todo.completed).toList()
      case 'active' => todos.where((todo) => !todo.completed).toList()
      default => todos

  @action
  void addTodo(String text)
    todos.add(Todo(text: text, completed: false))

  @action
  void toggleTodo(int id)
    final todo = todos.firstWhere((todo) => todo.id == id)
    todo.completed = !todo.completed

  @action
  void setFilter(String newFilter) => filter = newFilter
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@observable'));
        expect(dartCode, contains(r'class TodoStore extends _$TodoStore {'));
        expect(dartCode, contains('@observable List<Todo> todos = [];'));
        expect(dartCode, contains("@observable String filter = 'all';"));
        expect(dartCode, contains('@computed'));
        expect(dartCode, contains('List<Todo> get filteredTodos {'));
        expect(dartCode, contains('switch (filter) {'));
        expect(dartCode, contains("case 'completed':"));
        expect(dartCode, contains("case 'active':"));
        expect(dartCode, contains('default:'));
        expect(dartCode, contains('@action'));
        expect(dartCode, contains('void addTodo(String text) {'));
        expect(dartCode, contains('void toggleTodo(int id) {'));
        expect(
          dartCode,
          contains('void setFilter(String newFilter) => filter = newFilter;'),
        );
      });
    });

    group('Testing Annotations', () {
      test('converts test method annotations', () {
        const dpugCode = '''
@Test()
class UserServiceTest
  @Autowired()
  UserService userService

  @Test()
  void testCreateUser()
    User user = User('1', 'John', 'john@example.com')
    User created = userService.createUser(user)
    assert created.id == '1'

  @Test()
  @ExpectedException(ValidationException)
  void testCreateUserWithInvalidData()
    User invalidUser = User('', '', '')
    userService.createUser(invalidUser)

  @BeforeEach()
  void setUp()
    // Initialize test data
    userService.clearAll()

  @AfterEach()
  void tearDown()
    // Clean up test data
    userService.clearAll()
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@Test()'));
        expect(dartCode, contains('class UserServiceTest {'));
        expect(dartCode, contains('@Autowired()'));
        expect(dartCode, contains('UserService userService;'));
        expect(dartCode, contains('@Test()'));
        expect(dartCode, contains('void testCreateUser() {'));
        expect(
          dartCode,
          contains("User user = User('1', 'John', 'john@example.com');"),
        );
        expect(
          dartCode,
          contains('User created = userService.createUser(user);'),
        );
        expect(dartCode, contains("assert(created.id == '1');"));
        expect(dartCode, contains('@Test()'));
        expect(dartCode, contains('@ExpectedException(ValidationException)'));
        expect(dartCode, contains('void testCreateUserWithInvalidData() {'));
        expect(dartCode, contains("User invalidUser = User('', '', '');"));
        expect(dartCode, contains('userService.createUser(invalidUser);'));
        expect(dartCode, contains('@BeforeEach()'));
        expect(dartCode, contains('void setUp() {'));
        expect(dartCode, contains('userService.clearAll();'));
        expect(dartCode, contains('@AfterEach()'));
        expect(dartCode, contains('void tearDown() {'));
      });
    });

    group('Documentation Annotations', () {
      test('converts documentation annotations', () {
        const dpugCode = '''
/// A service for managing user operations
@Service()
class UserService
  /// Creates a new user with validation
  /// @param user The user to create
  /// @return The created user with generated ID
  /// @throws ValidationException if user data is invalid
  @Transactional()
  Future<User> createUser(@Valid() User user) async
    // Implementation here
    return user

  /// Finds a user by their ID
  /// @param id The user ID to search for
  /// @return The user if found, null otherwise
  @Cacheable('users')
  Future<User?> findById(@NotNull() String id) async
    // Implementation here
    return null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(
          dartCode,
          contains('/// A service for managing user operations'),
        );
        expect(dartCode, contains('@Service()'));
        expect(dartCode, contains('class UserService {'));
        expect(dartCode, contains('/// Creates a new user with validation'));
        expect(dartCode, contains('/// @param user The user to create'));
        expect(
          dartCode,
          contains('/// @return The created user with generated ID'),
        );
        expect(
          dartCode,
          contains('/// @throws ValidationException if user data is invalid'),
        );
        expect(dartCode, contains('@Transactional()'));
        expect(
          dartCode,
          contains('Future<User> createUser(@Valid() User user) async {'),
        );
        expect(dartCode, contains('/// Finds a user by their ID'));
        expect(dartCode, contains('/// @param id The user ID to search for'));
        expect(
          dartCode,
          contains('/// @return The user if found, null otherwise'),
        );
        expect(dartCode, contains("@Cacheable('users')"));
        expect(
          dartCode,
          contains('Future<User?> findById(@NotNull() String id) async {'),
        );
      });
    });

    group('Custom Annotations', () {
      test('converts custom annotation definitions', () {
        const dpugCode = '''
class Author
  final String name
  final String email

  const Author(this.name, this.email)

class Version
  final String number
  final String date

  const Version(this.number, {this.date = ''})
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class Author {'));
        expect(dartCode, contains('final String name;'));
        expect(dartCode, contains('final String email;'));
        expect(dartCode, contains('const Author(this.name, this.email);'));
        expect(dartCode, contains('class Version {'));
        expect(dartCode, contains('final String number;'));
        expect(dartCode, contains('final String date;'));
        expect(
          dartCode,
          contains("const Version(this.number, {this.date = ''});"),
        );
      });

      test('converts usage of custom annotations', () {
        const dpugCode = '''
@Author('John Doe', 'john@example.com')
@Version('1.0.0', date: '2024-01-15')
class TaskManager
  List<Todo> todos = []

  @Author('Jane Smith', 'jane@example.com')
  void addTodo(Todo todo) => todos.add(todo)

  @Version('1.1.0')
  void removeTodo(int index) => todos.removeAt(index)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("@Author('John Doe', 'john@example.com')"));
        expect(dartCode, contains("@Version('1.0.0', date: '2024-01-15')"));
        expect(dartCode, contains('class TaskManager {'));
        expect(dartCode, contains('List<Todo> todos = [];'));
        expect(dartCode, contains("@Author('Jane Smith', 'jane@example.com')"));
        expect(
          dartCode,
          contains('void addTodo(Todo todo) => todos.add(todo);'),
        );
        expect(dartCode, contains("@Version('1.1.0')"));
        expect(
          dartCode,
          contains('void removeTodo(int index) => todos.removeAt(index);'),
        );
      });
    });

    group('Round-trip Annotation Conversion', () {
      test('annotations maintain semantics through round-trip', () {
        const dpugCode = '''
@JsonSerializable()
@deprecated
class AnnotatedClass
  @JsonKey(name: 'user_id')
  @NotNull()
  String id

  @JsonKey(ignore: true)
  @observable
  String internalData

  @override
  @Transactional()
  Future<void> asyncMethod() async
    await Future.delayed(Duration(seconds: 1))

  @Test()
  void testMethod()
    assert id != null
''';

        final dartCode = converter.dpugToDart(dpugCode);
        final backToDpug = converter.dartToDpug(dartCode);

        // Should contain the key elements
        expect(backToDpug, contains('@JsonSerializable()'));
        expect(backToDpug, contains('@deprecated'));
        expect(backToDpug, contains('class AnnotatedClass'));
        expect(backToDpug, contains("@JsonKey(name: 'user_id')"));
        expect(backToDpug, contains('@NotNull()'));
        expect(backToDpug, contains('String id;'));
        expect(backToDpug, contains('@JsonKey(ignore: true)'));
        expect(backToDpug, contains('@observable'));
        expect(backToDpug, contains('String internalData;'));
        expect(backToDpug, contains('@override'));
        expect(backToDpug, contains('@Transactional()'));
        expect(backToDpug, contains('Future<void> asyncMethod() async'));
        expect(backToDpug, contains('@Test()'));
        expect(backToDpug, contains('void testMethod()'));
        expect(backToDpug, contains('assert id != null'));
      });
    });

    group('Annotation Edge Cases and Error Conditions', () {
      test('handles empty and malformed annotations', () {
        const dpugCode = '''
@ class EmptyAnnotation
  String field

class MalformedAnnotation
  @ String field1
  @( invalid: 'syntax' String field2
  @123Invalid int field3
  @[] List<int> field4
''';

        // Should handle gracefully or throw appropriate errors
        expect(() => converter.dpugToDart(dpugCode), returnsNormally);
      });

      test('handles very long annotation parameters', () {
        final longString = 'a' * 1000;
        final dpugCode = '''
@CustomAnnotation(
  veryLongParameter: '$longString',
  anotherLongOne: '$longString',
  nestedAnnotation: @Nested(param: '$longString')
)
class LongAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('veryLongParameter:'));
        expect(dartCode, contains('anotherLongOne:'));
        expect(dartCode, contains('nestedAnnotation:'));
        expect(dartCode, contains('@Nested'));
        expect(dartCode, contains('class LongAnnotationClass'));
      });

      test('handles deeply nested annotation parameters', () {
        const dpugCode = '''
@OuterAnnotation(
  param1: @MiddleAnnotation(
    param2: @InnerAnnotation(
      param3: @DeepAnnotation(
        param4: @VeryDeepAnnotation(
          value: 'deep value',
          number: 42
        ),
        list: [1, 2, @NestedInList(value: 'nested')]
      ),
      map: {'key': @NestedInMap(value: 'mapped')}
    ),
    array: [@ArrayAnnotation(value: 'array'), @AnotherArrayAnnotation(value: 'another')]
  )
)
class DeeplyNestedAnnotations
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@OuterAnnotation('));
        expect(dartCode, contains('@MiddleAnnotation('));
        expect(dartCode, contains('@InnerAnnotation('));
        expect(dartCode, contains('@DeepAnnotation('));
        expect(dartCode, contains('@VeryDeepAnnotation('));
        expect(dartCode, contains("value: 'deep value'"));
        expect(dartCode, contains('number: 42'));
        expect(dartCode, contains('@NestedInList'));
        expect(dartCode, contains('@NestedInMap'));
        expect(dartCode, contains('@ArrayAnnotation'));
        expect(dartCode, contains('class DeeplyNestedAnnotations'));
      });

      test('handles annotations with complex parameter types', () {
        const dpugCode = '''
@ComplexAnnotation(
  stringParam: 'hello',
  intParam: 42,
  doubleParam: 3.14,
  boolParam: true,
  nullParam: null,
  listParam: [1, 2, 'three', true, null],
  mapParam: {
    'string': 'value',
    'int': 42,
    'bool': true,
    'null': null,
    'nested': {'inner': 'value'}
  },
  functionParam: (String s) => s.toUpperCase(),
  typeParam: String,
  symbolParam: #symbol,
  durationParam: Duration(seconds: 30),
  colorParam: Colors.blue,
  iconParam: Icons.star
)
class ComplexAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@ComplexAnnotation('));
        expect(dartCode, contains("stringParam: 'hello'"));
        expect(dartCode, contains('intParam: 42'));
        expect(dartCode, contains('doubleParam: 3.14'));
        expect(dartCode, contains('boolParam: true'));
        expect(dartCode, contains('nullParam: null'));
        expect(dartCode, contains("listParam: [1, 2, 'three', true, null]"));
        expect(dartCode, contains('mapParam: {'));
        expect(dartCode, contains("'string': 'value'"));
        expect(dartCode, contains("'int': 42"));
        expect(dartCode, contains('functionParam:'));
        expect(dartCode, contains('typeParam: String'));
        expect(dartCode, contains('symbolParam: #symbol'));
        expect(dartCode, contains('durationParam: Duration(seconds: 30)'));
        expect(dartCode, contains('colorParam: Colors.blue'));
        expect(dartCode, contains('iconParam: Icons.star'));
        expect(dartCode, contains('class ComplexAnnotationClass'));
      });

      test('handles annotations with special characters and Unicode', () {
        const dpugCode = '''
@UnicodeAnnotation(
  emoji: '🚀🌟✨',
  accented: 'café naïve résumé',
  symbols: '©®™€£¥',
  mixed: 'Hello 世界 🌍',
  controlChars: '\u0000\u0001\u0002',
  newlines: 'line1\nline2\nline3',
  tabs: 'col1\tcol2\tcol3',
  quotes: 'He said "Hello" and 'Goodbye'',
  backslashes: 'path\\to\\file',
  regex: r'[a-zA-Z0-9]+',
  multiline: '''
    This is a
    multiline string
    with special chars: @#\$%^&*()
  '''
)
class UnicodeAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@UnicodeAnnotation('));
        expect(dartCode, contains("emoji: '🚀🌟✨'"));
        expect(dartCode, contains("accented: 'café naïve résumé'"));
        expect(dartCode, contains("symbols: '©®™€£¥'"));
        expect(dartCode, contains("mixed: 'Hello 世界 🌍'"));
        expect(dartCode, contains(r"controlChars: '\u0000\u0001\u0002'"));
        expect(dartCode, contains(r"newlines: 'line1\nline2\nline3'"));
        expect(dartCode, contains(r"tabs: 'col1\tcol2\tcol3'"));
        expect(dartCode, contains(r'''quotes: 'He said "Hello" and \'Goodbye\''''));
        expect(dartCode, contains(r"backslashes: 'path\\to\\file'"));
        expect(dartCode, contains("regex: r'[a-zA-Z0-9]+'"));
        expect(dartCode, contains('multiline:'));
        expect(dartCode, contains('This is a'));
        expect(dartCode, contains('multiline string'));
        expect(dartCode, contains('class UnicodeAnnotationClass'));
      });

      test('handles annotations with mathematical and logical expressions', () {
        const dpugCode = '''
@MathAnnotation(
  simpleMath: 1 + 2 * 3,
  complexMath: (1 + 2) * (3 - 4) / 5,
  booleanLogic: true && false || true,
  comparison: 1 > 0 && 2 < 3 && 4 >= 4 && 5 <= 5 && 6 == 6 && 7 != 8,
  nullCheck: value != null ? value : 'default',
  typeCheck: value is String ? value : 'not string',
  rangeCheck: value >= 0 && value <= 100,
  bitwise: (1 << 2) | (3 & 5) ^ (7 >> 1),
  ternary: condition ? 'true' : 'false'
)
class MathAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@MathAnnotation('));
        expect(dartCode, contains('simpleMath: 1 + 2 * 3'));
        expect(dartCode, contains('complexMath: (1 + 2) * (3 - 4) / 5'));
        expect(dartCode, contains('booleanLogic: true && false || true'));
        expect(dartCode, contains('comparison: 1 > 0 && 2 < 3 && 4 >= 4 && 5 <= 5 && 6 == 6 && 7 != 8'));
        expect(dartCode, contains("nullCheck: value != null ? value : 'default'"));
        expect(dartCode, contains("typeCheck: value is String ? value : 'not string'"));
        expect(dartCode, contains('rangeCheck: value >= 0 && value <= 100'));
        expect(dartCode, contains('bitwise: (1 << 2) | (3 & 5) ^ (7 >> 1)'));
        expect(dartCode, contains("ternary: condition ? 'true' : 'false'"));
        expect(dartCode, contains('class MathAnnotationClass'));
      });

      test('handles annotations with collection literals and comprehensions', () {
        const dpugCode = '''
@CollectionAnnotation(
  simpleList: [1, 2, 3, 4, 5],
  stringList: ['hello', 'world', 'test'],
  mixedList: [1, 'hello', true, null, 3.14],
  emptyList: [],
  nestedList: [[1, 2], [3, 4], [5, 6]],

  simpleMap: {'a': 1, 'b': 2, 'c': 3},
  stringMap: {'hello': 'world', 'foo': 'bar'},
  mixedMap: {'int': 42, 'string': 'value', 'bool': true},
  emptyMap: {},
  nestedMap: {'outer': {'inner': 'value'}},

  simpleSet: {1, 2, 3, 4, 5},
  stringSet: {'hello', 'world', 'test'},
  emptySet: {},

  listComprehension: [for int i in 1..10 if i % 2 == 0 i * 2],
  mapComprehension: {for String s in ['a', 'b', 'c'] s: s.toUpperCase()},
  setComprehension: {for int i in 1..10 if i % 3 == 0 i},

  spreadList: [0, ...[1, 2, 3], 4, ...[5, 6]],
  spreadMap: {'a': 1, ...{'b': 2, 'c': 3}, 'd': 4},
  conditionalCollection: [1, 2, if condition ...[3, 4, 5], 6]
)
class CollectionAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@CollectionAnnotation('));
        expect(dartCode, contains('simpleList: [1, 2, 3, 4, 5]'));
        expect(dartCode, contains("stringList: ['hello', 'world', 'test']"));
        expect(dartCode, contains("mixedList: [1, 'hello', true, null, 3.14]"));
        expect(dartCode, contains('emptyList: []'));
        expect(dartCode, contains('nestedList: [[1, 2], [3, 4], [5, 6]]'));
        expect(dartCode, contains("simpleMap: {'a': 1, 'b': 2, 'c': 3}"));
        expect(dartCode, contains("stringMap: {'hello': 'world', 'foo': 'bar'}"));
        expect(dartCode, contains("mixedMap: {'int': 42, 'string': 'value', 'bool': true}"));
        expect(dartCode, contains('emptyMap: {}'));
        expect(dartCode, contains("nestedMap: {'outer': {'inner': 'value'}}"));
        expect(dartCode, contains('simpleSet: {1, 2, 3, 4, 5}'));
        expect(dartCode, contains("stringSet: {'hello', 'world', 'test'}"));
        expect(dartCode, contains('emptySet: {}'));
        expect(dartCode, contains('listComprehension: [for (int i = 1; i <= 10; i++) if (i % 2 == 0) i * 2]'));
        expect(dartCode, contains("mapComprehension: {for (String s in ['a', 'b', 'c']) s: s.toUpperCase()}"));
        expect(dartCode, contains('setComprehension: {for (int i = 1; i <= 10; i++) if (i % 3 == 0) i}'));
        expect(dartCode, contains('spreadList: [0, ...[1, 2, 3], 4, ...[5, 6]]'));
        expect(dartCode, contains("spreadMap: {'a': 1, ...{'b': 2, 'c': 3}, 'd': 4}"));
        expect(dartCode, contains('conditionalCollection: [1, 2, if (condition) ...[3, 4, 5], 6]'));
        expect(dartCode, contains('class CollectionAnnotationClass'));
      });

      test('handles annotations with function calls and method references', () {
        const dpugCode = '''
@FunctionAnnotation(
  simpleCall: 'hello'.toUpperCase(),
  methodCall: 'hello'.substring(0, 2),
  staticCall: DateTime.now(),
  constructorCall: Duration(seconds: 30),
  cascadeCall: StringBuffer()..write('hello')..write('world'),
  nestedCall: 'hello'.substring(0, 2).toUpperCase(),
  functionCall: (String s) => s.length,
  methodRef: String#toUpperCase,
  getterCall: 'hello'.length,
  operatorCall: 1 + 2 * 3,
  conditionalCall: condition ? 'true'.length : 'false'.length
)
class FunctionAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@FunctionAnnotation('));
        expect(dartCode, contains("simpleCall: 'hello'.toUpperCase()"));
        expect(dartCode, contains("methodCall: 'hello'.substring(0, 2)"));
        expect(dartCode, contains('staticCall: DateTime.now()'));
        expect(dartCode, contains('constructorCall: Duration(seconds: 30)'));
        expect(dartCode, contains("cascadeCall: StringBuffer()..write('hello')..write('world')"));
        expect(dartCode, contains("nestedCall: 'hello'.substring(0, 2).toUpperCase()"));
        expect(dartCode, contains('functionCall: (String s) => s.length'));
        expect(dartCode, contains('methodRef: String#toUpperCase'));
        expect(dartCode, contains("getterCall: 'hello'.length"));
        expect(dartCode, contains('operatorCall: 1 + 2 * 3'));
        expect(dartCode, contains("conditionalCall: condition ? 'true'.length : 'false'.length"));
        expect(dartCode, contains('class FunctionAnnotationClass'));
      });

      test('handles annotations with async and generator expressions', () {
        const dpugCode = '''
@AsyncAnnotation(
  futureValue: Future.value(42),
  delayedValue: Future.delayed(Duration(seconds: 1), () => 'delayed'),
  microtaskValue: Future.microtask(() => 'microtask'),
  syncValue: Future.sync(() => 'sync'),
  completedFuture: Future(() => 'completed'),
  errorFuture: Future.error('error'),
  streamValue: Stream.fromIterable([1, 2, 3]),
  periodicStream: Stream.periodic(Duration(seconds: 1), (i) => i),
  emptyStream: Stream.empty(),
  valueStream: Stream.value('hello'),
  errorStream: Stream.error('stream error'),
  generatorList: [for int i in 1..5 if i % 2 == 0 i],
  generatorMap: {for String s in ['a', 'b', 'c'] s: s.length},
  generatorSet: {for int i in 1..10 if i % 3 == 0 i}
)
class AsyncAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@AsyncAnnotation('));
        expect(dartCode, contains('futureValue: Future.value(42)'));
        expect(dartCode, contains("delayedValue: Future.delayed(Duration(seconds: 1), () => 'delayed')"));
        expect(dartCode, contains("microtaskValue: Future.microtask(() => 'microtask')"));
        expect(dartCode, contains("syncValue: Future.sync(() => 'sync')"));
        expect(dartCode, contains("completedFuture: Future(() => 'completed')"));
        expect(dartCode, contains("errorFuture: Future.error('error')"));
        expect(dartCode, contains('streamValue: Stream.fromIterable([1, 2, 3])'));
        expect(dartCode, contains('periodicStream: Stream.periodic(Duration(seconds: 1), (i) => i)'));
        expect(dartCode, contains('emptyStream: Stream.empty()'));
        expect(dartCode, contains("valueStream: Stream.value('hello')"));
        expect(dartCode, contains("errorStream: Stream.error('stream error')"));
        expect(dartCode, contains('generatorList: [for (int i = 1; i <= 5; i++) if (i % 2 == 0) i]'));
        expect(dartCode, contains("generatorMap: {for (String s in ['a', 'b', 'c']) s: s.length}"));
        expect(dartCode, contains('generatorSet: {for (int i = 1; i <= 10; i++) if (i % 3 == 0) i}'));
        expect(dartCode, contains('class AsyncAnnotationClass'));
      });

      test('handles annotations with enum values and constants', () {
        const dpugCode = '''
@EnumAnnotation(
  simpleEnum: MyEnum.value1,
  anotherEnum: Status.active,
  priorityEnum: Priority.high,
  listOfEnums: [MyEnum.value1, MyEnum.value2, MyEnum.value3],
  mapOfEnums: {
    'first': MyEnum.value1,
    'second': MyEnum.value2,
    'third': MyEnum.value3
  },
  constValue: const MyClass('hello'),
  finalValue: final MyClass('world'),
  staticConst: MyClass.staticConst,
  staticFinal: MyClass.staticFinal
)
class EnumAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@EnumAnnotation('));
        expect(dartCode, contains('simpleEnum: MyEnum.value1'));
        expect(dartCode, contains('anotherEnum: Status.active'));
        expect(dartCode, contains('priorityEnum: Priority.high'));
        expect(dartCode, contains('listOfEnums: [MyEnum.value1, MyEnum.value2, MyEnum.value3]'));
        expect(dartCode, contains('mapOfEnums: {'));
        expect(dartCode, contains("'first': MyEnum.value1"));
        expect(dartCode, contains("'second': MyEnum.value2"));
        expect(dartCode, contains("'third': MyEnum.value3"));
        expect(dartCode, contains("constValue: const MyClass('hello')"));
        expect(dartCode, contains("finalValue: final MyClass('world')"));
        expect(dartCode, contains('staticConst: MyClass.staticConst'));
        expect(dartCode, contains('staticFinal: MyClass.staticFinal'));
        expect(dartCode, contains('class EnumAnnotationClass'));
      });

      test('handles annotations with type parameters and bounds', () {
        const dpugCode = '''
@GenericAnnotation(
  simpleType: String,
  genericType: List<String>,
  boundedType: T extends num,
  multipleBounds: T extends Object & Comparable<T>,
  nestedGeneric: Map<String, List<int>>,
  functionType: bool Function(String),
  complexFunctionType: T Function<U>(List<U>) where T extends Object,
  voidFunctionType: void Function(),
  genericClassType: MyGenericClass<String, int>,
  futureType: Future<String>,
  streamType: Stream<int>
)
class GenericAnnotationClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@GenericAnnotation('));
        expect(dartCode, contains('simpleType: String'));
        expect(dartCode, contains('genericType: List<String>'));
        expect(dartCode, contains('boundedType: T extends num'));
        expect(dartCode, contains('multipleBounds: T extends Object & Comparable<T>'));
        expect(dartCode, contains('nestedGeneric: Map<String, List<int>>'));
        expect(dartCode, contains('functionType: bool Function(String)'));
        expect(dartCode, contains('complexFunctionType: T Function<U>(List<U>) where T extends Object'));
        expect(dartCode, contains('voidFunctionType: void Function()'));
        expect(dartCode, contains('genericClassType: MyGenericClass<String, int>'));
        expect(dartCode, contains('futureType: Future<String>'));
        expect(dartCode, contains('streamType: Stream<int>'));
        expect(dartCode, contains('class GenericAnnotationClass'));
      });

      test('handles multiple annotations on the same element', () {
        const dpugCode = '''
@FirstAnnotation(value: 'first')
@SecondAnnotation(name: 'second', count: 2)
@ThirdAnnotation(
  complex: true,
  items: ['a', 'b', 'c'],
  config: {'key': 'value'}
)
@JsonSerializable()
@Entity(tableName: 'users')
@Table(name: 'users', schema: 'public')
@Deprecated('Use NewClass instead')
@visibleForTesting
@protected
@Required()
@NotNull()
@Size(min: 1, max: 100)
@Pattern(regexp: r'^[a-zA-Z0-9]+$')
class MultiAnnotationClass
  @FirstAnnotation('field1')
  @SecondAnnotation(name: 'field2')
  @JsonKey(name: 'user_name')
  @Column(name: 'username', nullable: false)
  @NotNull()
  @Size(min: 3, max: 50)
  String field1

  @SecondAnnotation(name: 'field2')
  @ThirdAnnotation(value: 42)
  @JsonKey(ignore: true)
  @Transient()
  @observable
  String field2

  @FirstAnnotation('method1')
  @SecondAnnotation(name: 'method2')
  @override
  @Test()
  @Benchmark()
  void method1()

  @ThirdAnnotation(value: 'method2')
  @Deprecated('Use method1 instead')
  @protected
  @Transaction()
  Future<void> method2() async
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains("@FirstAnnotation(value: 'first')"));
        expect(dartCode, contains("@SecondAnnotation(name: 'second', count: 2)"));
        expect(dartCode, contains('@ThirdAnnotation('));
        expect(dartCode, contains('complex: true'));
        expect(dartCode, contains("items: ['a', 'b', 'c']"));
        expect(dartCode, contains('@JsonSerializable()'));
        expect(dartCode, contains("@Entity(tableName: 'users')"));
        expect(dartCode, contains("@Table(name: 'users', schema: 'public')"));
        expect(dartCode, contains("@Deprecated('Use NewClass instead')"));
        expect(dartCode, contains('@visibleForTesting'));
        expect(dartCode, contains('@protected'));
        expect(dartCode, contains('@Required()'));
        expect(dartCode, contains('@NotNull()'));
        expect(dartCode, contains('@Size(min: 1, max: 100)'));
        expect(dartCode, contains(r"@Pattern(regexp: r'^[a-zA-Z0-9]+$')"));
        expect(dartCode, contains('class MultiAnnotationClass'));
        expect(dartCode, contains("@FirstAnnotation('field1')"));
        expect(dartCode, contains("@SecondAnnotation(name: 'field2')"));
        expect(dartCode, contains("@JsonKey(name: 'user_name')"));
        expect(dartCode, contains("@Column(name: 'username', nullable: false)"));
        expect(dartCode, contains('@NotNull()'));
        expect(dartCode, contains('@Size(min: 3, max: 50)'));
        expect(dartCode, contains("@FirstAnnotation('method1')"));
        expect(dartCode, contains("@SecondAnnotation(name: 'method2')"));
        expect(dartCode, contains('@override'));
        expect(dartCode, contains('@Test()'));
        expect(dartCode, contains('@Benchmark()'));
        expect(dartCode, contains('void method1()'));
        expect(dartCode, contains("@ThirdAnnotation(value: 'method2')"));
        expect(dartCode, contains("@Deprecated('Use method1 instead')"));
        expect(dartCode, contains('@protected'));
        expect(dartCode, contains('@Transaction()'));
        expect(dartCode, contains('Future<void> method2() async'));
      });

      test('handles annotations with error conditions and edge cases', () {
        const dpugCode = '''
@AnnotationWithErrors(
  nullValue: null,
  undefinedValue: undefined,
  circularRef: circularRef,
  invalidSyntax: @InvalidAnnotation(,
  unclosedString: 'hello,
  unclosedMap: {'key': 'value',
  unclosedList: [1, 2, 3,
  invalidNumber: 42.5.7,
  invalidBoolean: maybe,
  invalidIdentifier: 123invalid,
  divisionByZero: 1 / 0,
  infinity: 1.0 / 0.0,
  negativeInfinity: -1.0 / 0.0,
  nan: 0.0 / 0.0,
  veryLargeNumber: 999999999999999999999999999999999999999999999999,
  verySmallNumber: 0.000000000000000000000000000000000000000000000001,
  emptyString: '',
  whitespaceOnly: '   \t\n   ',
  multilineError: '''
    This has an error: @Invalid(
    Unclosed bracket
  '''
,
  nestedError: @Outer(@Inner(1, 2, 3, invalid: syntax))
)
class ErrorAnnotationClass
  String field
''';

        // Should handle gracefully or throw appropriate errors
        expect(() => converter.dpugToDart(dpugCode), returnsNormally);
      });

      test('handles annotations with memory and performance considerations', () {
        final largeAnnotation = List.generate(1000, (final i) => '@LargeAnnotation_$i(value: $i)').join('\n');
        final dpugCode = '''
$largeAnnotation
class MemoryTestClass
  String field
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@LargeAnnotation_0(value: 0)'));
        expect(dartCode, contains('@LargeAnnotation_999(value: 999)'));
        expect(dartCode, contains('class MemoryTestClass'));
      });
    });
  });
}
