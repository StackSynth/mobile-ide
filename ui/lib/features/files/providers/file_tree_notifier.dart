import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/file_node.dart';
import '../services/file_service.dart';
import '../services/local_file_service.dart';
import 'file_tree_state.dart';

// In-memory persistence per project for expanded folders
final Map<String, Set<String>> _persistedExpandedFolders = {};

final fileServiceProvider = Provider<FileService>((ref) {
  return LocalFileService();
});

final activeProjectIdProvider = StateProvider<String>((ref) {
  return 'proj_react_vite';
});

final fileTreeNotifierProvider =
    AsyncNotifierProvider<FileTreeNotifier, FileTreeState>(FileTreeNotifier.new);

class FileTreeNotifier extends AsyncNotifier<FileTreeState> {
  FileService get _service => ref.read(fileServiceProvider);
  String get _projectId => ref.read(activeProjectIdProvider);

  @override
  Future<FileTreeState> build() async {
    final projectId = ref.watch(activeProjectIdProvider);
    final service = ref.watch(fileServiceProvider);

    final root = await service.loadTree(projectId);
    final persisted = _persistedExpandedFolders[projectId] ?? {'/', ..._collectInitialExpanded(root)};
    _persistedExpandedFolders[projectId] = persisted;

    return FileTreeState(
      rootNode: root,
      expandedPaths: persisted,
    );
  }

  Set<String> _collectInitialExpanded(FileNode node) {
    final result = <String>{};
    if (node.isFolder) {
      result.add(node.path);
      for (final child in node.children) {
        if (child.isFolder) {
          result.add(child.path);
        }
      }
    }
    return result;
  }

  void _persistExpanded(Set<String> expanded) {
    _persistedExpandedFolders[_projectId] = Set.from(expanded);
  }

