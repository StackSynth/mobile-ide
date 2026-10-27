import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/file_node.dart';
import '../../services/file_service.dart';
import '../../services/project_service.dart';
import 'file_context_menu.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewFileDialog({String parentPath = '', bool isDirectory = false}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isDirectory ? 'New Folder' : 'New File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isDirectory ? 'folder-name' : 'filename.tsx',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(fileTreeNotifierProvider.notifier)
                    .createFile(parentPath, name, isDirectory);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(FileNode node) {
    final controller = TextEditingController(text: node.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != node.name) {
                ref
                    .read(fileTreeNotifierProvider.notifier)
                    .renameFile(node.path, newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(FileNode node) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${node.name}?'),
        content: Text(
          node.isDirectory
              ? 'Are you sure you want to delete this folder and all its contents?'
              : 'Are you sure you want to delete this file?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(fileTreeNotifierProvider.notifier).deleteFile(node.path);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(FileNode node) {
    if (node.isDirectory) {
      return node.isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded;
    }
    final ext = node.extension;
    switch (ext) {
      case 'ts':
      case 'tsx':
        return Icons.code_rounded;
      case 'js':
      case 'jsx':
        return Icons.javascript_rounded;
      case 'css':
        return Icons.style_rounded;
      case 'json':
        return Icons.data_object_rounded;
      case 'md':
        return Icons.article_outlined;
      case 'py':
        return Icons.terminal_rounded;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileIconColor(FileNode node) {
    if (node.isDirectory) return AppColors.accentCyan;
    final ext = node.extension;
    switch (ext) {
      case 'ts':
      case 'tsx':
        return const Color(0xFF38BDF8);
      case 'js':
      case 'jsx':
        return const Color(0xFFFBBF24);
      case 'css':
        return const Color(0xFFEC4899);
      case 'json':
        return const Color(0xFFA855F7);
      case 'md':
        return AppColors.darkTextMuted;
      default:
        return AppColors.primaryLight;
    }
  }

  Widget _buildNodeItem(FileNode node, int depth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasGitBadge = node.gitStatus != GitFileStatus.unmodified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            if (node.isDirectory) {
              ref.read(fileTreeNotifierProvider.notifier).toggleExpand(node.path);
            } else {
              ref.read(openTabsProvider.notifier).openFile(node.path, node.name);
              context.go('/editor');
            }
          },
          onLongPress: () {
            FileContextMenuSheet.show(
              context: context,
              node: node,
              onNewFile: () => _showNewFileDialog(parentPath: node.path, isDirectory: false),
              onNewFolder: () => _showNewFileDialog(parentPath: node.path, isDirectory: true),
              onRename: () => _showRenameDialog(node),
              onDuplicate: () => ref.read(fileTreeNotifierProvider.notifier).duplicateFile(node.path),
              onDelete: () => _showDeleteDialog(node),
            );
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 48), // min 48dp tap target!
            padding: EdgeInsets.only(
              left: 16.0 + (depth * 20.0),
              right: 16.0,
              top: 6.0,
              bottom: 6.0,
            ),
            child: Row(
              children: [
                if (node.isDirectory) ...[
                  Icon(
                    node.isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 20,
                    color: AppColors.darkTextMuted,
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  const SizedBox(width: 24),
                ],
                Icon(
                  _getFileIcon(node),
                  size: 20,
                  color: _getFileIconColor(node),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: node.isDirectory ? FontWeight.w600 : FontWeight.normal,
                      color: hasGitBadge && node.gitStatus == GitFileStatus.modified
                          ? AppColors.gitModified
                          : (hasGitBadge && node.gitStatus == GitFileStatus.added
                              ? AppColors.gitAdded
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasGitBadge) ...[
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: (node.gitStatus == GitFileStatus.modified
                              ? AppColors.gitModified
                              : AppColors.gitAdded)
                          .withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      node.gitStatus.badgeLabel ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: node.gitStatus == GitFileStatus.modified
                            ? AppColors.gitModified
                            : AppColors.gitAdded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ),
        if (node.isDirectory && node.isExpanded)
          ...node.children.map((child) => _buildNodeItem(child, depth + 1)),
      ],
    );
  }

  List<FileNode> _filterNodes(List<FileNode> nodes, String query) {
    if (query.isEmpty) return nodes;
    final List<FileNode> matched = [];
    for (final node in nodes) {
      if (node.name.toLowerCase().contains(query.toLowerCase())) {
        matched.add(node);
      } else if (node.isDirectory) {
        final filteredChildren = _filterNodes(node.children, query);
        if (filteredChildren.isNotEmpty) {
          matched.add(node.copyWith(children: filteredChildren, isExpanded: true));
        }
      }
    }
    return matched;
  }

  @override
  Widget build(BuildContext context) {
    final currentProject = ref.watch(currentProjectProvider);
    final treeState = ref.watch(fileTreeNotifierProvider);

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
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'New File',
            onPressed: () => _showNewFileDialog(isDirectory: false),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'New Folder',
            onPressed: () => _showNewFileDialog(isDirectory: true),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Tree',
            onPressed: () => ref.read(fileTreeNotifierProvider.notifier).loadTree(),
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
                hintText: 'Search files in workspace...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const Divider(height: 1),

          // File Tree
          Expanded(
            child: treeState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error loading files: $err'),
              ),
              data: (nodes) {
                final displayNodes = _filterNodes(nodes, _searchQuery);
                if (displayNodes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No files found',
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 90, top: 4),
                  children: displayNodes.map((n) => _buildNodeItem(n, 0)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
