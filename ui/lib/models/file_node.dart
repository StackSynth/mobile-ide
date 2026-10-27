enum GitFileStatus {
  unmodified,
  modified,
  added,
  deleted;

  String? get badgeLabel {
    switch (this) {
      case GitFileStatus.modified:
        return 'M';
      case GitFileStatus.added:
        return 'U'; // untracked/new
      case GitFileStatus.deleted:
        return 'D';
      case GitFileStatus.unmodified:
        return null;
    }
  }
}

class FileNode {
  final String path;
  final String name;
  final bool isDirectory;
  final List<FileNode> children;
  final GitFileStatus gitStatus;
  final String? content;
  final bool isExpanded;

  const FileNode({
    required this.path,
    required this.name,
    this.isDirectory = false,
    this.children = const [],
    this.gitStatus = GitFileStatus.unmodified,
    this.content,
    this.isExpanded = false,
  });

  FileNode copyWith({
    String? path,
    String? name,
    bool? isDirectory,
    List<FileNode>? children,
    GitFileStatus? gitStatus,
    String? content,
    bool? isExpanded,
  }) {
    return FileNode(
      path: path ?? this.path,
      name: name ?? this.name,
      isDirectory: isDirectory ?? this.isDirectory,
      children: children ?? this.children,
      gitStatus: gitStatus ?? this.gitStatus,
      content: content ?? this.content,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  String get extension {
    if (isDirectory) return '';
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }
}

class OpenFileTab {
  final String path;
  final String name;
  final bool isDirty;
  final String content;

  const OpenFileTab({
    required this.path,
    required this.name,
    this.isDirty = false,
    required this.content,
  });

  OpenFileTab copyWith({
    String? path,
    String? name,
    bool? isDirty,
    String? content,
  }) {
    return OpenFileTab(
      path: path ?? this.path,
      name: name ?? this.name,
      isDirty: isDirty ?? this.isDirty,
      content: content ?? this.content,
    );
  }
}