  void toggleExpand(String path) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newExpanded = Set<String>.from(current.expandedPaths);
    if (newExpanded.contains(path)) {
      newExpanded.remove(path);
    } else {
      newExpanded.add(path);
    }
    _persistExpanded(newExpanded);
    state = AsyncData(current.copyWith(expandedPaths: newExpanded));
  }

  void expandFolder(String path) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newExpanded = Set<String>.from(current.expandedPaths);
    _expandParents(path, newExpanded);
    _persistExpanded(newExpanded);
    state = AsyncData(current.copyWith(expandedPaths: newExpanded));
  }

  void _expandParents(String path, Set<String> expanded) {
    expanded.add(path);
    var current = path;
    while (current.contains('/') && current != '/') {
      final lastSlash = current.lastIndexOf('/');
      current = lastSlash <= 0 ? '/' : current.substring(0, lastSlash);
      expanded.add(current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final root = await _service.loadTree(_projectId);
      final persisted = _persistedExpandedFolders[_projectId] ?? {'/'};
      return FileTreeState(rootNode: root, expandedPaths: persisted);
    });
  }

  Future<FileNode> createFile(String parentPath, String name) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw const FileSystemException('File tree not loaded');
    }

    final normalizedParent = _normalizeUnix(parentPath);
    // Optimistic placeholder node
    final tempPath = normalizedParent == '/' ? '/$name' : '$normalizedParent/$name';
    final tempNode = FileNode(
      id: tempPath,
      name: p.basename(tempPath),
      path: tempPath,
      isFolder: false,
      gitStatus: GitStatus.newFile,
    );

    final expandedWithParent = Set<String>.from(current.expandedPaths);
    _expandParents(normalizedParent, expandedWithParent);
    final optimisticTree = _addNodeToTree(current.rootNode, normalizedParent, tempNode);
    state = AsyncData(current.copyWith(
      rootNode: optimisticTree,
      expandedPaths: expandedWithParent,
      highlightedPath: tempPath,
    ));

    try {
      final actualNode = await _service.createFile(normalizedParent, name);
      // Reload actual tree to ensure accurate file structure
      final updatedRoot = await _service.loadTree(_projectId);
      final finalExpanded = Set<String>.from(expandedWithParent);
      _expandParents(_parentOf(actualNode.path), finalExpanded);
      _persistExpanded(finalExpanded);

      state = AsyncData(current.copyWith(
        rootNode: updatedRoot,
        expandedPaths: finalExpanded,
        highlightedPath: actualNode.path,
      ));
      return actualNode;
    } catch (e, st) {
      // Rollback to original state on failure
      state = AsyncData(current);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<FileNode> createFolder(String parentPath, String name) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw const FileSystemException('File tree not loaded');
    }

    final normalizedParent = _normalizeUnix(parentPath);
    final tempPath = normalizedParent == '/' ? '/$name' : '$normalizedParent/$name';
    final tempNode = FileNode(
      id: tempPath,
      name: p.basename(tempPath),
      path: tempPath,
      isFolder: true,
      children: const [],
      gitStatus: GitStatus.newFile,
    );

    final expandedWithParent = Set<String>.from(current.expandedPaths);
    _expandParents(normalizedParent, expandedWithParent);
    expandedWithParent.add(tempPath);

    final optimisticTree = _addNodeToTree(current.rootNode, normalizedParent, tempNode);
    state = AsyncData(current.copyWith(
      rootNode: optimisticTree,
      expandedPaths: expandedWithParent,
      highlightedPath: tempPath,
    ));

    try {
      final actualNode = await _service.createFolder(normalizedParent, name);
      final updatedRoot = await _service.loadTree(_projectId);
      final finalExpanded = Set<String>.from(expandedWithParent);
      _expandParents(actualNode.path, finalExpanded);
      _persistExpanded(finalExpanded);

      state = AsyncData(current.copyWith(
        rootNode: updatedRoot,
        expandedPaths: finalExpanded,
        highlightedPath: actualNode.path,
      ));
      return actualNode;
    } catch (e, st) {
      // Rollback
      state = AsyncData(current);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> rename(String path, String newName) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final normalized = _normalizeUnix(path);
    final parent = _parentOf(normalized);
    final newPath = parent == '/' ? '/$newName' : '$parent/$newName';

    final optimisticTree = _renameInTree(current.rootNode, normalized, newPath, newName);
    final updatedExpanded = current.expandedPaths.map((p) {
      if (p == normalized) return newPath;
      if (p.startsWith('$normalized/')) return p.replaceFirst(normalized, newPath);
      return p;
    }).toSet();

    state = AsyncData(current.copyWith(
      rootNode: optimisticTree,
      expandedPaths: updatedExpanded,
    ));

    try {
      await _service.rename(normalized, newName);
      final updatedRoot = await _service.loadTree(_projectId);
      _persistExpanded(updatedExpanded);
      state = AsyncData(current.copyWith(
        rootNode: updatedRoot,
        expandedPaths: updatedExpanded,
      ));
    } catch (e, st) {
      // Rollback
      state = AsyncData(current);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> delete(String path) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final normalized = _normalizeUnix(path);
    final optimisticTree = _removeFromTree(current.rootNode, normalized);
    final updatedExpanded = current.expandedPaths.where((p) => p != normalized && !p.startsWith('$normalized/')).toSet();

    state = AsyncData(current.copyWith(
      rootNode: optimisticTree,
      expandedPaths: updatedExpanded,
    ));

    try {
      await _service.delete(normalized);
      final updatedRoot = await _service.loadTree(_projectId);
      _persistExpanded(updatedExpanded);
      state = AsyncData(current.copyWith(
        rootNode: updatedRoot,
        expandedPaths: updatedExpanded,
      ));
    } catch (e, st) {
      // Rollback
      state = AsyncData(current);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> move(String fromPath, String toParentPath) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final normalizedFrom = _normalizeUnix(fromPath);
    final normalizedToParent = _normalizeUnix(toParentPath);
    final itemName = p.basename(normalizedFrom);
    final targetPath = normalizedToParent == '/' ? '/$itemName' : '$normalizedToParent/$itemName';

    final optimisticTree = _moveInTree(current.rootNode, normalizedFrom, normalizedToParent);
    final updatedExpanded = Set<String>.from(current.expandedPaths);
    _expandParents(normalizedToParent, updatedExpanded);

    state = AsyncData(current.copyWith(
      rootNode: optimisticTree,
      expandedPaths: updatedExpanded,
      highlightedPath: targetPath,
    ));

    try {
      await _service.move(normalizedFrom, normalizedToParent);
      final updatedRoot = await _service.loadTree(_projectId);
      _persistExpanded(updatedExpanded);
      state = AsyncData(current.copyWith(
        rootNode: updatedRoot,
        expandedPaths: updatedExpanded,
        highlightedPath: targetPath,
      ));
    } catch (e, st) {
      // Rollback
      state = AsyncData(current);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> duplicate(String path) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final node = current.rootNode.findByPath(path);
    if (node == null) return;
    final parent = _parentOf(path);

    if (node.isFolder) {
      final copyName = '${node.name}-copy';
      await createFolder(parent, copyName);
    } else {
      final dot = node.name.lastIndexOf('.');
      final copyName = dot != -1
          ? '${node.name.substring(0, dot)}.copy${node.name.substring(dot)}'
          : '${node.name}.copy';
      final created = await createFile(parent, copyName);
      try {
        final content = await _service.readFile(path);
        await _service.writeFile(created.path, content);
      } catch (_) {}
    }
  }

  void clearHighlight() {
    final current = state.valueOrNull;
    if (current != null && current.highlightedPath != null) {
      state = AsyncData(current.copyWith(clearHighlight: true));
    }
  }

  // --- Helper Tree Transforms ---
  static String _normalizeUnix(String path) {
    var clean = path.replaceAll(r'\', '/');
    if (!clean.startsWith('/')) clean = '/$clean';
    while (clean.endsWith('/') && clean.length > 1) {
      clean = clean.substring(0, clean.length - 1);
    }
    return clean;
  }

  static String _parentOf(String path) {
    final clean = _normalizeUnix(path);
    if (!clean.contains('/') || clean == '/') return '/';
    final idx = clean.lastIndexOf('/');
    return idx == 0 ? '/' : clean.substring(0, idx);
  }

  static FileNode _addNodeToTree(FileNode current, String targetParent, FileNode newNode) {
    if (current.path == targetParent) {
      final children = List<FileNode>.from(current.children)
        ..removeWhere((c) => c.name == newNode.name)
        ..add(newNode);
      _sortNodes(children);
      return current.copyWith(children: children);
    }

    final updatedChildren = current.children.map((child) {
      if (child.isFolder) {
        return _addNodeToTree(child, targetParent, newNode);
      }
      return child;
    }).toList();

    return current.copyWith(children: updatedChildren);
  }

  static FileNode _removeFromTree(FileNode current, String pathToRemove) {
    final updatedChildren = current.children
        .where((c) => c.path != pathToRemove)
        .map((child) => child.isFolder ? _removeFromTree(child, pathToRemove) : child)
        .toList();
    return current.copyWith(children: updatedChildren);
  }

  static FileNode _renameInTree(FileNode current, String oldPath, String newPath, String newName) {
    if (current.path == oldPath) {
      return current.copyWith(
        name: newName,
        path: newPath,
        children: current.children.map((child) {
          final rel = child.path.substring(oldPath.length);
          return _renameInTree(child, child.path, '$newPath$rel', child.name);
        }).toList(),
      );
    }

    final updatedChildren = current.children.map((child) {
      if (child.path == oldPath || child.path.startsWith('$oldPath/')) {
        return _renameInTree(child, oldPath, newPath, newName);
      }
      if (child.isFolder) {
        return _renameInTree(child, oldPath, newPath, newName);
      }
      return child;
    }).toList();

    return current.copyWith(children: updatedChildren);
  }

  static FileNode _moveInTree(FileNode root, String fromPath, String toParentPath) {
    final nodeToMove = root.findByPath(fromPath);
    if (nodeToMove == null) return root;

    // Remove from old location
    final withoutNode = _removeFromTree(root, fromPath);
    // Add to new parent with updated path
    final itemName = p.basename(fromPath);
    final newPath = toParentPath == '/' ? '/$itemName' : '$toParentPath/$itemName';
    final updatedNode = _updatePathRecursively(nodeToMove, newPath);

    return _addNodeToTree(withoutNode, toParentPath, updatedNode);
  }

  static FileNode _updatePathRecursively(FileNode node, String newPath) {
    final updatedChildren = node.children.map((c) {
      final childNewPath = '$newPath/${c.name}';
      return _updatePathRecursively(c, childNewPath);
    }).toList();

    return node.copyWith(
      path: newPath,
      name: p.basename(newPath),
      children: updatedChildren,
    );
  }

  static void _sortNodes(List<FileNode> nodes) {
    nodes.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }
}
