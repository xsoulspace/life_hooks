import 'package:args/command_runner.dart';

import '../dpug_cli.dart';

/// Show plugin information and available annotations
class PluginsCommand extends Command {
  PluginsCommand() {
    argParser
      ..addFlag(
        'list',
        abbr: 'l',
        help: 'List all available plugins',
        negatable: false,
        defaultsTo: true,
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show detailed plugin information',
        negatable: false,
      )
      ..addOption(
        'info',
        abbr: 'i',
        help: 'Show detailed information about a specific plugin',
      );
  }

  @override
  String get name => 'plugins';

  @override
  String get description =>
      'Show information about available DPug plugins and annotations';

  @override
  String get invocation => 'dpug plugins [options]';

  @override
  Future<void> run() async {
    final args = argResults;
    if (args == null) return;

    final list = args['list'] as bool;
    final verbose = args['verbose'] as bool;
    final infoPlugin = args['info'] as String?;

    if (infoPlugin != null) {
      _showPluginInfo(infoPlugin);
    } else if (list) {
      _listPlugins(verbose);
    }
  }

  void _listPlugins(final bool verbose) {
    print('🎯 Available DPug Plugins & Annotations');
    print('=' * 40);

    final plugins = [
      {
        'name': 'stateful',
        'type': 'Class Annotation',
        'description': 'Creates StatefulWidget with reactive state management',
        'example':
            '@stateful\nclass Counter\n  @listen int count = 0\n  Widget get build => ...',
      },
      {
        'name': 'stateless',
        'type': 'Class Annotation',
        'description': 'Creates StatelessWidget for display-only components',
        'example': '@stateless\nclass MyWidget\n  Widget get build => ...',
      },
      {
        'name': 'listen',
        'type': 'Field Annotation',
        'description': 'Creates reactive getter/setter that calls setState()',
        'example': '@listen int count = 0  // Auto-generates reactive property',
      },
      {
        'name': 'changeNotifier',
        'type': 'Field Annotation',
        'description': 'Creates ChangeNotifier field with auto-dispose logic',
        'example':
            '@changeNotifier CounterModel counter  // Auto-disposed in StatefulWidget',
      },
    ];

    for (final plugin in plugins) {
      print('\n📌 ${plugin['name']} (${plugin['type']})');
      print('   ${plugin['description']}');

      if (verbose) {
        print('\n   Example:');
        final example = plugin['example']!;
        for (final line in example.split('\n')) {
          print('     $line');
        }
      }
    }

    print('\n${'=' * 40}');
    print(
      '💡 Use "dpug plugins --info <name>" for detailed plugin information',
    );
    print('🔧 Custom plugins can be created by extending AnnotationPlugin');
  }

  void _showPluginInfo(final String pluginName) {
    final pluginInfo = {
      'stateful': {
        'title': 'Stateful Plugin (@stateful)',
        'description':
            'Transforms classes into StatefulWidget implementations with automatic state class generation.',
        'features': [
          'Converts class fields to state variables',
          'Generates StatefulWidget and State classes',
          'Handles constructor parameters properly',
          'Integrates with @listen and @changeNotifier fields',
        ],
        'usage': r'''
@stateful
class Counter
  @listen int count = 0
  @changeNotifier CounterModel model

  Widget get build =>
    Column
      Text ..text: "Count: $count"
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text ..text: "Increment"''',
        'generated_code': r'''
class Counter extends StatefulWidget {
  const Counter({
    required this.count,
    required this.model,
    super.key,
  });

  final int count;
  final CounterModel model;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _count;
  late final CounterModel _modelNotifier;

  int get count => _count;
  set count(int value) => setState(() => _count = value);

  CounterModel get model => _modelNotifier;

  @override
  void dispose() {
    _disposeModel();
    super.dispose();
  }

  void _disposeModel() {
    _modelNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Count: $count"),
        ElevatedButton(
          onPressed: () => count++,
          child: Text("Increment"),
        ),
      ],
    );
  }
}''',
      },
      'stateless': {
        'title': 'Stateless Plugin (@stateless)',
        'description':
            'Creates StatelessWidget implementations for display-only components.',
        'features': [
          'Validates no state fields are present',
          'Generates StatelessWidget implementation',
          'Prevents common mistakes with state management',
        ],
        'usage': '''
@stateless
class MyWidget
  Widget get build =>
    Container
      Text ..text: "Hello World"''',
        'generated_code': '''
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Hello World"),
    );
  }
}''',
      },
      'listen': {
        'title': 'Listen Plugin (@listen)',
        'description':
            'Creates reactive properties that automatically call setState() when modified.',
        'features': [
          'Generates getter/setter pairs',
          'Automatically calls setState() on value changes',
          'Provides simple reactive state without ChangeNotifier complexity',
        ],
        'usage': r'''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Text ..text: "Count: $count"''',
        'generated_code': '''
// Inside the State class:
late int _count = 0;

int get count => _count;
set count(int value) => setState(() => _count = value);''',
      },
      'changeNotifier': {
        'title': 'ChangeNotifier Plugin (@changeNotifier)',
        'description':
            'Creates ChangeNotifier fields with automatic disposal logic in StatefulWidgets.',
        'features': [
          'Generates ChangeNotifier field implementations',
          'Automatic disposal in StatefulWidget dispose() method',
          'Memory leak prevention',
          'Flutter best practices enforcement',
        ],
        'usage': r'''
@stateful
class MyWidget
  @changeNotifier CounterModel counter

  Widget get build =>
    Text ..text: "Count: ${counter.count}"''',
        'generated_code': '''
// Inside the State class:
late final CounterModel _counterNotifier = CounterModel();

CounterModel get counter => _counterNotifier;

// Auto-generated dispose logic:
@override
void dispose() {
  _disposeCounter();
  super.dispose();
}

void _disposeCounter() {
  _counterNotifier.dispose();
}''',
      },
    };

    if (!pluginInfo.containsKey(pluginName)) {
      DpugCliUtils.printError('Plugin not found: $pluginName');
      print('\nAvailable plugins: ${pluginInfo.keys.join(', ')}');
      return;
    }

    final info = pluginInfo[pluginName]!;

    print('🎯 ${info['title']}');
    print('=' * 50);
    print('${info['description']}');

    print('\n✨ Features:');
    final features = info['features']! as List<String>;
    for (final feature in features) {
      print('  • $feature');
    }

    print('\n📝 Usage Example:');
    final usage = info['usage']! as String;
    for (final line in usage.split('\n')) {
      print('  $line');
    }

    print('\n🔧 Generated Dart Code:');
    final code = info['generated_code']! as String;
    for (final line in code.split('\n')) {
      print('  $line');
    }
  }
}
