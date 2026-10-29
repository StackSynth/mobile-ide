import '../models/file_node.dart';

abstract class FileService {
  /// Loads the entire file tree for the specified [projectId].
  /// Returns the root [FileNode] containing all children recursively.
  Future<FileNode> loadTree(String projectId);

  /// Creates a new file at [parentPath] with [name].
  /// Supports nested paths in [name] (e.g. "components/ui/Button.jsx").
  /// Returns the created [FileNode].
  Future<FileNode> createFile(String parentPath, String name);

  /// Creates a new folder at [parentPath] with [name].
  /// Supports nested paths in [name] (e.g. "components/ui").
  /// Returns the created [FileNode].
  Future<FileNode> createFolder(String parentPath, String name);

  /// Renames an existing file or folder at [path] to [newName].
  Future<void> rename(String path, String newName);

  /// Deletes the file or directory at [path].
  Future<void> delete(String path);

  /// Moves the file or folder at [fromPath] into [toParentPath].
  Future<void> move(String fromPath, String toParentPath);

  /// Reads and returns the UTF-8 text content of the file at [path].
  Future<String> readFile(String path);

  /// Writes [content] into the file at [path], creating parents if needed.
  Future<void> writeFile(String path, String content);
}

class FileSystemException implements Exception {
  final String message;
  const FileSystemException(this.message);

  @override
  String toString() => message;
}
