import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/project_service.dart';

class NewProjectSheet extends ConsumerStatefulWidget {
  const NewProjectSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NewProjectSheet(),
    );
  }

  @override
  ConsumerState<NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends ConsumerState<NewProjectSheet> {
  final TextEditingController _nameController = TextEditingController(text: 'my-project');
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);
    final proj = await ref
        .read(projectsNotifierProvider.notifier)
        .createProject(name, 'custom');
    if (mounted) {
      setState(() => _isCreating = false);
      if (proj != null) {
        ref.read(currentProjectProvider.notifier).state = proj;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${proj.name}! Open Terminal to configure environment.'),
            backgroundColor: const Color(0xFF1F2937),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    // Dark gray outline border color
    final darkGrayBorder = isDark ? const Color(0xFF374151) : const Color(0xFF4B5563);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: darkGrayBorder),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: darkGrayBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Project',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Spin up an isolated container workspace',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Divider(color: darkGrayBorder, height: 1),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Name',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.folder_open_rounded, size: 20, color: AppColors.accentCyan),
                      hintText: 'e.g. mobile-project',
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: darkGrayBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: darkGrayBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: darkGrayBorder, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Environment Setup',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Box with dark gray outline explaining terminal setup
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: darkGrayBorder, width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: darkGrayBorder),
                          ),
                          child: const Icon(Icons.terminal_rounded, color: AppColors.accentCyan, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Terminal-Driven Workspace',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'No predefined framework lock-in. Use the integrated Terminal to set up your environment with any tools you need (Node, Python, Flutter, Rust, etc.).',
                                style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border(top: BorderSide(color: darkGrayBorder)),
              ),
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                  label: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Create Workspace & Open',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B), // sleek dark container tone
                    side: BorderSide(color: darkGrayBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isCreating ? null : _handleCreate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
