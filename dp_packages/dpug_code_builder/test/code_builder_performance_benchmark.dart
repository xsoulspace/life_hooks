import 'package:benchmark/benchmark.dart';
import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:dpug_core/compiler/performance_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Code Builder Performance Benchmarks', () {
    late DpugBenchmarkRunner runner;

    setUp(() {
      runner = DpugBenchmarkRunner();
    });

    tearDown(() {
      runner.clearResults();
    });

    test('Widget builder performance', () async {
      final widgetSpec = WidgetSpec(
        name: 'PerformanceTestWidget',
        properties: [
          PropertySpec(name: 'text', type: 'String', value: '"Hello World"'),
          PropertySpec(name: 'style', type: 'TextStyle', isNested: true),
        ],
        children: [
          ChildSpec(
            type: 'Text',
            properties: [
              PropertySpec(name: 'text', type: 'String', value: '"Child Text"'),
            ],
          ),
        ],
      );

      final benchmark = Benchmark('widget_builder_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          final builder = WidgetBuilder();
          return builder.build(widgetSpec);
        });
        DpugPerformanceUtils.recordMeasurement(
          'widget_builder_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('widget_builder_performance', benchmark);
      await benchmark.run();
    });

    test('Class builder performance', () async {
      final classSpec = ClassSpec(
        name: 'PerformanceTestClass',
        annotations: [AnnotationSpec(name: 'stateful')],
        fields: [
          FieldSpec(
            name: 'counter',
            type: 'int',
            annotations: [AnnotationSpec(name: 'listen')],
            initializer: '0',
          ),
        ],
        methods: [
          MethodSpec(
            name: 'build',
            returnType: 'Widget',
            body: 'return Container();',
          ),
        ],
      );

      final benchmark = Benchmark('class_builder_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          final builder = ClassBuilder();
          return builder.build(classSpec);
        });
        DpugPerformanceUtils.recordMeasurement(
          'class_builder_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('class_builder_performance', benchmark);
      await benchmark.run();
    });

    test('Large widget tree builder performance', () async {
      final largeWidgetSpec = _generateLargeWidgetSpec(100);

      final benchmark = Benchmark('large_widget_tree_builder', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          final builder = WidgetBuilder();
          return builder.build(largeWidgetSpec);
        });
        DpugPerformanceUtils.recordMeasurement(
          'large_widget_tree_builder',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('large_widget_tree_builder', benchmark);
      await benchmark.run();
    });

    test('Visitor pattern performance', () async {
      final complexSpec = _generateComplexSpec();

      final benchmark = Benchmark('visitor_pattern_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          final visitor = CodeGenerationVisitor();
          return complexSpec.accept(visitor);
        });
        DpugPerformanceUtils.recordMeasurement(
          'visitor_pattern_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('visitor_pattern_performance', benchmark);
      await benchmark.run();
    });

    test('Concurrent builder performance', () async {
      final specs = List.generate(20, (final i) => _generateComplexSpec());

      final benchmark = Benchmark('concurrent_builder_performance', () async {
        final result = await DpugPerformanceUtils.measureTimeWithMemory(
          () async {
            final futures = specs.map(
              (final spec) => Future(() {
                final builder = WidgetBuilder();
                return builder.build(spec);
              }),
            );
            return Future.wait(futures);
          },
        );
        DpugPerformanceUtils.recordMeasurement(
          'concurrent_builder_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('concurrent_builder_performance', benchmark);
      await benchmark.run();
    });

    test('Memory efficiency test', () async {
      final initialMemory = ProcessInfo.currentRss;

      final benchmark = Benchmark('memory_efficiency_test', () {
        // Create and build many widgets to test memory efficiency
        for (int i = 0; i < 1000; i++) {
          final spec = WidgetSpec(
            name: 'MemoryTestWidget$i',
            properties: [
              PropertySpec(name: 'text', type: 'String', value: '"Test $i"'),
            ],
          );
          final builder = WidgetBuilder();
          builder.build(spec);
        }

        final finalMemory = ProcessInfo.currentRss;
        final memoryDelta = finalMemory - initialMemory;

        DpugPerformanceUtils.recordMeasurement(
          'memory_efficiency_test',
          Duration.zero,
          memoryDelta,
        );
      });

      runner.addBenchmark('memory_efficiency_test', benchmark);
      await benchmark.run();
    });

    test('Builder pattern memory leak detection', () async {
      final initialMemory = ProcessInfo.currentRss;

      final benchmark = Benchmark('builder_memory_leak_detection', () {
        // Run multiple builder operations to check for memory leaks
        for (int i = 0; i < 500; i++) {
          final spec = _generateComplexSpec();
          final builder = WidgetBuilder();
          builder.build(spec);

          final classBuilder = ClassBuilder();
          final classSpec = ClassSpec(
            name: 'LeakTestClass$i',
            fields: [FieldSpec(name: 'field$i', type: 'int')],
          );
          classBuilder.build(classSpec);
        }

        final finalMemory = ProcessInfo.currentRss;
        final memoryDelta = finalMemory - initialMemory;

        DpugPerformanceUtils.recordMeasurement(
          'builder_memory_leak_detection',
          Duration.zero,
          memoryDelta,
        );
      });

      runner.addBenchmark('builder_memory_leak_detection', benchmark);
      await benchmark.run();
    });

    test(
      'Print code builder performance report',
      DpugPerformanceUtils.printReport,
    );
  });
}

WidgetSpec _generateLargeWidgetSpec(final int size) {
  final children = <ChildSpec>[];

  for (int i = 0; i < size; i++) {
    children.add(
      ChildSpec(
        type: 'Container',
        properties: [
          PropertySpec(name: 'width', type: 'double', value: '${i + 100}.0'),
          PropertySpec(name: 'height', type: 'double', value: '${i + 50}.0'),
        ],
        children: [
          ChildSpec(
            type: 'Text',
            properties: [
              PropertySpec(name: 'text', type: 'String', value: '"Item $i"'),
            ],
          ),
        ],
      ),
    );
  }

  return WidgetSpec(
    name: 'LargeWidget',
    properties: [
      PropertySpec(name: 'title', type: 'String', value: '"Large Widget"'),
    ],
    children: children,
  );
}

Spec _generateComplexSpec() => WidgetSpec(
  name: 'ComplexWidget',
  properties: [
    PropertySpec(name: 'title', type: 'String', value: '"Complex"'),
    PropertySpec(name: 'enabled', type: 'bool', value: 'true'),
    PropertySpec(name: 'size', type: 'double', value: '100.0'),
  ],
  children: [
    ChildSpec(
      type: 'Column',
      properties: [
        PropertySpec(
          name: 'mainAxisAlignment',
          type: 'MainAxisAlignment',
          value: 'MainAxisAlignment.center',
        ),
      ],
      children: List.generate(
        10,
        (final i) => ChildSpec(
          type: 'Text',
          properties: [
            PropertySpec(name: 'text', type: 'String', value: '"Text $i"'),
          ],
        ),
      ),
    ),
  ],
);
