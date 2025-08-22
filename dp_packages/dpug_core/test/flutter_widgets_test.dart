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

    group('Widget Edge Cases and Error Conditions', () {
      test('handles very large widget trees', () {
        final manyWidgets = List.generate(100, (final i) => "  Text 'Widget $i'").join('\n');
        final dpugCode = '''
@stateless
class LargeWidget
  Widget get build =>
    Column
      children:
$manyWidgets
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class LargeWidget'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('children: ['));
        expect(dartCode, contains("Text('Widget 0')"));
        expect(dartCode, contains("Text('Widget 99')"));
      });

      test('handles deeply nested widget hierarchies', () {
        const dpugCode = '''
@stateless
class DeeplyNestedWidget
  Widget get build =>
    Container
      child:
        Padding
          padding: EdgeInsets.all(8.0)
          child:
            Column
              children:
                Row
                  children:
                    Container
                      child:
                        Padding
                          padding: EdgeInsets.all(4.0)
                          child:
                            Column
                              children:
                                Row
                                  children:
                                    Container
                                      child:
                                        Padding
                                          padding: EdgeInsets.all(2.0)
                                          child:
                                            Text 'Deeply nested content'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class DeeplyNestedWidget'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Container('));
        expect(dartCode, contains('Padding('));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('Row('));
        expect(dartCode, contains('EdgeInsets.all(8.0)'));
        expect(dartCode, contains('EdgeInsets.all(4.0)'));
        expect(dartCode, contains('EdgeInsets.all(2.0)'));
        expect(dartCode, contains("Text('Deeply nested content')"));
      });

      test('handles widgets with null and conditional children', () {
        const dpugCode = '''
@stateless
class ConditionalWidget
  String? title
  List<String>? items
  bool showFooter

  ConditionalWidget({this.title, this.items, this.showFooter = false})

  Widget get build =>
    Column
      children:
        if title != null
          Text title style: TextStyle fontWeight: FontWeight.bold
        if items != null && items.isNotEmpty
          for String item in items
            if item.length > 3
              ListTile title: Text item
        if showFooter
          Container
            padding: EdgeInsets.all(8.0)
            child: Text 'Footer'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ConditionalWidget'));
        expect(dartCode, contains('String? title;'));
        expect(dartCode, contains('List<String>? items;'));
        expect(dartCode, contains('bool showFooter;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('children: ['));
        expect(dartCode, contains('if (title != null)'));
        expect(dartCode, contains('Text(title, style: TextStyle(fontWeight: FontWeight.bold))'));
        expect(dartCode, contains('if (items != null && items.isNotEmpty)'));
        expect(dartCode, contains('for (String item in items)'));
        expect(dartCode, contains('if (item.length > 3)'));
        expect(dartCode, contains('ListTile(title: Text(item))'));
        expect(dartCode, contains('if (showFooter)'));
        expect(dartCode, contains('Container('));
        expect(dartCode, contains("Text('Footer')"));
      });

      test('handles widgets with complex state management', () {
        const dpugCode = '''
@stateful
class ComplexStateWidget
  @listen int count = 0
  @listen String status = 'idle'
  @listen List<String> items = []
  @listen Map<String, dynamic> config = {}
  @setState bool isLoading = false
  @changeNotifier UserModel userModel = UserModel()

  void increment() => count++
  void addItem(String item) => items.add(item)
  void updateConfig(String key, dynamic value) => config[key] = value
  void toggleLoading() => isLoading = !isLoading

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text 'Complex State: $count'
      body:
        if isLoading
          CircularProgressIndicator()
        else
          Column
            children:
              Text 'Status: $status'
              Text 'Items: ${items.length}'
              for String item in items
                ListTile
                  title: Text item
                  onTap: () => updateConfig('selected', item)
              ElevatedButton
                onPressed: increment
                child: Text 'Increment'
              ElevatedButton
                onPressed: () => addItem('Item ${count + 1}')
                child: Text 'Add Item'
              ElevatedButton
                onPressed: toggleLoading
                child: Text 'Toggle Loading'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class ComplexStateWidget'));
        expect(dartCode, contains('@listen int count = 0;'));
        expect(dartCode, contains("@listen String status = 'idle';"));
        expect(dartCode, contains('@listen List<String> items = [];'));
        expect(dartCode, contains('@listen Map<String, dynamic> config = {};'));
        expect(dartCode, contains('@setState bool isLoading = false;'));
        expect(dartCode, contains('@changeNotifier UserModel userModel = UserModel();'));
        expect(dartCode, contains('void increment() => count++;'));
        expect(dartCode, contains('void addItem(String item) => items.add(item);'));
        expect(dartCode, contains('void updateConfig(String key, dynamic value) => config[key] = value;'));
        expect(dartCode, contains('void toggleLoading() => isLoading = !isLoading;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains(r"appBar: AppBar(title: Text('Complex State: $count')),"));
        expect(dartCode, contains('if (isLoading)'));
        expect(dartCode, contains('CircularProgressIndicator(),'));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains(r"Text('Status: $status'),"));
        expect(dartCode, contains(r"Text('Items: ${items.length}'),"));
        expect(dartCode, contains('for (String item in items)'));
        expect(dartCode, contains('ListTile('));
        expect(dartCode, contains('title: Text(item),'));
        expect(dartCode, contains("onTap: () => updateConfig('selected', item)"));
        expect(dartCode, contains('ElevatedButton('));
        expect(dartCode, contains('onPressed: increment,'));
        expect(dartCode, contains(r"onPressed: () => addItem('Item ${count + 1}'),"));
        expect(dartCode, contains('onPressed: toggleLoading,'));
      });

      test('handles widgets with complex layouts and constraints', () {
        const dpugCode = '''
@stateless
class ComplexLayoutWidget
  Widget get build =>
    CustomMultiChildLayout
      delegate: MyLayoutDelegate()
      children:
        LayoutId
          id: 'header'
          child:
            Container
              color: Colors.blue
              height: 60.0
              child:
                Center
                  child: Text 'Header' style: TextStyle color: Colors.white fontWeight: FontWeight.bold
        LayoutId
          id: 'sidebar'
          child:
            Container
              color: Colors.grey.shade200
              width: 200.0
              child:
                Column
                  children:
                    Text 'Menu Item 1'
                    Text 'Menu Item 2'
                    Text 'Menu Item 3'
        LayoutId
          id: 'content'
          child:
            Container
              color: Colors.white
              child:
                SingleChildScrollView
                  child:
                    Column
                      children:
                        Text 'Main Content' style: TextStyle fontSize: 24.0
                        SizedBox height: 20.0
                        Wrap
                          spacing: 8.0
                          runSpacing: 8.0
                          children:
                            for int i in 1..20
                              Chip label: Text 'Chip $i'
        LayoutId
          id: 'footer'
          child:
            Container
              color: Colors.grey.shade300
              height: 40.0
              child:
                Center
                  child: Text 'Footer'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ComplexLayoutWidget'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('CustomMultiChildLayout('));
        expect(dartCode, contains('delegate: MyLayoutDelegate(),'));
        expect(dartCode, contains('children: ['));
        expect(dartCode, contains("LayoutId(id: 'header',"));
        expect(dartCode, contains("LayoutId(id: 'sidebar',"));
        expect(dartCode, contains("LayoutId(id: 'content',"));
        expect(dartCode, contains("LayoutId(id: 'footer',"));
        expect(dartCode, contains('color: Colors.blue,'));
        expect(dartCode, contains('height: 60.0,'));
        expect(dartCode, contains('width: 200.0,'));
        expect(dartCode, contains('SingleChildScrollView('));
        expect(dartCode, contains('Wrap('));
        expect(dartCode, contains('spacing: 8.0,'));
        expect(dartCode, contains('runSpacing: 8.0,'));
        expect(dartCode, contains('for (int i = 1; i <= 20; i++)'));
        expect(dartCode, contains(r"Chip(label: Text('Chip $i'))"));
      });

      test('handles widgets with animations and transitions', () {
        const dpugCode = '''
@stateful
class AnimatedWidget
  @setState bool isExpanded = false

  void toggle() => isExpanded = !isExpanded

  Widget get build =>
    Scaffold
      body:
        Center
          child:
            AnimatedContainer
              duration: Duration(milliseconds: 300)
              width: isExpanded ? 200.0 : 100.0
              height: isExpanded ? 200.0 : 100.0
              color: isExpanded ? Colors.blue : Colors.red
              child:
                AnimatedOpacity
                  opacity: isExpanded ? 1.0 : 0.5
                  duration: Duration(milliseconds: 300)
                  child:
                    GestureDetector
                      onTap: toggle
                      child:
                        AnimatedRotation
                          turns: isExpanded ? 0.25 : 0.0
                          duration: Duration(milliseconds: 300)
                          child:
                            Container
                              decoration:
                                BoxDecoration
                                  borderRadius: BorderRadius.circular(isExpanded ? 20.0 : 10.0)
                                  boxShadow:
                                    if isExpanded
                                      [
                                        BoxShadow
                                          color: Colors.black26
                                          blurRadius: 10.0
                                          spreadRadius: 2.0
                                      ]
                              child:
                                Center
                                  child:
                                    AnimatedDefaultTextStyle
                                      style:
                                        TextStyle
                                          color: isExpanded ? Colors.white : Colors.black
                                          fontSize: isExpanded ? 20.0 : 14.0
                                          fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal
                                      duration: Duration(milliseconds: 300)
                                      child: Text 'Tap me!'
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class AnimatedWidget'));
        expect(dartCode, contains('@setState bool isExpanded = false;'));
        expect(dartCode, contains('void toggle() => isExpanded = !isExpanded;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains('AnimatedContainer('));
        expect(dartCode, contains('duration: Duration(milliseconds: 300),'));
        expect(dartCode, contains('width: isExpanded ? 200.0 : 100.0,'));
        expect(dartCode, contains('height: isExpanded ? 200.0 : 100.0,'));
        expect(dartCode, contains('color: isExpanded ? Colors.blue : Colors.red,'));
        expect(dartCode, contains('AnimatedOpacity('));
        expect(dartCode, contains('opacity: isExpanded ? 1.0 : 0.5,'));
        expect(dartCode, contains('GestureDetector('));
        expect(dartCode, contains('onTap: toggle,'));
        expect(dartCode, contains('AnimatedRotation('));
        expect(dartCode, contains('turns: isExpanded ? 0.25 : 0.0,'));
        expect(dartCode, contains('BoxDecoration('));
        expect(dartCode, contains('borderRadius: BorderRadius.circular(isExpanded ? 20.0 : 10.0),'));
        expect(dartCode, contains('if (isExpanded)'));
        expect(dartCode, contains('BoxShadow('));
        expect(dartCode, contains('color: Colors.black26,'));
        expect(dartCode, contains('blurRadius: 10.0,'));
        expect(dartCode, contains('spreadRadius: 2.0'));
        expect(dartCode, contains('AnimatedDefaultTextStyle('));
        expect(dartCode, contains('style: TextStyle('));
        expect(dartCode, contains('color: isExpanded ? Colors.white : Colors.black,'));
        expect(dartCode, contains('fontSize: isExpanded ? 20.0 : 14.0,'));
        expect(dartCode, contains('fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal'));
        expect(dartCode, contains("child: Text('Tap me!')"));
      });

      test('handles widgets with form elements and validation', () {
        const dpugCode = '''
@stateful
class FormWidget
  @setState String name = ''
  @setState String email = ''
  @setState String password = ''
  @setState bool agreeToTerms = false
  @setState String selectedGender = 'male'
  @setState double rating = 3.0
  @setState List<String> selectedHobbies = []

  void submitForm()
    if name.isEmpty || email.isEmpty || password.isEmpty || !agreeToTerms
      print 'Please fill all required fields'
      return
    print 'Form submitted successfully'

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text 'Registration Form'
      body:
        SingleChildScrollView
          padding: EdgeInsets.all(16.0)
          child:
            Column
              children:
                TextField
                  decoration:
                    InputDecoration
                      labelText: 'Full Name'
                      hintText: 'Enter your full name'
                      border: OutlineInputBorder()
                      prefixIcon: Icon Icons.person
                  onChanged: (value) => name = value
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null
                SizedBox height: 16.0
                TextField
                  decoration:
                    InputDecoration
                      labelText: 'Email'
                      hintText: 'Enter your email'
                      border: OutlineInputBorder()
                      prefixIcon: Icon Icons.email
                  onChanged: (value) => email = value
                  keyboardType: TextInputType.emailAddress
                SizedBox height: 16.0
                TextField
                  decoration:
                    InputDecoration
                      labelText: 'Password'
                      border: OutlineInputBorder()
                      prefixIcon: Icon Icons.lock
                  onChanged: (value) => password = value
                  obscureText: true
                SizedBox height: 24.0
                DropdownButtonFormField<String>
                  decoration: InputDecoration labelText: 'Gender'
                  value: selectedGender
                  items:
                    DropdownMenuItem value: 'male' child: Text 'Male'
                    DropdownMenuItem value: 'female' child: Text 'Female'
                    DropdownMenuItem value: 'other' child: Text 'Other'
                  onChanged: (value) => selectedGender = value ?? 'male'
                SizedBox height: 16.0
                Slider
                  value: rating
                  min: 1.0
                  max: 5.0
                  divisions: 4
                  label: '${rating.round()} stars'
                  onChanged: (value) => rating = value
                SizedBox height: 16.0
                CheckboxListTile
                  title: Text 'I agree to the terms and conditions'
                  value: agreeToTerms
                  onChanged: (value) => agreeToTerms = value ?? false
                SizedBox height: 24.0
                ElevatedButton
                  onPressed: submitForm
                  child: Text 'Submit Form'
                  style:
                    ElevatedButton.styleFrom
                      minimumSize: Size(double.infinity, 48.0)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class FormWidget'));
        expect(dartCode, contains("@setState String name = '';"));
        expect(dartCode, contains("@setState String email = '';"));
        expect(dartCode, contains("@setState String password = '';"));
        expect(dartCode, contains('@setState bool agreeToTerms = false;'));
        expect(dartCode, contains("@setState String selectedGender = 'male';"));
        expect(dartCode, contains('@setState double rating = 3.0;'));
        expect(dartCode, contains('@setState List<String> selectedHobbies = [];'));
        expect(dartCode, contains('void submitForm() {'));
        expect(dartCode, contains('if (name.isEmpty || email.isEmpty || password.isEmpty || !agreeToTerms) {'));
        expect(dartCode, contains("print('Please fill all required fields');"));
        expect(dartCode, contains("print('Form submitted successfully');"));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains("appBar: AppBar(title: Text('Registration Form')),"));
        expect(dartCode, contains('SingleChildScrollView('));
        expect(dartCode, contains('padding: EdgeInsets.all(16.0),'));
        expect(dartCode, contains('TextField('));
        expect(dartCode, contains('InputDecoration('));
        expect(dartCode, contains("labelText: 'Full Name',"));
        expect(dartCode, contains("hintText: 'Enter your full name',"));
        expect(dartCode, contains('border: OutlineInputBorder(),'));
        expect(dartCode, contains('prefixIcon: Icon(Icons.person),'));
        expect(dartCode, contains('onChanged: (value) => name = value,'));
        expect(dartCode, contains("validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,"));
        expect(dartCode, contains('DropdownButtonFormField<String>('));
        expect(dartCode, contains("decoration: InputDecoration(labelText: 'Gender'),"));
        expect(dartCode, contains('value: selectedGender,'));
        expect(dartCode, contains("DropdownMenuItem(value: 'male', child: Text('Male')),"));
        expect(dartCode, contains('Slider('));
        expect(dartCode, contains('value: rating,'));
        expect(dartCode, contains('min: 1.0,'));
        expect(dartCode, contains('max: 5.0,'));
        expect(dartCode, contains('divisions: 4,'));
        expect(dartCode, contains(r"label: '${rating.round()} stars',"));
        expect(dartCode, contains('onChanged: (value) => rating = value'));
        expect(dartCode, contains('CheckboxListTile('));
        expect(dartCode, contains("title: Text('I agree to the terms and conditions'),"));
        expect(dartCode, contains('value: agreeToTerms,'));
        expect(dartCode, contains('onChanged: (value) => agreeToTerms = value ?? false'));
        expect(dartCode, contains('ElevatedButton('));
        expect(dartCode, contains('onPressed: submitForm,'));
        expect(dartCode, contains("child: Text('Submit Form'),"));
        expect(dartCode, contains('style: ElevatedButton.styleFrom('));
        expect(dartCode, contains('minimumSize: Size(double.infinity, 48.0)'));
      });

      test('handles widgets with complex gesture handling', () {
        const dpugCode = '''
@stateful
class GestureWidget
  @setState Offset position = Offset.zero
  @setState double scale = 1.0
  @setState double rotation = 0.0

  void onPanUpdate(DragUpdateDetails details)
    position += details.delta

  void onScaleUpdate(ScaleUpdateDetails details)
    scale = details.scale.clamp(0.5, 3.0)
    rotation = details.rotation

  Widget get build =>
    Scaffold
      body:
        Center
          child:
            Transform
              transform:
                Matrix4.identity()
                  ..translate(position.dx, position.dy)
                  ..scale(scale)
                  ..rotateZ(rotation)
              child:
                GestureDetector
                  onPanUpdate: onPanUpdate
                  onScaleUpdate: onScaleUpdate
                  onTap: () => print 'Single tap'
                  onDoubleTap: () => setState(() => scale = 1.0, rotation = 0.0, position = Offset.zero)
                  onLongPress: () => print 'Long press'
                  onHorizontalDragEnd: (details) => print 'Horizontal drag end'
                  onVerticalDragEnd: (details) => print 'Vertical drag end'
                  child:
                    Container
                      width: 200.0
                      height: 200.0
                      decoration:
                        BoxDecoration
                          color: Colors.blue
                          borderRadius: BorderRadius.circular(20.0)
                          boxShadow:
                            [
                              BoxShadow
                                color: Colors.black26
                                blurRadius: 10.0
                                offset: Offset(0, 4)
                            ]
                      child:
                        Center
                          child:
                            Column
                              mainAxisAlignment: MainAxisAlignment.center
                              children:
                                Icon Icons.touch_app size: 48.0 color: Colors.white
                                SizedBox height: 8.0
                                Text 'Drag, Scale, Rotate' style: TextStyle color: Colors.white fontWeight: FontWeight.bold
                                Text 'Double tap to reset' style: TextStyle color: Colors.white.opacity(0.8) fontSize: 12.0
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class GestureWidget'));
        expect(dartCode, contains('@setState Offset position = Offset.zero;'));
        expect(dartCode, contains('@setState double scale = 1.0;'));
        expect(dartCode, contains('@setState double rotation = 0.0;'));
        expect(dartCode, contains('void onPanUpdate(DragUpdateDetails details) {'));
        expect(dartCode, contains('position += details.delta;'));
        expect(dartCode, contains('void onScaleUpdate(ScaleUpdateDetails details) {'));
        expect(dartCode, contains('scale = details.scale.clamp(0.5, 3.0);'));
        expect(dartCode, contains('rotation = details.rotation;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains('Transform('));
        expect(dartCode, contains('transform: Matrix4.identity()'));
        expect(dartCode, contains('..translate(position.dx, position.dy)'));
        expect(dartCode, contains('..scale(scale)'));
        expect(dartCode, contains('..rotateZ(rotation),'));
        expect(dartCode, contains('GestureDetector('));
        expect(dartCode, contains('onPanUpdate: onPanUpdate,'));
        expect(dartCode, contains('onScaleUpdate: onScaleUpdate,'));
        expect(dartCode, contains("onTap: () => print('Single tap'),"));
        expect(dartCode, contains('onDoubleTap: () => setState(() => scale = 1.0, rotation = 0.0, position = Offset.zero),'));
        expect(dartCode, contains("onLongPress: () => print('Long press'),"));
        expect(dartCode, contains("onHorizontalDragEnd: (details) => print('Horizontal drag end'),"));
        expect(dartCode, contains("onVerticalDragEnd: (details) => print('Vertical drag end'),"));
        expect(dartCode, contains('Container('));
        expect(dartCode, contains('width: 200.0,'));
        expect(dartCode, contains('height: 200.0,'));
        expect(dartCode, contains('color: Colors.blue,'));
        expect(dartCode, contains('borderRadius: BorderRadius.circular(20.0),'));
        expect(dartCode, contains('BoxShadow('));
        expect(dartCode, contains('color: Colors.black26,'));
        expect(dartCode, contains('blurRadius: 10.0,'));
        expect(dartCode, contains('offset: Offset(0, 4)'));
        expect(dartCode, contains('Icon(Icons.touch_app, size: 48.0, color: Colors.white),'));
        expect(dartCode, contains("Text('Drag, Scale, Rotate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),"));
        expect(dartCode, contains("Text('Double tap to reset', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.0))"));
      });

      test('handles widgets with error boundaries and error handling', () {
        const dpugCode = '''
@stateful
class ErrorBoundaryWidget
  @setState String errorMessage = ''
  @setState bool hasError = false

  void simulateError()
    try
      // Simulate various types of errors
      if Random().nextBool()
        throw ArgumentError('Invalid argument')
      else
        throw FormatException('Invalid format')
    catch e
      errorMessage = e.toString()
      hasError = true

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text 'Error Boundary Demo'
      body:
        Column
          children:
            ElevatedButton
              onPressed: simulateError
              child: Text 'Trigger Error'
            SizedBox height: 20.0
            if hasError
              Card
                color: Colors.red.shade100
                margin: EdgeInsets.all(16.0)
                child:
                  Padding
                    padding: EdgeInsets.all(16.0)
                    child:
                      Column
                        children:
                          Row
                            children:
                              Icon Icons.error color: Colors.red
                              SizedBox width: 8.0
                              Text 'Error Occurred' style: TextStyle color: Colors.red fontWeight: FontWeight.bold
                          SizedBox height: 8.0
                          Text errorMessage style: TextStyle color: Colors.red.shade700
                          SizedBox height: 16.0
                          ElevatedButton
                            onPressed: () => setState(() => hasError = false, errorMessage = '')
                            style: ElevatedButton.styleFrom backgroundColor: Colors.red
                            child: Text 'Dismiss' style: TextStyle color: Colors.white
            else
              Card
                margin: EdgeInsets.all(16.0)
                child:
                  Padding
                    padding: EdgeInsets.all(16.0)
                    child:
                      Column
                        children:
                          Icon Icons.check_circle color: Colors.green size: 48.0
                          SizedBox height: 8.0
                          Text 'No errors detected' style: TextStyle fontSize: 16.0
                          Text 'Click the button to simulate an error' style: TextStyle color: Colors.grey
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class ErrorBoundaryWidget'));
        expect(dartCode, contains("@setState String errorMessage = '';"));
        expect(dartCode, contains('@setState bool hasError = false;'));
        expect(dartCode, contains('void simulateError() {'));
        expect(dartCode, contains('try {'));
        expect(dartCode, contains('if (Random().nextBool()) {'));
        expect(dartCode, contains("throw ArgumentError('Invalid argument');"));
        expect(dartCode, contains("throw FormatException('Invalid format');"));
        expect(dartCode, contains('} catch (e) {'));
        expect(dartCode, contains('errorMessage = e.toString();'));
        expect(dartCode, contains('hasError = true;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains("appBar: AppBar(title: Text('Error Boundary Demo')),"));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('ElevatedButton('));
        expect(dartCode, contains('onPressed: simulateError,'));
        expect(dartCode, contains("child: Text('Trigger Error'),"));
        expect(dartCode, contains('if (hasError)'));
        expect(dartCode, contains('Card('));
        expect(dartCode, contains('color: Colors.red.shade100,'));
        expect(dartCode, contains('margin: EdgeInsets.all(16.0),'));
        expect(dartCode, contains('Icon(Icons.error, color: Colors.red),'));
        expect(dartCode, contains("Text('Error Occurred', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),"));
        expect(dartCode, contains('Text(errorMessage, style: TextStyle(color: Colors.red.shade700)),'));
        expect(dartCode, contains("onPressed: () => setState(() => hasError = false, errorMessage = ''),"));
        expect(dartCode, contains('style: ElevatedButton.styleFrom(backgroundColor: Colors.red),'));
        expect(dartCode, contains("child: Text('Dismiss', style: TextStyle(color: Colors.white)),"));
        expect(dartCode, contains('else'));
        expect(dartCode, contains('Icon(Icons.check_circle, color: Colors.green, size: 48.0),'));
        expect(dartCode, contains("Text('No errors detected', style: TextStyle(fontSize: 16.0)),"));
        expect(dartCode, contains("Text('Click the button to simulate an error', style: TextStyle(color: Colors.grey)),"));
      });

      test('handles widgets with complex asynchronous operations', () {
        const dpugCode = '''
@stateful
class AsyncWidget
  @setState bool isLoading = false
  @setState List<String> data = []
  @setState String error = ''
  @setState int currentPage = 1

  void loadData() async
    setState(() => isLoading = true, error = '')
    try
      final response = await fetchData(currentPage)
      setState(() => data = response, isLoading = false)
    catch e
      setState(() => error = e.toString(), isLoading = false)

  void loadNextPage() async
    currentPage++
    await loadData()

  void refresh() async
    currentPage = 1
    await loadData()

  Widget get build =>
    Scaffold
      appBar: AppBar
        title: Text 'Async Data Loading'
        actions:
          IconButton
            icon: Icon Icons.refresh
            onPressed: refresh
      body:
        if isLoading
          Center
            child:
              Column
                mainAxisAlignment: MainAxisAlignment.center
                children:
                  CircularProgressIndicator()
                  SizedBox height: 16.0
                  Text 'Loading data...'
        else if error.isNotEmpty
          Center
            child:
              Column
                mainAxisAlignment: MainAxisAlignment.center
                children:
                  Icon Icons.error color: Colors.red size: 48.0
                  SizedBox height: 16.0
                  Text 'Error loading data' style: TextStyle color: Colors.red
                  SizedBox height: 8.0
                  Text error style: TextStyle color: Colors.red.shade700
                  SizedBox height: 16.0
                  ElevatedButton
                    onPressed: refresh
                    child: Text 'Retry'
        else if data.isEmpty
          Center
            child:
              Column
                mainAxisAlignment: MainAxisAlignment.center
                children:
                  Icon Icons.inbox color: Colors.grey size: 48.0
                  SizedBox height: 16.0
                  Text 'No data available'
                  SizedBox height: 16.0
                  ElevatedButton
                    onPressed: loadData
                    child: Text 'Load Data'
        else
          Column
            children:
              Expanded
                child:
                  ListView.builder
                    itemCount: data.length
                    itemBuilder: (context, index) =>
                      ListTile
                        title: Text data[index]
                        subtitle: Text 'Item ${index + 1}'
                        leading: CircleAvatar
                          child: Text '${index + 1}'
              if currentPage < 5
                Padding
                  padding: EdgeInsets.all(16.0)
                  child:
                    ElevatedButton
                      onPressed: loadNextPage
                      child: Text 'Load More'
                      style: ElevatedButton.styleFrom minimumSize: Size(double.infinity, 48.0)
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('@stateful'));
        expect(dartCode, contains('class AsyncWidget'));
        expect(dartCode, contains('@setState bool isLoading = false;'));
        expect(dartCode, contains('@setState List<String> data = [];'));
        expect(dartCode, contains("@setState String error = '';"));
        expect(dartCode, contains('@setState int currentPage = 1;'));
        expect(dartCode, contains('void loadData() async {'));
        expect(dartCode, contains("setState(() => isLoading = true, error = '');"));
        expect(dartCode, contains('try {'));
        expect(dartCode, contains('final response = await fetchData(currentPage);'));
        expect(dartCode, contains('setState(() => data = response, isLoading = false);'));
        expect(dartCode, contains('} catch (e) {'));
        expect(dartCode, contains('setState(() => error = e.toString(), isLoading = false);'));
        expect(dartCode, contains('void loadNextPage() async {'));
        expect(dartCode, contains('currentPage++;'));
        expect(dartCode, contains('await loadData();'));
        expect(dartCode, contains('void refresh() async {'));
        expect(dartCode, contains('currentPage = 1;'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains("appBar: AppBar(title: Text('Async Data Loading'), actions: ["));
        expect(dartCode, contains('IconButton('));
        expect(dartCode, contains('icon: Icon(Icons.refresh),'));
        expect(dartCode, contains('onPressed: refresh,'));
        expect(dartCode, contains('if (isLoading)'));
        expect(dartCode, contains('Center('));
        expect(dartCode, contains('CircularProgressIndicator(),'));
        expect(dartCode, contains("Text('Loading data...'),"));
        expect(dartCode, contains('else if (error.isNotEmpty)'));
        expect(dartCode, contains('Icon(Icons.error, color: Colors.red, size: 48.0),'));
        expect(dartCode, contains("Text('Error loading data', style: TextStyle(color: Colors.red)),"));
        expect(dartCode, contains('Text(error, style: TextStyle(color: Colors.red.shade700)),'));
        expect(dartCode, contains('else if (data.isEmpty)'));
        expect(dartCode, contains('Icon(Icons.inbox, color: Colors.grey, size: 48.0),'));
        expect(dartCode, contains("Text('No data available'),"));
        expect(dartCode, contains('onPressed: loadData,'));
        expect(dartCode, contains('else'));
        expect(dartCode, contains('Column('));
        expect(dartCode, contains('Expanded('));
        expect(dartCode, contains('ListView.builder('));
        expect(dartCode, contains('itemCount: data.length,'));
        expect(dartCode, contains('itemBuilder: (context, index) =>'));
        expect(dartCode, contains('ListTile('));
        expect(dartCode, contains('title: Text(data[index]),'));
        expect(dartCode, contains(r"subtitle: Text('Item ${index + 1}'),"));
        expect(dartCode, contains('leading: CircleAvatar('));
        expect(dartCode, contains(r"child: Text('${index + 1}'),"));
        expect(dartCode, contains('if (currentPage < 5)'));
        expect(dartCode, contains('Padding('));
        expect(dartCode, contains('padding: EdgeInsets.all(16.0),'));
        expect(dartCode, contains('onPressed: loadNextPage,'));
        expect(dartCode, contains("child: Text('Load More'),"));
        expect(dartCode, contains('style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48.0))'));
      });

      test('handles widgets with complex theming and styling', () {
        const dpugCode = '''
@stateless
class ThemedWidget
  Widget get build =>
    Theme
      data:
        ThemeData
          primaryColor: Colors.blue
          accentColor: Colors.orange
          fontFamily: 'Roboto'
          textTheme:
            TextTheme
              headline1: TextStyle fontSize: 32.0 fontWeight: FontWeight.bold
              headline2: TextStyle fontSize: 28.0 fontWeight: FontWeight.w600
              bodyText1: TextStyle fontSize: 16.0 color: Colors.black87
              bodyText2: TextStyle fontSize: 14.0 color: Colors.black54
              button: TextStyle fontSize: 16.0 fontWeight: FontWeight.w600
          elevatedButtonTheme:
            ElevatedButtonThemeData
              style:
                ElevatedButton.styleFrom
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)
                  shape: RoundedRectangleBorder borderRadius: BorderRadius.circular(8.0)
          cardTheme:
            CardTheme
              elevation: 4.0
              margin: EdgeInsets.all(8.0)
              shape: RoundedRectangleBorder borderRadius: BorderRadius.circular(12.0)
      child:
        Scaffold
          appBar: AppBar title: Text 'Themed App'
          body:
            Container
              decoration:
                BoxDecoration
                  gradient:
                    LinearGradient
                      colors: [Colors.blue.shade100, Colors.blue.shade50]
                      begin: Alignment.topLeft
                      end: Alignment.bottomRight
              child:
                SingleChildScrollView
                  padding: EdgeInsets.all(16.0)
                  child:
                    Column
                      children:
                        Card
                          child:
                            Padding
                              padding: EdgeInsets.all(16.0)
                              child:
                                Column
                                  children:
                                    Text 'Headline 1' style: Theme.of(context).textTheme.headline1
                                    SizedBox height: 8.0
                                    Text 'Headline 2' style: Theme.of(context).textTheme.headline2
                                    SizedBox height: 16.0
                                    Text 'This is body text 1' style: Theme.of(context).textTheme.bodyText1
                                    SizedBox height: 8.0
                                    Text 'This is body text 2' style: Theme.of(context).textTheme.bodyText2
                                    SizedBox height: 24.0
                                    ElevatedButton
                                      onPressed: () => print 'Button pressed'
                                      child: Text 'Themed Button'
                        SizedBox height: 16.0
                        Container
                          padding: EdgeInsets.all(16.0)
                          decoration:
                            BoxDecoration
                              color: Colors.white
                              borderRadius: BorderRadius.circular(8.0)
                              boxShadow:
                                [
                                  BoxShadow
                                    color: Colors.black12
                                    blurRadius: 4.0
                                    offset: Offset(0, 2)
                                ]
                          child:
                            Row
                              children:
                                Container
                                  width: 60.0
                                  height: 60.0
                                  decoration:
                                    BoxDecoration
                                      color: Theme.of(context).primaryColor
                                      borderRadius: BorderRadius.circular(30.0)
                                  child:
                                    Icon Icons.star color: Colors.white size: 30.0
                                SizedBox width: 16.0
                                Expanded
                                  child:
                                    Column
                                      crossAxisAlignment: CrossAxisAlignment.start
                                      children:
                                        Text 'Feature Title' style: TextStyle fontWeight: FontWeight.bold fontSize: 18.0
                                        SizedBox height: 4.0
                                        Text 'Feature description goes here' style: TextStyle color: Colors.grey.shade600
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class ThemedWidget'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('Theme('));
        expect(dartCode, contains('data: ThemeData('));
        expect(dartCode, contains('primaryColor: Colors.blue,'));
        expect(dartCode, contains('accentColor: Colors.orange,'));
        expect(dartCode, contains("fontFamily: 'Roboto',"));
        expect(dartCode, contains('textTheme: TextTheme('));
        expect(dartCode, contains('headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),'));
        expect(dartCode, contains('headline2: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),'));
        expect(dartCode, contains('bodyText1: TextStyle(fontSize: 16.0, color: Colors.black87),'));
        expect(dartCode, contains('bodyText2: TextStyle(fontSize: 14.0, color: Colors.black54),'));
        expect(dartCode, contains('button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)'));
        expect(dartCode, contains('elevatedButtonTheme: ElevatedButtonThemeData('));
        expect(dartCode, contains('style: ElevatedButton.styleFrom('));
        expect(dartCode, contains('padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),'));
        expect(dartCode, contains('shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))'));
        expect(dartCode, contains('cardTheme: CardTheme('));
        expect(dartCode, contains('elevation: 4.0,'));
        expect(dartCode, contains('margin: EdgeInsets.all(8.0),'));
        expect(dartCode, contains('shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))'));
        expect(dartCode, contains('Scaffold('));
        expect(dartCode, contains("appBar: AppBar(title: Text('Themed App')),"));
        expect(dartCode, contains('Container('));
        expect(dartCode, contains('decoration: BoxDecoration('));
        expect(dartCode, contains('gradient: LinearGradient('));
        expect(dartCode, contains('colors: [Colors.blue.shade100, Colors.blue.shade50],'));
        expect(dartCode, contains('begin: Alignment.topLeft,'));
        expect(dartCode, contains('end: Alignment.bottomRight,'));
        expect(dartCode, contains('SingleChildScrollView('));
        expect(dartCode, contains('padding: EdgeInsets.all(16.0),'));
        expect(dartCode, contains('Card('));
        expect(dartCode, contains('Padding('));
        expect(dartCode, contains("Text('Headline 1', style: Theme.of(context).textTheme.headline1),"));
        expect(dartCode, contains("Text('Headline 2', style: Theme.of(context).textTheme.headline2),"));
        expect(dartCode, contains("Text('This is body text 1', style: Theme.of(context).textTheme.bodyText1),"));
        expect(dartCode, contains("Text('This is body text 2', style: Theme.of(context).textTheme.bodyText2),"));
        expect(dartCode, contains("onPressed: () => print('Button pressed'),"));
        expect(dartCode, contains("child: Text('Themed Button'),"));
        expect(dartCode, contains('BoxShadow('));
        expect(dartCode, contains('color: Colors.black12,'));
        expect(dartCode, contains('blurRadius: 4.0,'));
        expect(dartCode, contains('offset: Offset(0, 2)'));
        expect(dartCode, contains("Text('Feature Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),"));
        expect(dartCode, contains("Text('Feature description goes here', style: TextStyle(color: Colors.grey.shade600)),"));
      });

      test('handles widgets with error conditions and edge cases', () {
        const dpugCode = '''
@stateless
class ErrorWidget
  Widget get build =>
    Container
      child:
        // This would cause issues in real Flutter
        if true
          Text 'This is fine'
        else if null != null
          Text 'This should not render'
        else if 1 / 0 == double.infinity
          Text 'Division by zero'
        else if 'hello'.length < 0
          Text 'Negative length'
        else
          Container
            // Nested errors
            child:
              if undefined != null
                Text 'Undefined variable'
              else
                // Malformed widget
                Text(
                  'Missing comma'
                  style: TextStyle(
                    fontSize: 16.0
                    color: Colors.black
                  )
                )
''';

        // Should handle gracefully or throw appropriate errors
        expect(() => converter.dpugToDart(dpugCode), returnsNormally);
      });

      test('handles widgets with memory management considerations', () {
        const largeWidgetCount = 1000;
        final widgetLines = List.generate(largeWidgetCount, (final i) => "  Text 'Item $i'").join('\n');
        final dpugCode = '''
@stateless
class MemoryTestWidget
  Widget get build =>
    ListView
      children:
$widgetLines
''';

        final dartCode = converter.dpugToDart(dpugCode);
        expect(dartCode, contains('class MemoryTestWidget'));
        expect(dartCode, contains('Widget get build =>'));
        expect(dartCode, contains('ListView('));
        expect(dartCode, contains('children: ['));
        expect(dartCode, contains("Text('Item 0')"));
        expect(dartCode, contains("Text('Item 999')"));
      });
    });
  });
}
