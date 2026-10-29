import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cmd_palette_button.dart';
import '../../services/project_service.dart';
import 'models/file_node.dart';
import 'providers/file_tree_notifier.dart';
import 'providers/file_tree_state.dart';
import '../../services/file_service.dart' show openTabsProvider;
import 'file_context_menu.dart';
import 'widgets/file_creation_dialog.dart';
import 'widgets/file_icon.dart';
import 'widgets/folder_picker_sheet.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedPath;
  bool _isSelectedDirectory = false;
  Timer? _highlightClearTimer;

  @override
  void dispose() {
    _highlightClearTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _getParentPath(String path) {
    if (!path.contains('/') || path == '/') return '/';
    final lastSlash = path.lastIndexOf('/');
    return lastSlash <= 0 ? '/' : path.substring(0, lastSlash);
  }

  String get _currentTargetFolder {
    if (_selectedPath == null || _selectedPath!.isEmpty) return '/';
    return _isSelectedDirectory ? _selectedPath! : _getParentPath(_selectedPath!);
  }

  void _triggerHighlightClear() {
    _highlightClearTimer?.cancel();
    _highlightClearTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(fileTreeNotifierProvider.notifier).clearHighlight();
      }
    });
  }

  void _showAppBarCreateSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final targetFolder = _currentTargetFolder;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderHighlight : AppColors.lightBorderHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: AppColors.accentCyan, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Create inside: ${targetFolder == '/' ? 'Root (/)' : targetFolder}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Semantics(
                label: 'Create new file',
                button: true,
                child: ListTile(
                  leading: const Icon(Icons.note_add_outlined, size: 22, color: AppColors.primaryLight),
                  title: const Text('New File', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Create a file or nested path', style: TextStyle(fontSize: 12)),
                  minVerticalPadding: 14,
                  onTap: () {
                    Navigator.pop(ctx);
                    _promptCreate(parentPath: targetFolder, isFolder: false);
                  },
                ),
              ),
              Semantics(
                label: 'Create new folder',
                button: true,
                child: ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined, size: 22, color: AppColors.accentCyan),
                  title: const Text('New Folder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Create directory structure', style: TextStyle(fontSize: 12)),
                  minVerticalPadding: 14,
                  onTap: () {
                    Navigator.pop(ctx);
                    _promptCreate(parentPath: targetFolder, isFolder: true);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _promptCreate({required String parentPath, required bool isFolder}) {
    final treeAsync = ref.read(fileTreeNotifierProvider);
    final root = treeAsync.valueOrNull?.rootNode;
    if (root == null) return;

    FileCreationDialog.show(
      context: context,
      parentPath: parentPath,
      isFolder: isFolder,
      rootNode: root,
      onSubmit: (name) async {
        if (isFolder) {
          final created = await ref.read(fileTreeNotifierProvider.notifier).createFolder(parentPath, name);
          setState(() {
            _selectedPath = created.path;
            _isSelectedDirectory = true;
          });
          _triggerHighlightClear();
        } else {
          final created = await ref.read(fileTreeNotifierProvider.notifier).createFile(parentPath, name);
          setState(() {
            _selectedPath = created.path;
            _isSelectedDirectory = false;
          });
          _triggerHighlightClear();
          // Automatically open newly created file in Editor tab
          await ref.read(openTabsProvider.notifier).openFile(created.path, created.name);
          if (mounted) {
            context.go('/editor');
          }
        }
      },
    );
  }

  void _showRenameDialog(FileNode node) {
    final controller = TextEditingController(text: node.name);
    final treeAsync = ref.read(fileTreeNotifierProvider);
    final root = treeAsync.valueOrNull?.rootNode;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit_rounded, color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 8),
                Text('Rename ${node.isFolder ? 'Folder' : 'File'}'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'New name',
                    errorText: errorMsg,
                  ),
                  onChanged: (val) {
                    final trimmed = val.trim();
                    if (trimmed.isEmpty) {
                      setDialogState(() => errorMsg = 'Name cannot be empty');
                    } else if (trimmed.contains('/') || trimmed.contains(r'\')) {
                      setDialogState(() => errorMsg = 'Cannot contain path slashes');
                    } else if (root != null) {
                      final parent = root.findByPath(_getParentPath(node.path));
                      if (parent != null &&
                          parent.children.any((c) => c.name.toLowerCase() == trimmed.toLowerCase() && c.path != node.path)) {
                        setDialogState(() => errorMsg = 'An item with this name already exists');
                      } else {
                        setDialogState(() => errorMsg = null);
                      }
                    } else {
                      setDialogState(() => errorMsg = null);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: (errorMsg == null && controller.text.trim().isNotEmpty)
                    ? () async {
                        final newName = controller.text.trim();
                        if (newName == node.name) {
                          Navigator.pop(ctx);
                          return;
                        }
                        try {
                          final parent = _getParentPath(node.path);
                          final newPath = parent == '/' ? '/$newName' : '$parent/$newName';
                          await ref.read(fileTreeNotifierProvider.notifier).rename(node.path, newName);
                          ref.read(openTabsProvider.notifier).handleFileRenamed(node.path, newPath, newName);
                          if (mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setDialogState(() => errorMsg = e.toString().replaceFirst('FileSystemException: ', ''));
                        }
                      }
                    : null,
                child: const Text('Rename'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(FileNode node) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            const Text('Delete item?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${node.name}"${node.isFolder ? ' and all of its contents' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _performDeleteWithUndo(node);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteWithUndo(FileNode node) async {
    String? cachedContent;
    if (!node.isFolder) {
      try {
        cachedContent = await ref.read(fileServiceProvider).readFile(node.path);
      } catch (_) {}
    }

    // Close in editor tabs if open
    ref.read(openTabsProvider.notifier).closeTabByPath(node.path);
    await ref.read(fileTreeNotifierProvider.notifier).delete(node.path);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${node.name}"'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.accentCyan,
            onPressed: () async {
              try {
                if (node.isFolder) {
                  await ref.read(fileTreeNotifierProvider.notifier).createFolder(
                    _getParentPath(node.path),
                    node.name,
                  );
                } else {
                  final created = await ref.read(fileTreeNotifierProvider.notifier).createFile(
                    _getParentPath(node.path),
                    node.name,
                  );
                  if (cachedContent != null && cachedContent.isNotEmpty) {
                    await ref.read(fileServiceProvider).writeFile(created.path, cachedContent);
                  }
                  ref.read(openTabsProvider.notifier).openFile(created.path, created.name);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not restore: $e')),
                  );
                }
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _showMoveFolderPicker(FileNode node) async {
    final root = ref.read(fileTreeNotifierProvider).valueOrNull?.rootNode;
    if (root == null) return;

    final destPath = await FolderPickerSheet.show(
      context: context,
      rootNode: root,
      sourcePath: node.path,
    );

    if (destPath != null) {
      try {
        await ref.read(fileTreeNotifierProvider.notifier).move(node.path, destPath);
        final newPath = destPath == '/' ? '/${node.name}' : '$destPath/${node.name}';
        ref.read(openTabsProvider.notifier).handleFileRenamed(node.path, newPath, node.name);
        _triggerHighlightClear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Move failed: $e')),
          );
        }
      }
    }
  }

  void _copyPathToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Path copied: $path'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildNodeItem({
    required FileNode node,
    required int depth,
    required Set<String> expandedPaths,
    required String? highlightedPath,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPath == node.path;
    final isHighlighted = highlightedPath == node.path;
    final isExpanded = expandedPaths.contains(node.path);

    final rowContent = Container(
      constraints: const BoxConstraints(minHeight: 48), // Guaranteed 48dp minimum
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primaryLight.withOpacity(0.25)
            : (isSelected
                ? (isDark ? AppColors.primary.withOpacity(0.18) : AppColors.primary.withOpacity(0.12))
                : Colors.transparent),
        border: isSelected
            ? const Border(
                left: BorderSide(color: AppColors.accentCyan, width: 3.5),
              )
            : null,
      ),
      padding: EdgeInsets.only(
        left: 12.0 + (depth * 18.0),
        right: 8.0,
      ),
      child: Row(
        children: [
          // Folder expand arrow or indentation spacer
          if (node.isFolder)
            Semantics(
              label: isExpanded ? 'Collapse ${node.name}' : 'Expand ${node.name}',
              button: true,
              child: InkWell(
                onTap: () => ref.read(fileTreeNotifierProvider.notifier).toggleExpand(node.path),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                    size: 20,
                    color: isSelected ? AppColors.accentCyan : AppColors.darkTextMuted,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 28),

          // File / Folder icon
          FileIconWidget(
            fileName: node.name,
            isFolder: node.isFolder,
            isExpanded: isExpanded,
            size: 20,
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: Text(
              node.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: node.isFolder ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.accentCyan
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Git badge if any
          if (node.gitStatus != GitStatus.none && node.gitStatus.badgeLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: (node.gitStatus == GitStatus.modified ? AppColors.gitModified : AppColors.gitAdded)
                    .withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                node.gitStatus.badgeLabel!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: node.gitStatus == GitStatus.modified ? AppColors.gitModified : AppColors.gitAdded,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],

          // Quick create '+' button on folder rows
          if (node.isFolder)
            Semantics(
              label: 'Create inside ${node.name}',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.add_rounded, size: 20),
                tooltip: 'Create inside ${node.name}',
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // 48dp target
                onPressed: () {
                  setState(() {
                    _selectedPath = node.path;
                    _isSelectedDirectory = true;
                  });
                  _promptCreate(parentPath: node.path, isFolder: false);
                },
              ),
            ),
        ],
      ),
    );

    // Make row draggable and droppable
    Widget interactiveRow = Semantics(
      label: '${node.isFolder ? "Folder" : "File"}: ${node.name}',
      button: true,
      child: InkWell(
        onTap: () {
          if (node.isFolder) {
            setState(() {
              _selectedPath = node.path;
              _isSelectedDirectory = true;
            });
            ref.read(fileTreeNotifierProvider.notifier).toggleExpand(node.path);
          } else {
            setState(() {
              _selectedPath = node.path;
              _isSelectedDirectory = false;
            });
            ref.read(openTabsProvider.notifier).openFile(node.path, node.name);
            context.go('/editor');
          }
        },
        onLongPress: () {
          setState(() {
            _selectedPath = node.path;
            _isSelectedDirectory = node.isFolder;
          });
          FileContextMenuSheet.show(
            context: context,
            node: node,
            onNewFile: node.isFolder ? () => _promptCreate(parentPath: node.path, isFolder: false) : null,
            onNewFolder: node.isFolder ? () => _promptCreate(parentPath: node.path, isFolder: true) : null,
            onRename: () => _showRenameDialog(node),
            onDuplicate: () => ref.read(fileTreeNotifierProvider.notifier).duplicate(node.path),
            onMove: () => _showMoveFolderPicker(node),
            onCopyPath: () => _copyPathToClipboard(node.path),
            onDelete: () => _showDeleteDialog(node),
          );
        },
        child: rowContent,
      ),
    );

    // If this is a folder, wrap it with DragTarget to support drag-and-drop moving!
    if (node.isFolder) {
      interactiveRow = DragTarget<FileNode>(
        onWillAcceptWithDetails: (details) {
          final dragged = details.data;
          if (dragged.path == node.path) return false;
          if (dragged.isFolder && node.path.startsWith('${dragged.path}/')) return false;
          if (_getParentPath(dragged.path) == node.path) return false;
          return true;
        },
        onAcceptWithDetails: (details) async {
          final dragged = details.data;
          try {
            await ref.read(fileTreeNotifierProvider.notifier).move(dragged.path, node.path);
            final newPath = '${node.path}/${dragged.name}';
            ref.read(openTabsProvider.notifier).handleFileRenamed(dragged.path, newPath, dragged.name);
            _triggerHighlightClear();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Move failed: $e')),
              );
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            color: isHovering ? AppColors.accentCyan.withOpacity(0.2) : Colors.transparent,
            child: interactiveRow,
          );
        },
      );
    }

    // Wrap with LongPressDraggable so files and folders can be dragged
    interactiveRow = LongPressDraggable<FileNode>(
      data: node,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        color: surfaceColorFor(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FileIconWidget(fileName: node.name, isFolder: node.isFolder, size: 18),
              const SizedBox(width: 8),
              Text(node.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      child: interactiveRow,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        interactiveRow,
        if (node.isFolder && isExpanded)
          ...node.children.map((child) => _buildNodeItem(
                node: child,
                depth: depth + 1,
                expandedPaths: expandedPaths,
                highlightedPath: highlightedPath,
              )),
      ],
    );
  }

  static Color surfaceColorFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
  }

  List<FileNode> _filterTree(List<FileNode> nodes, String query) {
    if (query.isEmpty) return nodes;
    final List<FileNode> matched = [];
    final lower = query.toLowerCase();

    for (final node in nodes) {
      if (node.name.toLowerCase().contains(lower)) {
        matched.add(node);
      } else if (node.isFolder) {
        final filteredChildren = _filterTree(node.children, query);
        if (filteredChildren.isNotEmpty) {
          matched.add(node.copyWith(children: filteredChildren));
        }
      }
    }
    return matched;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 38,
                color: AppColors.accentCyan,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No files in workspace',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your project directory is empty. Get started by creating your first file or folder.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.note_add_rounded, size: 20),
                label: const Text('Create First File'),
                onPressed: () => _promptCreate(parentPath: '/', isFolder: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProject = ref.watch(currentProjectProvider);
    final treeAsync = ref.watch(fileTreeNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              currentProject?.name ?? 'Workspace',
              style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
            ),
          ],
        ),
        actions: [
          const CmdPaletteButton(),
          // "+" button opening New File / New Folder bottom sheet
          Semantics(
            label: 'Create new file or folder',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 24),
              tooltip: 'New file or folder',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: _showAppBarCreateSheet,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh Tree',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => ref.read(fileTreeNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                hintText: 'Search files by name...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Selected target indicator banner
          if (_selectedPath != null && _selectedPath!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.accentCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Target folder: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          TextSpan(
                            text: _currentTargetFolder == '/' ? 'root (/)' : '$_currentTargetFolder/',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentCyan,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => _promptCreate(parentPath: _currentTargetFolder, isFolder: false),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.note_add_outlined, size: 15, color: AppColors.primaryLight),
                          SizedBox(width: 4),
                          Text('+ File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _promptCreate(parentPath: _currentTargetFolder, isFolder: true),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.create_new_folder_outlined, size: 15, color: AppColors.accentCyan),
                          SizedBox(width: 4),
                          Text('+ Folder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentCyan)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: 'Deselect',
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      setState(() {
                        _selectedPath = null;
                        _isSelectedDirectory = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1),

          // File Tree with Pull-to-refresh
          Expanded(
            child: treeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                      const SizedBox(height: 12),
                      Text('Error loading workspace: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.read(fileTreeNotifierProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (treeState) {
                final rootNode = treeState.rootNode;
                if (rootNode.children.isEmpty) {
                  return _buildEmptyState();
                }

                final displayNodes = _filterTree(rootNode.children, _searchQuery);
                if (displayNodes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching files found',
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(fileTreeNotifierProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 90, top: 4),
                    children: displayNodes.map((n) {
                      return _buildNodeItem(
                        node: n,
                        depth: 0,
                        expandedPaths: treeState.expandedPaths,
                        highlightedPath: treeState.highlightedPath,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
