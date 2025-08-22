// DPug Language Specification: Flutter Integration

DPug provides first-class support for Flutter development with specialized annotations, widget syntax, and state management features.

## Widget Classes

### 1. Standard Flutter Widgets (No Annotations)

```dpug
import 'package:flutter/material.dart'

// Standard Flutter widget without DPug annotations
class GreetingWidget extends StatelessWidget
  final String name
  final Color textColor

  const GreetingWidget(this.name, {this.textColor = Colors.black})

  @override
  Widget build(BuildContext context) =>
    Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Hello, $name!',
        style: TextStyle(
          color: textColor,
          fontSize: 24.0,
          fontWeight: FontWeight.bold
        )
      )
    )
```

### 2. DPug StatelessWidget with @stateless

```dpug
import 'package:flutter/material.dart'

@stateless
class GreetingWidget
  String name
  Color textColor

  GreetingWidget(this.name, {this.textColor = Colors.black})

  Widget get build =>
    Container
      padding: EdgeInsets.all(16.0)
      child:
        Text
          'Hello, $name!'
          style:
            TextStyle
              color: textColor
              fontSize: 24.0
              fontWeight: FontWeight.bold
```

### 3. DPug StatefulWidget with @stateful

#### Basic @stateful Widget

```dpug
import 'package:flutter/material.dart'

@stateful
class CounterWidget
  int count = 0
  String title

  CounterWidget({this.title = 'Counter'})

  void increment() => count++
  void decrement() => count--
  void reset() => count = 0

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text title
      body:
        Center
          child:
            Column
              mainAxisAlignment: MainAxisAlignment.center
              children:
                Text '$count' style: TextStyle fontSize: 48.0 fontWeight: FontWeight.bold
                SizedBox height: 20.0
                Row
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly
                  children:
                    ElevatedButton onPressed: () => decrement() child: Text '-'
                    ElevatedButton onPressed: () => reset() child: Text 'Reset'
                    ElevatedButton onPressed: () => increment() child: Text '+'
```

#### @stateful Widget with Field Annotations

```dpug
import 'package:flutter/material.dart'

@stateful
class CounterWidget
  // @listen: Passes field from constructor arguments and listens to changes
  @listen int count = 0        // count will be passed from constructor
  @listen String title = 'Counter'  // title will be passed from constructor

  // @changeNotifier: Initializes ChangeNotifier instance (not widget-specific)
  @changeNotifier int changeNotifierCount = 0

  // @setState: Uses setState for state management
  @setState int setStateCount = 0

  void increment() => count++
  void decrement() => count--
  void reset() => count = 0

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text title
      body:
        Center
          child:
            Column
              mainAxisAlignment: MainAxisAlignment.center
              children:
                Text '$count' style: TextStyle fontSize: 48.0 fontWeight: FontWeight.bold
                SizedBox height: 20.0
                Row
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly
                  children:
                    ElevatedButton onPressed: () => decrement() child: Text '-'
                    ElevatedButton onPressed: () => reset() child: Text 'Reset'
                    ElevatedButton onPressed: () => increment() child: Text '+'
```

## Field Annotations in Detail

### @listen Annotation

Used in @stateful widgets to create reactive fields that automatically trigger rebuilds.

```dpug
@stateful
class CounterWidget
  // @listen: Creates reactive field that triggers rebuild when changed
  @listen int count = 0

  // Constructor parameters are automatically passed to @listen fields
  CounterWidget({int initialCount = 0})
    count = initialCount  // This will trigger rebuild

  void increment() => count++  // Automatically triggers rebuild

  Widget get build => Text '$count'
```

### @changeNotifier Annotation

Creates ChangeNotifier instances for complex state management.

```dpug
@stateful
class AppState
  // @changeNotifier: Creates ChangeNotifier for external state management
  @changeNotifier UserModel userModel = UserModel()

  Widget get build =>
    ChangeNotifierProvider.value(
      value: userModel,
      child: UserProfile()
    )
```

### @setState Annotation

Uses traditional setState for state management (when preferred over reactive approaches).

```dpug
@stateful
class ManualCounter
  // @setState: Uses traditional setState approach
  @setState int count = 0

  void increment()
    setState(() => count++)

  Widget get build => Text '$count'
```

## Advanced State Management

### Provider Pattern

```dpug
@ChangeNotifier()
class UserModel extends ChangeNotifier
  @listen String name = ''
  @listen int age = 0
  @listen bool isLoading = false

  void updateName(String newName)
    name = newName
    notifyListeners()

  void updateAge(int newAge)
    age = newAge
    notifyListeners()

  Future<void> loadUserData() async
    isLoading = true
    notifyListeners()

    try
      // Simulate API call
      await Future.delayed(Duration(seconds: 2))
      name = 'John Doe'
      age = 25
    finally
      isLoading = false
      notifyListeners()

@stateless
class UserProfile extends StatelessWidget
  Widget get build =>
    Consumer<UserModel>
      builder: (context, userModel, child) =>
        if userModel.isLoading
          CircularProgressIndicator()
        else
          Column
            children:
              Text 'Name: ${userModel.name}'
              Text 'Age: ${userModel.age}'
              ElevatedButton
                onPressed: () => userModel.loadUserData()
                child: Text 'Load Data'
```

