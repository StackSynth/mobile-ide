import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/file_node.dart';

class FileContextMenuSheet extends StatelessWidget {
  final FileNode node;
  final VoidCallback onNewFile;
  final VoidCallback onNewFolder;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const FileContextMenuSheet({
    super.key,
    required this.node,
    required this.onNewFile,
    required this.onNewFolder,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required FileNode node,
    required VoidCallback onNewFile,
    required VoidCallback onNewFolder,
    required VoidCallback onRename,
    required VoidCallback onDuplicate,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FileContextMenuSheet(
        node: node,
        onNewFile: onNewFile,
        onNewFolder: onNewFolder,
        onRename: onRename,
        onDuplicate: onDuplicate,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final isDir = node.isDirectory;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                Icon(
                  isDir ? Icons.folder_rounded : Icons.insert_drive_file_outlined,
                  size: 20,
                  color: isDir ? AppColors.accentCyan : AppColors.primaryLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    node.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          if (isDir) ...[
            ListTile(
              leading: const Icon(Icons.note_add_outlined, size: 20),
              title: const Text('New File in Folder', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                onNewFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined, size: 20),
              title: const Text('New Folder in Folder', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                onNewFolder();
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.edit_outlined, size: 20),
            title: const Text('Rename', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              onRename();
            },
          ),
          if (!isDir)
            ListTile(
              leading: const Icon(Icons.copy_outlined, size: 20),
              title: const Text('Duplicate File', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                onDuplicate();
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
            title: const Text(
              'Delete',
              style: TextStyle(fontSize: 14, color: AppColors.error, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
