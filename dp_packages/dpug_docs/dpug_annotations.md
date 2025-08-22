// DPug Language Specification: Annotations

DPug supports Dart annotations with a clean syntax for metadata, dependency injection, serialization, and more.

## Basic Annotations

```dpug
@deprecated
void oldFunction() => print 'This function is deprecated'

@Deprecated('Use newFunction instead')
void anotherOldFunction() => print 'Also deprecated with message'

@override
void customImplementation() => print 'Overriding parent method'
```

## Class Annotations

```dpug
@JsonSerializable()
class User
  @JsonKey(name: 'user_id')
  String id

  @JsonKey(defaultValue: 'Anonymous')
  String name

  @JsonKey(ignore: true)
  String password

  User(this.id, this.name, this.password)

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json)
  Map<String, dynamic> toJson() => _$UserToJson(this)
```

## Field Annotations

```dpug
class Product
  @Id()
  @GeneratedValue(strategy: GenerationType.AUTO)
  int id

  @Column(name: 'product_name', nullable: false)
  String name

  @Column(precision: 10, scale: 2)
  double price

  @ManyToOne()
  @JoinColumn(name: 'category_id')
  Category category

  Product(this.id, this.name, this.price, this.category)
```

## Method Annotations

```dpug
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
```

## Dependency Injection Annotations

```dpug
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
```

## Multiple Annotations on Classes

```dpug
@Entity()
@Table(name: 'users')
@JsonSerializable()
@ChangeNotifier()
class User extends ChangeNotifier
  @Id()
  @GeneratedValue()
  @JsonKey(name: 'id')
  int id

  @Column(name: 'username')
  @JsonKey(name: 'username')
  @listen String username

  @Column(name: 'email')
  @JsonKey(name: 'email')
  @listen String email

  User(this.id, this.username, this.email)

  @JsonKey(ignore: true)
  @observable bool isLoading = false

  @JsonKey(ignore: true)
  @observable bool hasError = false

  void updateUsername(String newUsername)
    username = newUsername
    notifyListeners()

  void updateEmail(String newEmail)
    email = newEmail
    notifyListeners()
```

## Custom Annotations

```dpug
class Todo
  String description
  Priority priority
  bool completed

  Todo(this.description, this.priority, this.completed)

// Custom annotation definition
class Author
  final String name
  final String email

  const Author(this.name, this.email)

class Version
  final String number
  final String date

  const Version(this.number, {this.date = ''})

// Using custom annotations
@Author('John Doe', 'john@example.com')
@Version('1.0.0', date: '2024-01-15')
class TaskManager
  List<Todo> todos = []

  @Author('Jane Smith', 'jane@example.com')
  void addTodo(Todo todo) => todos.add(todo)

  @Version('1.1.0')
  void removeTodo(int index) => todos.removeAt(index)
```

## Validation Annotations

```dpug
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
```

## State Management Annotations

```dpug
@riverpod
class CounterNotifier extends _$CounterNotifier
  @override
  int build() => 0

  void increment() => state++
  void decrement() => state--

@riverpod
Future<List<User>> usersNotifier(UsersNotifierRef ref) async
  return await ref.watch(userServiceProvider).fetchUsers()

@freezed
class UserState with _$UserState
  const factory UserState.initial() = Initial
  const factory UserState.loading() = Loading
  const factory UserState.loaded(List<User> users) = Loaded
  const factory UserState.error(String message) = Error
```

## Testing Annotations

```dpug
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
```

## Documentation Annotations

```dpug
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
```

## Configuration Annotations

```dpug
@Configuration()
class AppConfig
  @Value('${app.name}')
  String appName

  @Value('${app.version:1.0.0}')
  String appVersion

  @Value('${database.url}')
  String databaseUrl

  @Bean()
  DatabaseService databaseService() => DatabaseService(databaseUrl)

  @Bean()
  @Scope('prototype')
  UserService userService() => UserService(databaseService())

@Profile('development')
@Configuration()
class DevConfig
  @Bean()
  Logger logger() => ConsoleLogger()

@Profile('production')
@Configuration()
class ProdConfig
  @Bean()
  Logger logger() => FileLogger()
```

## Event Handling Annotations

```dpug
@Component()
class EventListener
  @EventListener()
  void handleUserCreated(UserCreatedEvent event)
    print 'User created: ${event.user.name}'

  @EventListener()
  void handleUserDeleted(UserDeletedEvent event)
    print 'User deleted: ${event.userId}'

@Async()
@Component()
class AsyncEventListener
  @EventListener()
  Future<void> handleAsyncEvent(AsyncEvent event) async
    await Future.delayed(Duration(seconds: 1))
    print 'Async event processed: ${event.data}'
```

## Aspect-Oriented Programming Annotations

```dpug
@Aspect()
@Component()
class LoggingAspect
  @Pointcut('execution(* com.example.*.*(..))')
  void businessMethods() {}

  @Before('businessMethods()')
  void logBefore(JoinPoint joinPoint)
    print 'Before: ${joinPoint.signature.name}'

  @After('businessMethods()')
  void logAfter(JoinPoint joinPoint)
    print 'After: ${joinPoint.signature.name}'

  @AfterThrowing('businessMethods()')
  void logException(JoinPoint joinPoint, Exception exception)
    print 'Exception in ${joinPoint.signature.name}: $exception'

  @Around('businessMethods()')
  Object? logExecutionTime(ProceedingJoinPoint joinPoint)
    DateTime start = DateTime.now()
    Object? result = joinPoint.proceed()
    Duration executionTime = DateTime.now().difference(start)
    print 'Execution time: $executionTime'
    return result
```

## Combining Multiple Annotations

```dpug
@stateful
@JsonSerializable()
@ChangeNotifier()
@Entity()
@Table(name: 'user_profiles')
class UserProfile extends ChangeNotifier
  @Id()
  @GeneratedValue()
  @JsonKey(name: 'id')
  int id

  @Column(name: 'username', unique: true, nullable: false)
  @JsonKey(name: 'username')
  @NotNull()
  @Size(min: 3, max: 20)
  @listen String username

  @Column(name: 'email', unique: true, nullable: false)
  @JsonKey(name: 'email')
  @NotNull()
  @Email()
  @listen String email

  @Column(name: 'created_at')
  @JsonKey(name: 'createdAt')
  @Temporal(TemporalType.TIMESTAMP)
  DateTime createdAt

  @JsonKey(ignore: true)
  @observable bool isLoading = false

  @JsonKey(ignore: true)
  @ManyToMany()
  @JoinTable(
    name: 'user_roles',
    joinColumns: [JoinColumn(name: 'user_id')],
    inverseJoinColumns: [JoinColumn(name: 'role_id')]
  )
  List<Role> roles

  UserProfile(this.id, this.username, this.email, this.createdAt, this.roles)

  @JsonKey(ignore: true)
  @OneToMany(mappedBy: 'user')
  List<Post> posts

  @PostLoad()
  void initialize()
    posts = []
    isLoading = false

  @PrePersist()
  void prePersist()
    createdAt = DateTime.now()

  @Transactional()
  @CacheEvict(value: ['users', 'userProfiles'], allEntries: true)
  void updateProfile()
    // Implementation
    notifyListeners()

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
    _$UserProfileFromJson(json)

  Map<String, dynamic> toJson() => _$UserProfileToJson(this)
```
