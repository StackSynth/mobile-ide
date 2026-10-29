import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'models/file_node.dart';

class FileContextMenuSheet extends StatelessWidget {
  final FileNode node;
  final VoidCallback? onNewFile;
  final VoidCallback? onNewFolder;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onCopyPath;

  const FileContextMenuSheet({
    super.key,
    required this.node,
    this.onNewFile,
    this.onNewFolder,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
    required this.onMove,
    required this.onCopyPath,
  });

  static Future<void> show({
    required BuildContext context,
    required FileNode node,
    VoidCallback? onNewFile,
    VoidCallback? onNewFolder,
    required VoidCallback onRename,
    required VoidCallback onDuplicate,
    required VoidCallback onDelete,
    required VoidCallback onMove,
    required VoidCallback onCopyPath,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FileContextMenuSheet(
        node: node,
        onNewFile: onNewFile,
        onNewFolder: onNewFolder,
        onRename: onRename,
        onDuplicate: onDuplicate,
        onDelete: onDelete,
        onMove: onMove,
        onCopyPath: onCopyPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final isDir = node.isFolder;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isDir ? Icons.folder_rounded : Icons.insert_drive_file_outlined,
                    size: 22,
                    color: isDir ? AppColors.accentCyan : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          node.path,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkTextMuted,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isDir) ...[
              Semantics(
                label: 'Create new file inside ${node.name}',
                button: true,
                child: ListTile(
                  leading: const Icon(Icons.note_add_outlined, size: 22),
                  title: const Text('New File', style: TextStyle(fontSize: 14)),
                  minVerticalPadding: 14,
                  onTap: () {
                    Navigator.pop(context);
                    onNewFile?.call();
                  },
                ),
              ),
              Semantics(
                label: 'Create new folder inside ${node.name}',
                button: true,
                child: ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined, size: 22),
                  title: const Text('New Folder', style: TextStyle(fontSize: 14)),
                  minVerticalPadding: 14,
                  onTap: () {
                    Navigator.pop(context);
                    onNewFolder?.call();
                  },
                ),
              ),
            ],
            Semantics(
              label: 'Rename ${node.name}',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.edit_outlined, size: 22),
                title: const Text('Rename', style: TextStyle(fontSize: 14)),
                minVerticalPadding: 14,
                onTap: () {
                  Navigator.pop(context);
                  onRename();
                },
              ),
            ),
            Semantics(
              label: 'Duplicate ${node.name}',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.copy_outlined, size: 22),
                title: Text(isDir ? 'Duplicate Folder' : 'Duplicate', style: const TextStyle(fontSize: 14)),
                minVerticalPadding: 14,
                onTap: () {
                  Navigator.pop(context);
                  onDuplicate();
                },
              ),
            ),
            Semantics(
              label: 'Move ${node.name} to another folder',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.drive_file_move_outlined, size: 22),
                title: const Text('Move...', style: TextStyle(fontSize: 14)),
                minVerticalPadding: 14,
                onTap: () {
                  Navigator.pop(context);
                  onMove();
                },
              ),
            ),
            Semantics(
              label: 'Copy path of ${node.name}',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.link_rounded, size: 22),
                title: const Text('Copy Path', style: TextStyle(fontSize: 14)),
                minVerticalPadding: 14,
                onTap: () {
                  Navigator.pop(context);
                  onCopyPath();
                },
              ),
            ),
            Semantics(
              label: 'Delete ${node.name}',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.delete_outline_rounded, size: 22, color: AppColors.error),
                title: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 14, color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                minVerticalPadding: 14,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
