import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/file_node.dart';

class FileCreationDialog extends StatefulWidget {
  final String parentPath;
  final bool isFolder;
  final FileNode rootNode;
  final Future<void> Function(String name) onSubmit;

  const FileCreationDialog({
    super.key,
    required this.parentPath,
    required this.isFolder,
    required this.rootNode,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String parentPath,
    required bool isFolder,
    required FileNode rootNode,
    required Future<void> Function(String name) onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => FileCreationDialog(
        parentPath: parentPath,
        isFolder: isFolder,
        rootNode: rootNode,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<FileCreationDialog> createState() => _FileCreationDialogState();
}

class _FileCreationDialogState extends State<FileCreationDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    _controller.removeListener(_validate);
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty');
      return;
    }
    if (text.length > 255) {
      setState(() => _errorMessage = 'Name cannot exceed 255 characters');
      return;
    }

    const invalidChars = r'\:*?"<>|';
    for (int i = 0; i < text.length; i++) {
      if (invalidChars.contains(text[i])) {
        setState(() => _errorMessage = 'Name contains invalid character: "${text[i]}"');
        return;
      }
    }

    final segments = text.split('/');
    for (final seg in segments) {
      final trimmed = seg.trim();
      if (trimmed.isEmpty) {
        setState(() => _errorMessage = 'Path segment cannot be empty');
        return;
      }
      if (trimmed == '.' || trimmed == '..') {
        setState(() => _errorMessage = 'Invalid segment name: "$trimmed"');
        return;
      }
    }

    // Check duplicate in direct target folder if not creating nested subfolders
    if (!text.contains('/')) {
      final parentNode = widget.rootNode.findByPath(widget.parentPath);
      if (parentNode != null) {
        final duplicate = parentNode.children.any(
          (c) => c.name.toLowerCase() == text.toLowerCase(),
        );
        if (duplicate) {
          setState(() => _errorMessage = 'An item named "$text" already exists in this folder');
          return;
        }
      }
    }

    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleConfirm() async {
    _validate();
    if (_errorMessage != null || _controller.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(_controller.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('FileSystemException: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceElevated = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Icon(
            widget.isFolder ? Icons.create_new_folder_rounded : Icons.note_add_rounded,
            color: widget.isFolder ? AppColors.accentCyan : AppColors.primaryLight,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(widget.isFolder ? 'New Folder' : 'New File'),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.accentCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Target: ${widget.parentPath == '/' ? '/' : '${widget.parentPath}/'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentCyan,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              onSubmitted: (_) => _handleConfirm(),
              decoration: InputDecoration(
                hintText: widget.isFolder ? 'e.g. components or ui/widgets' : 'e.g. Button.jsx or utils/math.ts',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.darkTextMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 6),
            const Text(
              'Supports nested paths like "components/ui/Button.jsx"',
              style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_errorMessage == null && _controller.text.trim().isNotEmpty && !_isSubmitting)
              ? _handleConfirm
              : null,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}
