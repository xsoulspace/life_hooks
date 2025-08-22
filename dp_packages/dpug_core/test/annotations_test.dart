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
  });
}
