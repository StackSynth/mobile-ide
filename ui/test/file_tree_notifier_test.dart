import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/files/providers/file_tree_notifier.dart';
import 'package:my_app/features/files/services/file_service.dart';
import 'package:my_app/features/files/services/local_file_service.dart';

void main() {
  late Directory tempDir;
  late LocalFileService localService;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ide_notifier_test_');
    localService = LocalFileService(baseDirProvider: () async => tempDir);
    container = ProviderContainer(
      overrides: [
        fileServiceProvider.overrideWithValue(localService),
        activeProjectIdProvider.overrideWith((ref) => 'test_proj'),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileTreeNotifier Tests', () {
    test('initializes and loads file tree', () async {
      final state = await container.read(fileTreeNotifierProvider.future);
      expect(state.rootNode, isNotNull);
      expect(state.rootNode.isFolder, isTrue);
      expect(state.expandedPaths, contains('/'));
    });

    test('toggleExpand updates expandedPaths', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      notifier.toggleExpand('/src');
      var state = container.read(fileTreeNotifierProvider).value!;
      expect(state.expandedPaths.contains('/src'), isTrue);

      notifier.toggleExpand('/src');
      state = container.read(fileTreeNotifierProvider).value!;
      expect(state.expandedPaths.contains('/src'), isFalse);
    });

    test('createFile creates file and auto-expands parent', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      final node = await notifier.createFile('/', 'main.dart');
      expect(node.name, equals('main.dart'));

      final state = container.read(fileTreeNotifierProvider).value!;
      expect(state.rootNode.findByPath('/main.dart'), isNotNull);
      expect(state.highlightedPath, equals('/main.dart'));
    });

    test('createFile with nested path expands all parents', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      final node = await notifier.createFile('/', 'src/utils/helpers.dart');
      expect(node.name, equals('helpers.dart'));

      final state = container.read(fileTreeNotifierProvider).value!;
      expect(state.expandedPaths.contains('/src'), isTrue);
      expect(state.expandedPaths.contains('/src/utils'), isTrue);
    });

    test('createFolder creates folder and auto-expands it', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      final folder = await notifier.createFolder('/', 'components');
      expect(folder.isFolder, isTrue);

      final state = container.read(fileTreeNotifierProvider).value!;
      expect(state.expandedPaths.contains('/components'), isTrue);
    });

    test('duplicate name rolls back optimistic state and throws error', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      await notifier.createFile('/', 'unique.txt');

      expect(
        () => notifier.createFile('/', 'unique.txt'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('rename updates node in tree and preserves expansion', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      await notifier.createFile('/', 'initial.txt');
      await notifier.rename('/initial.txt', 'renamed.txt');

      final state = container.read(fileTreeNotifierProvider).value!;
      expect(state.rootNode.findByPath('/initial.txt'), isNull);
      expect(state.rootNode.findByPath('/renamed.txt'), isNotNull);
    });

    test('delete removes node from tree', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      await notifier.createFile('/', 'to_delete.txt');
      await notifier.delete('/to_delete.txt');

      final state = container.read(fileTreeNotifierProvider).value!;
      expect(state.rootNode.findByPath('/to_delete.txt'), isNull);
    });

    test('move updates node location in tree', () async {
      await container.read(fileTreeNotifierProvider.future);
      final notifier = container.read(fileTreeNotifierProvider.notifier);

      await notifier.createFolder('/', 'folderA');
      await notifier.createFile('/', 'item.txt');
      await notifier.move('/item.txt', '/folderA');

      final state = container.read(fileTreeNotifierProvider).value!;
      expect(state.rootNode.findByPath('/item.txt'), isNull);
      expect(state.rootNode.findByPath('/folderA/item.txt'), isNotNull);
    });
  });
}
