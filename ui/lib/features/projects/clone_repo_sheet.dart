import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/project_service.dart';

class CloneRepoSheet extends ConsumerStatefulWidget {
  const CloneRepoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CloneRepoSheet(),
    );
  }

  @override
  ConsumerState<CloneRepoSheet> createState() => _CloneRepoSheetState();
}

class _CloneRepoSheetState extends ConsumerState<CloneRepoSheet> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://github.com/facebook/react.git',
  );
  bool _isCloning = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleClone() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isCloning = true);
    final proj = await ref.read(projectsNotifierProvider.notifier).cloneRepo(url);
    if (mounted) {
      setState(() => _isCloning = false);
      if (proj != null) {
        ref.read(currentProjectProvider.notifier).state = proj;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cloned ${proj.name}! Workspace ready.'),
            backgroundColor: const Color(0xFF3A3A3A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderHighlight : AppColors.lightBorderHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.download_rounded, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clone from GitHub',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Text(
                    'Import any public or private repository',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Repository HTTPS or SSH URL',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.link_rounded, size: 20),
              hintText: 'https://github.com/owner/repository.git',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isCloning ? null : _handleClone,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A3A3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCloning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Clone & Open Workspace',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}