### Riverpod Integration

```dpug
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

@stateless
class CounterDisplay
  Widget get build =>
    Consumer
      builder: (context, ref, child) =>
        Column
          children:
            Text
              '${ref.watch(counterNotifierProvider)}'
              style:
                TextStyle
                  fontSize: 48.0
            Row
              mainAxisAlignment: MainAxisAlignment.spaceEvenly
              children:
                ElevatedButton
                  onPressed: () => ref.read(counterNotifierProvider.notifier).increment()
                  child: Text '+'
                ElevatedButton
                  onPressed: () => ref.read(counterNotifierProvider.notifier).decrement()
                  child: Text '-'
```

## Widget Composition Patterns

### Custom Button Widget

```dpug
@stateless
class CustomButton
  VoidCallback onPressed
  String text
  Color backgroundColor
  double borderRadius

  CustomButton({
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0
  })

  Widget get build =>
    ElevatedButton
      onPressed: onPressed
      style:
        ElevatedButton.styleFrom
          backgroundColor: backgroundColor
          shape:
            RoundedRectangleBorder
              borderRadius: BorderRadius.circular(borderRadius)
      child: Text text
```

### List Item Widget

```dpug
@stateless
class TodoItem
  Todo todo
  VoidCallback onToggle
  VoidCallback onDelete

  TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete
  })

  Widget get build =>
    Card
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0)
      child:
        ListTile
          leading:
            Checkbox
              value: todo.completed
              onChanged: (value) => onToggle()
          title: Text todo.title
          trailing:
            IconButton
              icon: Icon Icons.delete
              onPressed: onDelete
```

## Form Handling

```dpug
@stateful
class LoginForm
  @listen String email = ''
  @listen String password = ''
  @listen bool isLoading = false
  @listen String? errorMessage

  void updateEmail(String value) =>
    email = value

  void updatePassword(String value) =>
    password = value

  Future<void> login() async
    if email.isEmpty || password.isEmpty
      errorMessage = 'Please fill all fields'
      return

    isLoading = true
    errorMessage = null

    try
      // Simulate login
      await Future.delayed(Duration(seconds: 2))
      print 'Login successful'
    catch e
      errorMessage = 'Login failed: $e'
    finally
      isLoading = false

  Widget get build =>
    Padding
      padding: EdgeInsets.all(16.0)
      child:
        Column
          mainAxisAlignment: MainAxisAlignment.center
          children:
            TextField
              decoration:
                InputDecoration
                  labelText: 'Email'
                  errorText: email.isEmpty ? 'Email is required' : null
              onChanged: updateEmail
            SizedBox
              height: 16.0
            TextField
              decoration:
                InputDecoration
                  labelText: 'Password'
                  errorText: password.isEmpty ? 'Password is required' : null
              obscureText: true
              onChanged: updatePassword
            SizedBox
              height: 24.0
            if errorMessage != null
              Text
                errorMessage!
                style:
                  TextStyle
                    color: Colors.red
            SizedBox
              height: 16.0
            ElevatedButton
              onPressed: isLoading ? null : login
              child:
                if isLoading
                  SizedBox
                    width: 20.0
                    height: 20.0
                    child: CircularProgressIndicator()
                else
                  Text 'Login'
```

## Animation and Motion

```dpug
@stateful
class AnimatedCounter
  @listen int count = 0
  @listen bool isAnimating = false

  void incrementWithAnimation()
    isAnimating = true
    Future.delayed(Duration(milliseconds: 300), () =>
      isAnimating = false
    )
    count++

  Widget get build =>
    AnimatedContainer
      duration: Duration(milliseconds: 300)
      decoration:
        BoxDecoration
          color: isAnimating ? Colors.green : Colors.blue
          borderRadius: BorderRadius.circular(isAnimating ? 50.0 : 8.0)
      child:
        Center
          child:
            Text
              '$count'
              style:
                TextStyle
                  fontSize: 48.0
                  color: Colors.white
```

## Navigation and Routing

