import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/files/services/file_service.dart';
import 'package:my_app/features/files/services/local_file_service.dart';

void main() {
  late Directory tempDir;
  late LocalFileService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mobile_ide_test_');
    service = LocalFileService(baseDirProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalFileService Tests', () {
    test('loadTree creates project folder and returns root FileNode', () async {
      final root = await service.loadTree('test_proj');
      expect(root.isFolder, isTrue);
      expect(root.path, equals('/'));
    });

    test('createFile creates nested folders and file in one go', () async {
      await service.loadTree('test_proj');
      final node = await service.createFile('/', 'src/components/Button.jsx');

      expect(node.name, equals('Button.jsx'));
      expect(node.path, equals('/src/components/Button.jsx'));
      expect(node.isFolder, isFalse);

      final tree = await service.loadTree('test_proj');
      final src = tree.findByPath('/src');
      expect(src, isNotNull);
      expect(src!.isFolder, isTrue);

      final components = tree.findByPath('/src/components');
      expect(components, isNotNull);

      final button = tree.findByPath('/src/components/Button.jsx');
      expect(button, isNotNull);
    });

    test('createFile with duplicate name throws FileSystemException', () async {
      await service.loadTree('test_proj');
      await service.createFile('/', 'index.js');

      expect(
        () => service.createFile('/', 'index.js'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('rename renames file and folder properly', () async {
      await service.loadTree('test_proj');
      await service.createFile('/', 'oldName.txt');
      await service.rename('/oldName.txt', 'newName.txt');

      final tree = await service.loadTree('test_proj');
      expect(tree.findByPath('/oldName.txt'), isNull);
      expect(tree.findByPath('/newName.txt'), isNotNull);
    });

    test('delete removes file or folder from filesystem', () async {
      await service.loadTree('test_proj');
      await service.createFile('/', 'temp.txt');
      await service.delete('/temp.txt');

      final tree = await service.loadTree('test_proj');
      expect(tree.findByPath('/temp.txt'), isNull);
    });

    test('move moves item into destination folder', () async {
      await service.loadTree('test_proj');
      await service.createFolder('/', 'assets');
      await service.createFile('/', 'logo.png');

      await service.move('/logo.png', '/assets');

      final tree = await service.loadTree('test_proj');
      expect(tree.findByPath('/logo.png'), isNull);
      expect(tree.findByPath('/assets/logo.png'), isNotNull);
    });

    test('move folder into itself or child throws FileSystemException', () async {
      await service.loadTree('test_proj');
      await service.createFolder('/', 'parent');
      await service.createFolder('/parent', 'child');

      expect(
        () => service.move('/parent', '/parent/child'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('readFile and writeFile handle UTF-8 text properly', () async {
      await service.loadTree('test_proj');
      await service.createFile('/', 'hello.txt');
      await service.writeFile('/hello.txt', 'Hello, Flutter IDE!');

      final content = await service.readFile('/hello.txt');
      expect(content, equals('Hello, Flutter IDE!'));
    });
  });
}
