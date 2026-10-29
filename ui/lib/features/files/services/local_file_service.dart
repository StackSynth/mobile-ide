import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/file_node.dart';
import 'file_service.dart';

class LocalFileService implements FileService {
  final Future<Directory> Function()? baseDirProvider;
  Directory? _currentProjectDir;
  String? _currentProjectId;

  LocalFileService({this.baseDirProvider});

  Future<Directory> _getBaseDir() async {
    final provider = baseDirProvider;
    if (provider != null) {
      return await provider();
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory> _getProjectDir(String projectId) async {
    if (_currentProjectId == projectId && _currentProjectDir != null) {
      return _currentProjectDir!;
    }
    final base = await _getBaseDir();
    final dir = Directory(p.join(base.path, 'projects', projectId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _currentProjectId = projectId;
    _currentProjectDir = dir;
    return dir;
  }

  Future<Directory> _ensureActiveProjectDir() async {
    if (_currentProjectDir != null && await _currentProjectDir!.exists()) {
      return _currentProjectDir!;
    }
    return _getProjectDir(_currentProjectId ?? 'proj_react_vite');
  }

  static void validateName(String name, {bool allowSlash = false}) {
    if (name.trim().isEmpty) {
      throw const FileSystemException('Name cannot be empty');
    }
    if (name.length > 255) {
      throw const FileSystemException('Name cannot exceed 255 characters');
    }

    final segments = allowSlash ? name.split('/') : [name];
    for (final seg in segments) {
      final trimmed = seg.trim();
      if (trimmed.isEmpty) {
        throw const FileSystemException('Path segment cannot be empty');
      }
      if (trimmed == '.' || trimmed == '..') {
        throw const FileSystemException('Invalid name');
      }
      // Check invalid characters: \ : * ? " < > |
      const invalidChars = r'\:*?"<>|';
      for (int i = 0; i < trimmed.length; i++) {
        if (invalidChars.contains(trimmed[i])) {
          throw FileSystemException('Name contains invalid character: "${trimmed[i]}"');
        }
      }
    }
  }

  String _toLocalPath(Directory projectDir, String unixPath) {
    var clean = unixPath.replaceAll(r'\', '/');
    while (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    if (clean.isEmpty) {
      return projectDir.path;
    }
    return p.join(projectDir.path, p.normalize(clean));
  }

  String _toUnixPath(Directory projectDir, String localPath) {
    final rel = p.relative(localPath, from: projectDir.path);
    if (rel == '.' || rel.isEmpty) {
      return '/';
    }
    final unix = rel.replaceAll(r'\', '/');
    return unix.startsWith('/') ? unix : '/$unix';
  }

  @override
  Future<FileNode> loadTree(String projectId) async {
    final projectDir = await _getProjectDir(projectId);
    return _buildNodeFromDir(projectDir, projectDir);
  }

  Future<FileNode> _buildNodeFromDir(Directory rootDir, Directory currentDir) async {
    final unixPath = _toUnixPath(rootDir, currentDir.path);
    final isRoot = currentDir.path == rootDir.path;
    final name = isRoot ? (rootDir.path.split(p.separator).last) : p.basename(currentDir.path);

    final children = <FileNode>[];
    if (await currentDir.exists()) {
      final entries = currentDir.listSync(followLinks: false);
      for (final entity in entries) {
        if (entity is Directory) {
          children.add(await _buildNodeFromDir(rootDir, entity));
        } else if (entity is File) {
          final fileUnix = _toUnixPath(rootDir, entity.path);
          final stat = entity.statSync();
          children.add(FileNode(
            id: fileUnix,
            name: p.basename(entity.path),
            path: fileUnix,
            isFolder: false,
            createdAt: stat.changed,
            modifiedAt: stat.modified,
            gitStatus: GitStatus.none,
          ));
        }
      }
    }

    // Sort folders first, then files, alphabetically
    children.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    final stat = currentDir.existsSync() ? currentDir.statSync() : null;
    return FileNode(
      id: unixPath,
      name: name,
      path: unixPath,
      isFolder: true,
      children: List.unmodifiable(children),
      createdAt: stat?.changed,
      modifiedAt: stat?.modified,
      gitStatus: GitStatus.none,
    );
  }

  @override
  Future<FileNode> createFile(String parentPath, String name) async {
    validateName(name, allowSlash: true);
    final projectDir = await _ensureActiveProjectDir();

    final cleanParent = parentPath.replaceAll(r'\', '/');
    final combined = cleanParent == '/' || cleanParent.isEmpty
        ? name
        : '${cleanParent.endsWith('/') ? cleanParent : '$cleanParent/'}$name';

    final targetLocalPath = _toLocalPath(projectDir, combined);
    final file = File(targetLocalPath);

    if (await file.exists() || await Directory(targetLocalPath).exists()) {
      throw FileSystemException('A file or folder with name "${p.basename(targetLocalPath)}" already exists');
    }

    // Ensure parent directories exist
    final parentDir = file.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    await file.writeAsString('', flush: true);
    final unixPath = _toUnixPath(projectDir, file.path);
    final stat = await file.stat();

    return FileNode(
      id: unixPath,
      name: p.basename(file.path),
      path: unixPath,
      isFolder: false,
      createdAt: stat.changed,
      modifiedAt: stat.modified,
      gitStatus: GitStatus.newFile,
    );
  }

  @override
  Future<FileNode> createFolder(String parentPath, String name) async {
    validateName(name, allowSlash: true);
    final projectDir = await _ensureActiveProjectDir();

    final cleanParent = parentPath.replaceAll(r'\', '/');
    final combined = cleanParent == '/' || cleanParent.isEmpty
        ? name
        : '${cleanParent.endsWith('/') ? cleanParent : '$cleanParent/'}$name';

    final targetLocalPath = _toLocalPath(projectDir, combined);
    final dir = Directory(targetLocalPath);

    if (await dir.exists() || await File(targetLocalPath).exists()) {
      throw FileSystemException('A file or folder with name "${p.basename(targetLocalPath)}" already exists');
    }

    await dir.create(recursive: true);
    final unixPath = _toUnixPath(projectDir, dir.path);
    final stat = await dir.stat();

    return FileNode(
      id: unixPath,
      name: p.basename(dir.path),
      path: unixPath,
      isFolder: true,
      children: const [],
      createdAt: stat.changed,
      modifiedAt: stat.modified,
      gitStatus: GitStatus.newFile,
    );
  }

  @override
  Future<void> rename(String path, String newName) async {
    validateName(newName, allowSlash: false);
    final projectDir = await _ensureActiveProjectDir();

    final oldLocalPath = _toLocalPath(projectDir, path);
    final isDir = await Directory(oldLocalPath).exists();
    final isFile = await File(oldLocalPath).exists();

    if (!isDir && !isFile) {
      throw FileSystemException('Item "$path" does not exist');
    }

    final parentDir = p.dirname(oldLocalPath);
    final newLocalPath = p.join(parentDir, newName);

    if (await File(newLocalPath).exists() || await Directory(newLocalPath).exists()) {
      throw FileSystemException('A file or folder with name "$newName" already exists');
    }

    if (isDir) {
      await Directory(oldLocalPath).rename(newLocalPath);
    } else {
      await File(oldLocalPath).rename(newLocalPath);
    }
  }

  @override
  Future<void> delete(String path) async {
    final projectDir = await _ensureActiveProjectDir();
    final localPath = _toLocalPath(projectDir, path);

    if (await Directory(localPath).exists()) {
      await Directory(localPath).delete(recursive: true);
    } else if (await File(localPath).exists()) {
      await File(localPath).delete();
    } else {
      throw FileSystemException('Item "$path" not found');
    }
  }

  @override
  Future<void> move(String fromPath, String toParentPath) async {
    final projectDir = await _ensureActiveProjectDir();
    final fromLocal = _toLocalPath(projectDir, fromPath);
    final toParentLocal = _toLocalPath(projectDir, toParentPath);

    final isDir = await Directory(fromLocal).exists();
    final isFile = await File(fromLocal).exists();

    if (!isDir && !isFile) {
      throw FileSystemException('Source "$fromPath" does not exist');
    }

    final itemName = p.basename(fromLocal);
    final destLocal = p.join(toParentLocal, itemName);

    // Prevent moving into itself or a subfolder of itself
    if (isDir) {
      final canonicalFrom = Directory(fromLocal).resolveSymbolicLinksSync();
      final targetParentDir = Directory(toParentLocal);
      if (targetParentDir.existsSync()) {
        final canonicalDest = targetParentDir.resolveSymbolicLinksSync();
        if (canonicalDest == canonicalFrom || p.isWithin(canonicalFrom, canonicalDest)) {
          throw const FileSystemException('Cannot move a folder into itself or its child');
        }
      }
    }

    if (await File(destLocal).exists() || await Directory(destLocal).exists()) {
      throw FileSystemException('Destination already contains an item named "$itemName"');
    }

    if (isDir) {
      await Directory(fromLocal).rename(destLocal);
    } else {
      await File(fromLocal).rename(destLocal);
    }
  }

  @override
  Future<String> readFile(String path) async {
    final projectDir = await _ensureActiveProjectDir();
    final localPath = _toLocalPath(projectDir, path);
    final file = File(localPath);
    if (!await file.exists()) {
      throw FileSystemException('File "$path" does not exist');
    }
    return await file.readAsString();
  }

  @override
  Future<void> writeFile(String path, String content) async {
    final projectDir = await _ensureActiveProjectDir();
    final localPath = _toLocalPath(projectDir, path);
    final file = File(localPath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(content, flush: true);
  }
}
