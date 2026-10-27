import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/project_service.dart';

class ProjectTemplate {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const ProjectTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

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
  final TextEditingController _nameController = TextEditingController(text: 'my-mobile-app');
  String _selectedTemplate = 'React + Vite';
  bool _isCreating = false;

  final List<ProjectTemplate> _templates = const [
    ProjectTemplate(
      id: 'React + Vite',
      title: 'React + Vite',
      description: 'Lightning fast React 19 SPA with Tailwind CSS & hot module reload',
      icon: Icons.flash_on_rounded,
      color: Color(0xFF38BDF8),
    ),
    ProjectTemplate(
      id: 'Next.js',
      title: 'Next.js 15',
      description: 'Fullstack App Router, React Server Components & API routes',
      icon: Icons.layers_rounded,
      color: Color(0xFFF8FAFC),
    ),
    ProjectTemplate(
      id: 'Node API',
      title: 'Node.js API',
      description: 'Lightweight Express / Hono TypeScript backend with container sandbox',
      icon: Icons.code_rounded,
      color: Color(0xFF10B981),
    ),
    ProjectTemplate(
      id: 'Python',
      title: 'Python FastAPI',
      description: 'Modern asynchronous Python REST API with auto OpenAPI docs',
      icon: Icons.terminal_rounded,
      color: Color(0xFFF59E0B),
    ),
    ProjectTemplate(
      id: 'Flutter web',
      title: 'Flutter Web',
      description: 'Cross-platform canvas kit web application with Riverpod',
      icon: Icons.flutter_dash_rounded,
      color: Color(0xFF6366F1),
    ),
    ProjectTemplate(
      id: 'Blank',
      title: 'Blank Workspace',
      description: 'Minimal Alpine Linux container with git, bash, node and python',
      icon: Icons.crop_square_rounded,
      color: Color(0xFF94A3B8),
    ),
  ];

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
        .createProject(name, _selectedTemplate);
    if (mounted) {
      setState(() => _isCreating = false);
      if (proj != null) {
        ref.read(currentProjectProvider.notifier).state = proj;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${proj.name}! Starting container...'),
            backgroundColor: AppColors.primary,
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
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderHighlight : AppColors.lightBorderHighlight,
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
                    Text(
                      'Spin up an isolated cloud container',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

          const SizedBox(height: 12),
          const Divider(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Project Name',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.folder_open_rounded, size: 20),
                    hintText: 'e.g. mobile-storefront',
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Select Starter Template',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 10),

                ..._templates.map((tpl) {
                  final isSelected = _selectedTemplate == tpl.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedTemplate = tpl.id);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : (isDark ? AppColors.darkCard : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tpl.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(tpl.icon, color: tpl.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tpl.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tpl.description,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.darkTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: tpl.id,
                              groupValue: _selectedTemplate,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedTemplate = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: ElevatedButton(
              onPressed: _isCreating ? null : _handleCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Launch Container & Open',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
