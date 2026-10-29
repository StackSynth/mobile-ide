import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/file_node.dart';

class FolderPickerSheet extends StatefulWidget {
  final FileNode rootNode;
  final String sourcePath;
  final ValueChanged<String> onFolderSelected;

  const FolderPickerSheet({
    super.key,
    required this.rootNode,
    required this.sourcePath,
    required this.onFolderSelected,
  });

  static Future<String?> show({
    required BuildContext context,
    required FileNode rootNode,
    required String sourcePath,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FolderPickerSheet(
        rootNode: rootNode,
        sourcePath: sourcePath,
        onFolderSelected: (path) => Navigator.of(ctx).pop(path),
      ),
    );
  }

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  String _selectedPath = '/';
  final Set<String> _expanded = {'/'};

  @override
  void initState() {
    super.initState();
    _expandAllFolders(widget.rootNode);
  }

  void _expandAllFolders(FileNode node) {
    if (node.isFolder) {
      _expanded.add(node.path);
      for (final child in node.children) {
        _expandAllFolders(child);
      }
    }
  }

  bool _isInvalidTarget(String folderPath) {
    // Cannot move into itself or a subfolder of itself
    if (folderPath == widget.sourcePath) return true;
    if (folderPath.startsWith('${widget.sourcePath}/')) return true;
    return false;
  }

  Widget _buildFolderRow(FileNode node, int depth) {
    if (!node.isFolder) return const SizedBox.shrink();

    final isSelected = _selectedPath == node.path;
    final isExpanded = _expanded.contains(node.path);
    final isDisabled = _isInvalidTarget(node.path);
    final isRoot = node.path == '/';
    final hasFolderChildren = node.children.any((c) => c.isFolder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedPath = node.path;
                  });
                },
          child: Container(
            height: 48,
            padding: EdgeInsets.only(left: 16.0 + depth * 20.0, right: 16.0),
            color: isSelected ? AppColors.primaryLight.withOpacity(0.15) : Colors.transparent,
            child: Row(
              children: [
                if (hasFolderChildren)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expanded.remove(node.path);
                        } else {
                          _expanded.add(node.path);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                        size: 18,
                        color: isDisabled ? AppColors.darkTextMuted : AppColors.accentCyan,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 34),
                Icon(
                  isRoot ? Icons.home_repair_service_rounded : Icons.folder_rounded,
                  size: 20,
                  color: isDisabled
                      ? AppColors.darkTextMuted
                      : (isSelected ? AppColors.primaryLight : AppColors.accentCyan),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isRoot ? 'Workspace Root (/)' : node.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isDisabled ? AppColors.darkTextMuted : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primaryLight),
              ],
            ),
          ),
        ),
        if (isExpanded)
          for (final child in node.children)
            if (child.isFolder) _buildFolderRow(child, depth + 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderHighlight : AppColors.lightBorderHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.drive_file_move_rounded, color: AppColors.accentCyan, size: 22),
                  const SizedBox(width: 10),
                  const Text('Move to Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  _buildFolderRow(widget.rootNode, 0),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  icon: const Icon(Icons.drive_file_move_rounded, size: 18),
                  label: Text('Move Here (${_selectedPath == '/' ? '/' : _selectedPath})'),
                  onPressed: () => widget.onFolderSelected(_selectedPath),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
