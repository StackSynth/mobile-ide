import 'package:flutter/foundation.dart';
import '../models/file_node.dart';

@immutable
class FileTreeState {
  final FileNode rootNode;
  final Set<String> expandedPaths;
  final String? highlightedPath;

  const FileTreeState({
    required this.rootNode,
    this.expandedPaths = const {},
    this.highlightedPath,
  });

  bool isExpanded(String path) => expandedPaths.contains(path);

  FileTreeState copyWith({
    FileNode? rootNode,
    Set<String>? expandedPaths,
    String? highlightedPath,
    bool clearHighlight = false,
  }) {
    return FileTreeState(
      rootNode: rootNode ?? this.rootNode,
      expandedPaths: expandedPaths ?? this.expandedPaths,
      highlightedPath: clearHighlight ? null : (highlightedPath ?? this.highlightedPath),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTreeState &&
          runtimeType == other.runtimeType &&
          rootNode == other.rootNode &&
          setEquals(expandedPaths, other.expandedPaths) &&
          highlightedPath == other.highlightedPath;

  @override
  int get hashCode => Object.hash(
        rootNode,
        Object.hashAll(expandedPaths),
        highlightedPath,
      );
}
