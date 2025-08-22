import 'package:benchmark/benchmark.dart';
import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:dpug_core/compiler/performance_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Widget Compilation Performance Benchmarks', () {
    late DpugConverter converter;
    late DpugBenchmarkRunner runner;

    setUp(() {
      converter = DpugConverter();
      runner = DpugBenchmarkRunner();
    });

    tearDown(() {
      runner.clearResults();
    });

    test('Simple stateless widget compilation', () async {
      const simpleWidget = '''
Text
  ..text: "Hello World"
  ..style: TextStyle
    ..fontSize: 16.0
    ..color: Colors.black
''';

      final benchmark = Benchmark('simple_stateless_widget', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(simpleWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'simple_stateless_widget',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('simple_stateless_widget', benchmark);
      await benchmark.run();
    });

    test('Stateful widget compilation', () async {
      const statefulWidget = r'''
@stateful
class CounterWidget
  @listen int counter = 0

  Widget get build =>
    Column
      ..children: [
        Text
          ..text: "Counter: $counter"
        ElevatedButton
          ..onPressed: () => counter++
          ..child:
            Text
              ..text: "Increment"
      ]
''';

      final benchmark = Benchmark('stateful_widget_compilation', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(statefulWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'stateful_widget_compilation',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('stateful_widget_compilation', benchmark);
      await benchmark.run();
    });

    test('Complex widget tree compilation', () async {
      const complexWidget = '''
Container
  ..decoration: BoxDecoration
    ..color: Colors.white
    ..borderRadius: BorderRadius.circular(8.0)
    ..boxShadow: [
      BoxShadow
        ..color: Colors.black.withOpacity(0.1)
        ..blurRadius: 4.0
        ..offset: Offset(0, 2)
    ]
  ..child:
    Column
      ..children: [
        Row
          ..children: [
            Icon
              ..icon: Icons.star
              ..color: Colors.yellow
            Text
              ..text: "Featured Item"
              ..style: Theme.of(context).textTheme.headlineSmall
          ]
        Padding
          ..padding: EdgeInsets.all(16.0)
          ..child:
            Text
              ..text: "This is a description of the featured item with some longer text to test text rendering performance."
              ..style: Theme.of(context).textTheme.bodyMedium
        ButtonBar
          ..children: [
            TextButton
              ..onPressed: () => Navigator.of(context).pop()
              ..child:
                Text
                  ..text: "Cancel"
            ElevatedButton
              ..onPressed: () => print("Confirmed")
              ..child:
                Text
                  ..text: "Confirm"
          ]
      ]
''';

      final benchmark = Benchmark('complex_widget_tree', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(complexWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'complex_widget_tree',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('complex_widget_tree', benchmark);
      await benchmark.run();
    });

    test('ListView widget compilation', () async {
      const listViewWidget = r'''
Scaffold
  ..appBar: AppBar
    ..title: Text
      ..text: "Item List"
  ..body:
    ListView.builder
      ..itemCount: 1000
      ..itemBuilder: (context, index) =>
        ListTile
          ..title: Text
            ..text: "Item $index"
          ..subtitle: Text
            ..text: "Description for item $index"
          ..leading: CircleAvatar
            ..child: Text
              ..text: "$index"
          ..onTap: () => print("Tapped item $index")
''';

      final benchmark = Benchmark('listview_widget_compilation', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(listViewWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'listview_widget_compilation',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('listview_widget_compilation', benchmark);
      await benchmark.run();
    });

    test('Form widget compilation', () async {
      const formWidget = '''
Scaffold
  ..appBar: AppBar
    ..title: Text
      ..text: "Contact Form"
  ..body:
    Form
      ..key: _formKey
      ..child:
        Column
          ..children: [
            TextFormField
              ..decoration: InputDecoration
                ..labelText: "Name"
                ..hintText: "Enter your full name"
              ..validator: (value) =>
                value.isEmpty ? "Name is required" : null
            TextFormField
              ..decoration: InputDecoration
                ..labelText: "Email"
                ..hintText: "Enter your email address"
              ..keyboardType: TextInputType.emailAddress
              ..validator: (value) =>
                value.isEmpty ? "Email is required" : null
            TextFormField
              ..decoration: InputDecoration
                ..labelText: "Phone"
                ..hintText: "Enter your phone number"
              ..keyboardType: TextInputType.phone
            ElevatedButton
              ..onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print("Form is valid");
                }
              }
              ..child:
                Text
                  ..text: "Submit"
          ]
''';

      final benchmark = Benchmark('form_widget_compilation', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(formWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'form_widget_compilation',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('form_widget_compilation', benchmark);
      await benchmark.run();
    });

    test('Animation widget compilation', () async {
      const animationWidget = '''
@stateful
class AnimatedWidget
  @listen AnimationController _controller
  @listen Animation<double> _animation

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Widget get build =>
    AnimatedBuilder
      ..animation: _animation
      ..builder: (context, child) =>
        Opacity
          ..opacity: _animation.value
          ..child:
            Transform.scale
              ..scale: _animation.value
              ..child:
                Container
                  ..width: 200.0
                  ..height: 200.0
                  ..color: Colors.blue
                  ..child:
                    Center
                      ..child:
                        Text
                          ..text: "Animated!"
                          ..style: TextStyle
                            ..color: Colors.white
                            ..fontSize: 24.0

  void dispose() {
    _controller.dispose();
    super.dispose();
  }
''';

      final benchmark = Benchmark('animation_widget_compilation', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(animationWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'animation_widget_compilation',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('animation_widget_compilation', benchmark);
      await benchmark.run();
    });

    test('Nested widget performance', () async {
      final nestedWidget = _generateNestedWidget(5); // 5 levels deep

      final benchmark = Benchmark('nested_widget_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(nestedWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'nested_widget_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('nested_widget_performance', benchmark);
      await benchmark.run();
    });

    test('Widget with many properties', () async {
      const manyPropsWidget = '''
Container
  ..width: 300.0
  ..height: 200.0
  ..margin: EdgeInsets.all(16.0)
  ..padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)
  ..decoration: BoxDecoration
    ..color: Colors.white
    ..borderRadius: BorderRadius.circular(12.0)
    ..border: Border.all(
      color: Colors.grey.shade300,
      width: 1.0,
    )
    ..boxShadow: [
      BoxShadow
        ..color: Colors.black.withOpacity(0.1)
        ..blurRadius: 8.0
        ..offset: Offset(0, 4)
      BoxShadow
        ..color: Colors.black.withOpacity(0.05)
        ..blurRadius: 16.0
        ..offset: Offset(0, 8)
    ]
  ..child:
    Text
      ..text: "Complex Container"
      ..textAlign: TextAlign.center
      ..style: TextStyle
        ..fontSize: 18.0
        ..fontWeight: FontWeight.w600
        ..color: Colors.black87
        ..letterSpacing: 0.5
        ..height: 1.2
''';

      final benchmark = Benchmark('many_properties_widget', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(manyPropsWidget),
        );
        DpugPerformanceUtils.recordMeasurement(
          'many_properties_widget',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('many_properties_widget', benchmark);
      await benchmark.run();
    });

    test(
      'Print widget compilation performance report',
      DpugPerformanceUtils.printReport,
    );
  });
}

String _generateNestedWidget(final int depth) {
  if (depth <= 0) {
    return '''
Text
  ..text: "Deep Text"
''';
  }

  return '''
Container
  ..child:
${_generateNestedWidget(depth - 1)}
''';
}
