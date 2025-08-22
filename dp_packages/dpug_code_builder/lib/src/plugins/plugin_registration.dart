import 'unified_plugin_system.dart';

/// Global registry instance for easy access
final pluginRegistry = UnifiedPluginRegistry();

/// Simple function to register a new plugin
void registerPlugin(final UnifiedPlugin plugin) {
  pluginRegistry.registerPlugin(plugin);
}

/// Simple function to check if an annotation is supported
bool isAnnotationSupported(final String annotationName) =>
    pluginRegistry.isAnnotationSupported(annotationName);

/// Simple function to get a plugin by annotation name
UnifiedPlugin? getPlugin(final String annotationName) =>
    pluginRegistry.getPlugin(annotationName);

/// Example of how to create and register a custom plugin
///
/// ```dart
/// class MyCustomPlugin extends ClassPlugin {
///   const MyCustomPlugin();
///
///   @override
///   String get annotationName => 'myCustom';
///
///   @override
///   int get priority => 50;
///
///   @override
///   cb.Spec? generateClassCode({
///     required String annotationName,
///     required dynamic classNode,
///     required Map<String, dynamic> context,
///   }) {
///     // Your custom code generation logic here
///     return null;
///   }
/// }
///
/// // Register it
/// registerPlugin(const MyCustomPlugin());
/// ```
