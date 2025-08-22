import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Flutter Widgets Conversion', () {
    final converter = DpugConverter();

    group('Standard Flutter Widgets (No Annotations)', () {
      test('converts basic StatelessWidget', () {
        const dpugCode = r'''
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
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class GreetingWidget extends StatelessWidget {'));
        expect(dartCode, contains('final String name;'));
        expect(dartCode, contains('final Color textColor;'));
        expect(dartCode, contains('const GreetingWidget(this.name, {this.textColor = Colors.black});'));
        expect(dartCode, contains('@override'));
        expect(dartCode, contains('Widget build(BuildContext context) =>'));
        expect(dartCode, contains('Container('));
        expect(dartCode, contains('padding: EdgeInsets.all(16.0),'));
        expect(dartCode, contains('child: Text('));
        expect(dartCode, contains(r"'Hello, $name!',"));
        expect(dartCode, contains('style: TextStyle('));
        expect(dartCode, contains('color: textColor,'));
        expect(dartCode, contains('fontSize: 24.0,'));
        expect(dartCode, contains('fontWeight: FontWeight.bold'));
      });

      test('converts basic StatefulWidget', () {
        const dpugCode = r'''
class CounterWidget extends StatefulWidget
  final int initialCount

  const CounterWidget({this.initialCount = 0})

  @override
  State<CounterWidget> createState() => _CounterWidgetState()

class _CounterWidgetState extends State<CounterWidget>
  late int _count

  @override
  void initState()
    super.initState()
    _count = widget.initialCount

  void _increment() => setState(() => _count++)

  @override
  Widget build(BuildContext context) =>
    Column(
      children: [
        Text('$_count'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('Increment')
        )
      ]
    )
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class CounterWidget extends StatefulWidget {'));
        expect(dartCode, contains('final int initialCount;'));
        expect(dartCode, contains('const CounterWidget({this.initialCount = 0});'));
        expect(dartCode, contains('State<CounterWidget> createState() => _CounterWidgetState();'));
        expect(dartCode, contains('class _CounterWidgetState extends State<CounterWidget> {'));
        expect(dartCode, contains('late int _count;'));
        expect(dartCode, contains('void initState() {'));
        expect(dartCode, contains('super.initState();'));
        expect(dartCode, contains('_count = widget.initialCount;'));
        expect(dartCode, contains('void _increment() => setState(() => _count++);'));
        expect(dartCode, contains('Widget build(BuildContext context) =>'));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('children: ['));
        expect(dartCode, contains(r"Text('$_count'),"));
        expect(dartCode, contains('ElevatedButton('));
        expect(dartCode, contains('onPressed: _increment,'));
        expect(dartCode, contains("child: Text('Increment')"));
      });
    });

    group('DPug StatelessWidget with @stateless', () {
      test('converts basic @stateless widget', () {
        const dpugCode = r'''
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
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateless'));
        expect(dartCode, contains('class GreetingWidget'));
        expect(dartCode, contains('String name;'));
        expect(dartCode, contains('Color textColor;'));
        expect(dartCode, contains('GreetingWidget(this.name, {this.textColor = Colors.black});'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Container('));
        expect(dartCode, contains('padding: EdgeInsets.all(16.0),'));
        expect(dartCode, contains('child:'));
        expect(dartCode, contains('Text('));
        expect(dartCode, contains(r"'Hello, $name!',"));
        expect(dartCode, contains('style:'));
        expect(dartCode, contains('TextStyle('));
        expect(dartCode, contains('color: textColor,'));
        expect(dartCode, contains('fontSize: 24.0,'));
        expect(dartCode, contains('fontWeight: FontWeight.bold'));
      });

      test('converts @stateless with complex widget tree', () {
        const dpugCode = '''
import 'package:flutter/material.dart'

@stateless
class UserCard
  User user
  VoidCallback onEdit

  UserCard({required this.user, required this.onEdit})

  Widget get build =>
    Card
      margin: EdgeInsets.all(8.0)
      child:
        Padding
          padding: EdgeInsets.all(16.0)
          child:
            Column
              crossAxisAlignment: CrossAxisAlignment.start
              children:
                Row
                  children:
                    CircleAvatar
                      child: Text user.name[0]
                    SizedBox width: 12.0
                    Expanded
                      child:
                        Column
                          crossAxisAlignment: CrossAxisAlignment.start
                          children:
                            Text
                              user.name
                              style:
                                TextStyle
                                  fontSize: 18.0
                                  fontWeight: FontWeight.bold
                            Text
                              user.email
                              style:
                                TextStyle
                                  color: Colors.grey
                SizedBox height: 12.0
                Row
                  mainAxisAlignment: MainAxisAlignment.end
                  children:
                    TextButton
                      onPressed: onEdit
                      child: Text 'Edit'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateless'));
        expect(dartCode, contains('class UserCard'));
        expect(dartCode, contains('User user;'));
        expect(dartCode, contains('VoidCallback onEdit;'));
        expect(dartCode, contains('UserCard({required this.user, required this.onEdit});'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Card('));
        expect(dartCode, contains('margin: EdgeInsets.all(8.0),'));
        expect(dartCode, contains('Padding('));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('crossAxisAlignment: CrossAxisAlignment.start,'));
        expect(dartCode, contains('Row('));
        expect(dartCode, contains('CircleAvatar('));
        expect(dartCode, contains('Expanded('));
        expect(dartCode, contains('TextButton('));
        expect(dartCode, contains('onPressed: onEdit,'));
      });
    });

    group('DPug StatefulWidget with @stateful - Basic', () {
      test('converts basic @stateful widget', () {
        const dpugCode = r'''
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
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class CounterWidget'));
        expect(dartCode, contains('int count = 0;'));
        expect(dartCode, contains('String title;'));
        expect(dartCode, contains("CounterWidget({this.title = 'Counter'});"));
        expect(dartCode, contains('void increment() => count++;'));
        expect(dartCode, contains('void decrement() => count--;'));
        expect(dartCode, contains('void reset() => count = 0;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains('appBar: AppBar(title: Text(title)),'));
        expect(dartCode, contains('Center('));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('mainAxisAlignment: MainAxisAlignment.center,'));
        expect(dartCode, contains(r"Text('$count', style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold)),"));
        expect(dartCode, contains(r'ElevatedButton(onPressed: () => decrement(), child: Text(\'-\\')),'));
        expect(dartCode, contains("ElevatedButton(onPressed: () => reset(), child: Text('Reset')),"));
        expect(dartCode, contains(r'ElevatedButton(onPressed: () => increment(), child: Text(\'+\\')),'));
      });
    });

    group('DPug StatefulWidget with Field Annotations', () {
      test('converts @stateful with @listen fields', () {
        const dpugCode = r'''
import 'package:flutter/material.dart'

@stateful
class CounterWidget
  @listen int count = 0
  @listen String title = 'Counter'

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
                ElevatedButton onPressed: () => increment() child: Text 'Increment'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class CounterWidget'));
        expect(dartCode, contains('@listen int count = 0;'));
        expect(dartCode, contains("@listen String title = 'Counter';"));
        expect(dartCode, contains('void increment() => count++;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains('appBar: AppBar(title: Text(title)),'));
      });

      test('converts @stateful with @changeNotifier fields', () {
        const dpugCode = '''
import 'package:flutter/material.dart'

@stateful
class AppState
  @changeNotifier UserModel userModel = UserModel()

  Widget get build =>
    ChangeNotifierProvider.value(
      value: userModel,
      child: UserProfile()
    )
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class AppState'));
        expect(dartCode, contains('@changeNotifier UserModel userModel = UserModel();'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('ChangeNotifierProvider.value('));
        expect(dartCode, contains('value: userModel,'));
        expect(dartCode, contains('child: UserProfile()'));
      });

      test('converts @stateful with @setState fields', () {
        const dpugCode = r'''
import 'package:flutter/material.dart'

@stateful
class ManualCounter
  @setState int count = 0

  void increment()
    setState(() => count++)

  Widget get build => Text '$count'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class ManualCounter'));
        expect(dartCode, contains('@setState int count = 0;'));
        expect(dartCode, contains('void increment() {'));
        expect(dartCode, contains('setState(() => count++);'));
        expect(dartCode, contains('}'));
        expect(dartCode, contains(r"Widget get build => Text('$count');"));
      });

      test('converts @stateful with mixed field annotations', () {
        const dpugCode = '''
import 'package:flutter/material.dart'

@stateful
class ComplexWidget
  @listen String title = 'App'
  @changeNotifier AppSettings settings = AppSettings()
  @setState bool isLoading = false

  void toggleLoading() => isLoading = !isLoading

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text title
      body:
        if isLoading
          CircularProgressIndicator()
        else
          SettingsForm settings: settings
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class ComplexWidget'));
        expect(dartCode, contains("@listen String title = 'App';"));
        expect(dartCode, contains('@changeNotifier AppSettings settings = AppSettings();'));
        expect(dartCode, contains('@setState bool isLoading = false;'));
        expect(dartCode, contains('void toggleLoading() => isLoading = !isLoading;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains('appBar: AppBar(title: Text(title)),'));
        expect(dartCode, contains('if (isLoading)'));
        expect(dartCode, contains('CircularProgressIndicator(),'));
        expect(dartCode, contains('else'));
        expect(dartCode, contains('SettingsForm(settings: settings)'));
      });
    });

    group('Widget Composition Patterns', () {
      test('converts custom button widget', () {
        const dpugCode = '''
import 'package:flutter/material.dart'

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
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateless'));
        expect(dartCode, contains('class CustomButton'));
        expect(dartCode, contains('VoidCallback onPressed;'));
        expect(dartCode, contains('String text;'));
        expect(dartCode, contains('Color backgroundColor;'));
        expect(dartCode, contains('double borderRadius;'));
        expect(dartCode, contains('CustomButton({'));
        expect(dartCode, contains('required this.onPressed,'));
        expect(dartCode, contains('required this.text,'));
        expect(dartCode, contains('this.backgroundColor = Colors.blue,'));
        expect(dartCode, contains('this.borderRadius = 8.0'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('ElevatedButton('));
        expect(dartCode, contains('onPressed: onPressed,'));
        expect(dartCode, contains('style:'));
        expect(dartCode, contains('ElevatedButton.styleFrom('));
        expect(dartCode, contains('backgroundColor: backgroundColor,'));
        expect(dartCode, contains('shape:'));
        expect(dartCode, contains('RoundedRectangleBorder('));
        expect(dartCode, contains('borderRadius: BorderRadius.circular(borderRadius)'));
        expect(dartCode, contains('child: Text(text)'));
      });

      test('converts list item widget', () {
        const dpugCode = '''
import 'package:flutter/material.dart'

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
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateless'));
        expect(dartCode, contains('class TodoItem'));
        expect(dartCode, contains('Todo todo;'));
        expect(dartCode, contains('VoidCallback onToggle;'));
        expect(dartCode, contains('VoidCallback onDelete;'));
        expect(dartCode, contains('TodoItem({'));
        expect(dartCode, contains('required this.todo,'));
        expect(dartCode, contains('required this.onToggle,'));
        expect(dartCode, contains('required this.onDelete'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Card('));
        expect(dartCode, contains('margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),'));
        expect(dartCode, contains('child:'));
        expect(dartCode, contains('ListTile('));
        expect(dartCode, contains('leading:'));
        expect(dartCode, contains('Checkbox('));
        expect(dartCode, contains('value: todo.completed,'));
        expect(dartCode, contains('onChanged: (value) => onToggle()'));
        expect(dartCode, contains('title: Text(todo.title),'));
        expect(dartCode, contains('trailing:'));
        expect(dartCode, contains('IconButton('));
        expect(dartCode, contains('icon: Icon(Icons.delete),'));
        expect(dartCode, contains('onPressed: onDelete'));
      });
    });

    group('Round-trip Widget Conversion', () {
      test('widgets maintain semantics through round-trip', () {
        const dpugCode = '''
@stateless
class TestWidget
  String message

  TestWidget(this.message)

  Widget get build =>
    Container
      padding: EdgeInsets.all(16.0)
      child: Text message
''';

        final dartCode = converter.dpugToDart(dpugCode);
        final backToDpug = converter.dartToDpug(dartCode);

        // Should contain the key elements
        expect(backToDpug, contains('@stateless'));
        expect(backToDpug, contains('class TestWidget'));
        expect(backToDpug, contains('String message;'));
        expect(backToDpug, contains('TestWidget(this.message);'));
        expect(backToDpug, contains('Widget get build =>'));
        expect(backToDpug, contains('Container'));
        expect(backToDpug, contains('padding: EdgeInsets.all(16.0)'));
        expect(backToDpug, contains('child:'));
        expect(backToDpug, contains('Text(message)'));
      });
    });
  });
}
