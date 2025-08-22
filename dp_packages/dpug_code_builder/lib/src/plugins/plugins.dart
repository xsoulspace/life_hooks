/// Unified Plugin System for DPUG
///
/// This package provides a unified plugin system that handles all DPUG plugin
/// functionality across different contexts (compiler, visitors, formatters, etc.).
///
/// ## Usage
///
/// ### For Plugin Developers
///
/// ```dart
/// import 'package:dpug_code_builder/src/plugins/plugins.dart';
///
/// class MyCustomPlugin extends ClassPlugin {
///   const MyCustomPlugin();
///
///   @override
///   String get annotationName => 'myCustom';
///
///   @override
///   cb.Spec? generateClassCode({
///     required String annotationName,
///     required dynamic classNode,
///     required Map<String, dynamic> context,
///   }) {
///     // Your custom logic here
///     return null;
///   }
/// }
///
/// // Register your plugin
/// registerPlugin(const MyCustomPlugin());
/// ```
///
/// ### For Users
///
/// The core plugins are automatically registered:
/// - `@stateful` - Creates StatefulWidget classes
/// - `@stateless` - Creates StatelessWidget classes
/// - `@listen` - Creates reactive state fields
/// - `@changeNotifier` - Creates ChangeNotifier fields
library;

export 'core_plugins.dart';
export 'dpug_core_compatibility.dart';
export 'plugin_registration.dart';
// Core exports
export 'unified_plugin_system.dart';