```dpug
@stateless
class HomeScreen
  Widget get build =>
    Scaffold
      appBar:
        AppBar
          title: Text 'Home'
      body:
        Center
          child:
            Column
              mainAxisAlignment: MainAxisAlignment.center
              children:
                Text 'Welcome to DPug!'
                SizedBox
                  height: 20.0
                ElevatedButton
                  onPressed: () => Navigator.pushNamed(context, '/profile')
                  child: Text 'Go to Profile'
                ElevatedButton
                  onPressed: () => Navigator.pushNamed(context, '/settings')
                  child: Text 'Go to Settings'

@stateless
class ProfileScreen
  Widget get build =>
    Scaffold
      appBar:
        AppBar
          title: Text 'Profile'
          leading:
            IconButton
              icon: Icon Icons.arrow_back
              onPressed: () => Navigator.pop(context)
      body:
        Center
          child: Text 'Profile Screen'
```

## Theming and Styling

```dpug
@stateless
class ThemedApp
  Widget get build =>
    MaterialApp
      theme:
        ThemeData
          primarySwatch: Colors.blue
          brightness: Brightness.light
          textTheme:
            TextTheme
              headline1:
                TextStyle
                  fontSize: 32.0
                  fontWeight: FontWeight.bold
              bodyText1:
                TextStyle
                  fontSize: 16.0
      darkTheme:
        ThemeData
          primarySwatch: Colors.blue
          brightness: Brightness.dark
      home: HomeScreen()

@stateless
class StyledContainer
  Widget get build =>
    Container
      padding: EdgeInsets.all(16.0)
      decoration:
        BoxDecoration
          gradient:
            LinearGradient
              colors: [Colors.blue, Colors.purple]
              begin: Alignment.topLeft
              end: Alignment.bottomRight
          borderRadius: BorderRadius.circular(12.0)
          boxShadow:
            BoxShadow
              color: Colors.black.withOpacity(0.2)
              blurRadius: 8.0
              offset: Offset(0, 4)
      child:
        Text
          'Styled Container'
          style:
            Theme.of(context).textTheme.headline1?.copyWith
              color: Colors.white
```

## Layout Widgets

```dpug
@stateless
class ComplexLayout
  Widget get build =>
    Scaffold
      body:
        CustomScrollView
          slivers:
            SliverAppBar
              title: Text 'Complex Layout'
              floating: true
              snap: true
            SliverList
              delegate:
                SliverChildBuilderDelegate
                  (context, index) =>
                    Card
                      margin: EdgeInsets.all(8.0)
                      child:
                        ListTile
                          title: Text 'Item $index'
                          subtitle: Text 'Description for item $index'
                  childCount: 20
```

## Gesture Handling

```dpug
@stateful
class GestureExample
  @listen Offset position = Offset.zero
  @listen Color color = Colors.blue

  void onPanUpdate(DragUpdateDetails details) =>
    position += details.delta

  void changeColor() =>
    color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)

  Widget get build =>
    GestureDetector
      onPanUpdate: onPanUpdate
      onTap: changeColor
      child:
        Container
          color: Colors.white
          child:
            Transform.translate
              offset: position
              child:
                Container
                  width: 100.0
                  height: 100.0
                  decoration:
                    BoxDecoration
                      color: color
                      shape: BoxShape.circle
```

## Media and Assets

```dpug
@stateless
class MediaExample
  Widget get build =>
    Column
      children:
        Image.asset
          'assets/images/logo.png'
          width: 200.0
          height: 100.0
        SizedBox
          height: 20.0
        Image.network
          'https://example.com/image.jpg'
          loadingBuilder: (context, child, loadingProgress) =>
            if loadingProgress == null
              child
            else
              CircularProgressIndicator
                value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null
        SizedBox
          height: 20.0
        Icon
          Icons.star
          size: 50.0
          color: Colors.amber
```

## Platform-Specific Code

```dpug
@stateless
class PlatformSpecificWidget
  Widget get build =>
    if Theme.of(context).platform == TargetPlatform.iOS
      CupertinoButton
        onPressed: () => print 'iOS button pressed'
        child: Text 'iOS Button'
    else if Theme.of(context).platform == TargetPlatform.android
      ElevatedButton
        onPressed: () => print 'Android button pressed'
        child: Text 'Android Button'
    else
      OutlinedButton
        onPressed: () => print 'Generic button pressed'
        child: Text 'Generic Button'
```

## Widget Testing

```dpug
@Test()
class CounterWidgetTest
  @Test()
  void testCounterIncrements()
    CounterWidget widget = CounterWidget()
    expect(widget.count, equals(0))

    widget.increment()
    expect(widget.count, equals(1))

  @Test()
  void testCounterWidgetRenders()
    await tester.pumpWidget(
      MaterialApp
        home: CounterWidget()
    )

    expect(find.text('0'), findsOneWidget)
    expect(find.text('+'), findsOneWidget)
    expect(find.text('-'), findsOneWidget)

  @Test()
  void testCounterIncrementButton()
    await tester.pumpWidget(
      MaterialApp
        home: CounterWidget()
    )

    await tester.tap(find.text('+'))
    await tester.pump()

    expect(find.text('1'), findsOneWidget)
```
