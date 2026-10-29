import 'package:flutter/foundation.dart';

enum GitStatus {
  none,
  modified,
  newFile;

  String? get badgeLabel {
    switch (this) {
      case GitStatus.modified:
        return 'M';
      case GitStatus.newFile:
        return 'U';
      case GitStatus.none:
        return null;
    }
  }

  bool get isNew => this == GitStatus.newFile;
  bool get isModified => this == GitStatus.modified;
}

@immutable
class FileNode {
  final String id;
  final String name;
  final String path;
  final bool isFolder;
  final List<FileNode> children;
  final String? content;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final GitStatus gitStatus;

  const FileNode({
    required this.id,
    required this.name,
    required this.path,
    this.isFolder = false,
    this.children = const [],
    this.content,
    this.createdAt,
    this.modifiedAt,
    this.gitStatus = GitStatus.none,
  });

  bool get isDirectory => isFolder;

  String get extension {
    if (isFolder) return '';
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  FileNode copyWith({
    String? id,
    String? name,
    String? path,
    bool? isFolder,
    List<FileNode>? children,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    GitStatus? gitStatus,
  }) {
    return FileNode(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      isFolder: isFolder ?? this.isFolder,
      children: children ?? this.children,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      gitStatus: gitStatus ?? this.gitStatus,
    );
  }

  /// Searches for a node with the given unix path recursively.
  FileNode? findByPath(String targetPath) {
    if (path == targetPath) return this;
    for (final child in children) {
      final found = child.findByPath(targetPath);
      if (found != null) return found;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          path == other.path &&
          isFolder == other.isFolder &&
          content == other.content &&
          gitStatus == other.gitStatus &&
          listEquals(children, other.children);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        path,
        isFolder,
        content,
        gitStatus,
        Object.hashAll(children),
      );

  @override
  String toString() {
    return 'FileNode(path: $path, isFolder: $isFolder, children: ${children.length})';
  }
}
