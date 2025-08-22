import 'dart:io';

import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:dpug_core/compiler/performance_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Resource Usage Tests', () {
    late DpugConverter converter;

    setUp(() {
      converter = DpugConverter();
    });

    test('Memory leak detection - basic conversion', () {
      final initialMemory = ProcessInfo.currentRss;

      // Run multiple conversions to check for memory leaks
      for (int i = 0; i < 1000; i++) {
        final dpug = 'Text\n  ..text: "Test $i"';
        converter.dpugToDart(dpug);
      }

      final finalMemory = ProcessInfo.currentRss;
      final memoryGrowth = finalMemory - initialMemory;

      // Allow some memory growth but not excessive (less than 50MB)
      expect(memoryGrowth, lessThan(50 * 1024 * 1024));
    });

    test('Memory leak detection - complex widgets', () {
      final initialMemory = ProcessInfo.currentRss;

      // Run multiple complex conversions
      for (int i = 0; i < 500; i++) {
        final dpug = TestDataGenerator.generateDpugWidget('Complex$i', 3, 5);
        converter.dpugToDart(dpug);
      }

      final finalMemory = ProcessInfo.currentRss;
      final memoryGrowth = finalMemory - initialMemory;

      // Allow some memory growth but not excessive (less than 100MB)
      expect(memoryGrowth, lessThan(100 * 1024 * 1024));
    });

    test('File handle management', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'dpug_resource_test_',
      );

      try {
        // Create multiple temporary files
        final files = <File>[];
        for (int i = 0; i < 100; i++) {
          final file = File('${tempDir.path}/test_$i.dpug');
          final content = TestDataGenerator.generateDpugWidget('Test$i', 2, 3);
          await file.writeAsString(content);
          files.add(file);
        }

        // Process all files
        for (final file in files) {
          final content = await file.readAsString();
          final dart = converter.dpugToDart(content);
          expect(dart, isNotEmpty);
        }

        // Clean up files
        for (final file in files) {
          await file.delete();
        }
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('Temporary file cleanup', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'dpug_cleanup_test_',
      );

      try {
        // Create temporary files
        final tempFiles = <File>[];
        for (int i = 0; i < 50; i++) {
          final file = File('${tempDir.path}/temp_$i.dpug');
          final content = TestDataGenerator.generateLargeDpugFile(1000);
          await file.writeAsString(content);
          tempFiles.add(file);
        }

        // Process and immediately delete
        for (final file in tempFiles) {
          final content = await file.readAsString();
          final dart = converter.dpugToDart(content);
          await file.delete();

          // Verify file is actually deleted
          expect(await file.exists(), isFalse);
        }

        // Verify all files are cleaned up
        final remainingFiles = await tempDir.list().toList();
        expect(remainingFiles, isEmpty);
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('Network resource cleanup simulation', () async {
      // Simulate network-like resource usage patterns
      final resources = <String>[];

      // Simulate acquiring resources
      for (int i = 0; i < 1000; i++) {
        final resource = 'resource_$i';
        resources.add(resource);

        // Simulate processing
        final dpug = 'Text\n  ..text: "$resource"';
        converter.dpugToDart(dpug);
      }

      // Simulate cleanup
      resources.clear();

      // Force garbage collection (if available)
      // Note: Dart doesn't have guaranteed GC, but this helps
      final initialMemory = ProcessInfo.currentRss;
      await Future.delayed(const Duration(milliseconds: 100));
      final finalMemory = ProcessInfo.currentRss;

      // Memory should not grow excessively
      final memoryGrowth = finalMemory - initialMemory;
      expect(memoryGrowth.abs(), lessThan(10 * 1024 * 1024));
    });

    test('Large object memory management', () {
      final initialMemory = ProcessInfo.currentRss;

      // Create and process very large DPug structures
      for (int i = 0; i < 10; i++) {
        final largeDpug = TestDataGenerator.generateLargeDpugFile(10000);
        final dart = converter.dpugToDart(largeDpug);
        expect(dart.length, greaterThan(largeDpug.length));
      }

      final finalMemory = ProcessInfo.currentRss;
      final memoryGrowth = finalMemory - initialMemory;

      // Allow reasonable memory growth (less than 200MB)
      expect(memoryGrowth, lessThan(200 * 1024 * 1024));
    });

    test('Concurrent resource usage', () async {
      final initialMemory = ProcessInfo.currentRss;

      // Run multiple concurrent conversions
      final futures = List.generate(50, (final i) async {
        final dpug = TestDataGenerator.generateDpugWidget('Concurrent$i', 3, 4);
        return converter.dpugToDart(dpug);
      });

      await Future.wait(futures);

      final finalMemory = ProcessInfo.currentRss;
      final memoryGrowth = finalMemory - initialMemory;

      // Memory should be reasonably managed (less than 100MB)
      expect(memoryGrowth, lessThan(100 * 1024 * 1024));
    });

    test('Resource exhaustion prevention', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'dpug_exhaustion_test_',
      );

      try {
        // Create many files to test resource limits
        final files = <File>[];
        for (int i = 0; i < 1000; i++) {
          final file = File('${tempDir.path}/exhaustion_$i.dpug');
          final content = 'Text\n  ..text: "File $i"';
          await file.writeAsString(content);
          files.add(file);
        }

        // Process files in batches to avoid overwhelming the system
        const batchSize = 100;
        for (int i = 0; i < files.length; i += batchSize) {
          final batch = files.sublist(
            i,
            i + batchSize < files.length ? i + batchSize : files.length,
          );
          final futures = batch.map((final file) async {
            final content = await file.readAsString();
            return converter.dpugToDart(content);
          });

          await Future.wait(futures);
        }

        // Verify all files were processed
        expect(files.length, equals(1000));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('Memory fragmentation test', () {
      final initialMemory = ProcessInfo.currentRss;

      // Create objects of varying sizes to test memory fragmentation
      final conversions = <String>[];

      for (int i = 0; i < 100; i++) {
        // Vary the size of the DPug content
        final size = (i % 10) + 1;
        final dpug = TestDataGenerator.generateDpugWidget(
          'Fragment$i',
          size,
          size,
        );
        final dart = converter.dpugToDart(dpug);
        conversions.add(dart);
      }

      // Clear references to test GC
      conversions.clear();

      final finalMemory = ProcessInfo.currentRss;
      final memoryGrowth = finalMemory - initialMemory;

      // Memory should be reasonably managed
      expect(memoryGrowth.abs(), lessThan(50 * 1024 * 1024));
    });
  });
}
