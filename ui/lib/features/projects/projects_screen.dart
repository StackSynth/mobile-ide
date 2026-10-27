import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import 'new_project_sheet.dart';
import 'clone_repo_sheet.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  IconData _getStackIcon(String stack) {
    if (stack.contains('react') || stack.contains('vite')) return Icons.bolt_rounded;
    if (stack.contains('next')) return Icons.layers_rounded;
    if (stack.contains('python')) return Icons.data_object_rounded;
    if (stack.contains('flutter')) return Icons.flutter_dash_rounded;
    return Icons.folder_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsState = ref.watch(projectsNotifierProvider);
    final currentProject = ref.watch(currentProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.code_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'StackSynth',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Cloud IDE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsNotifierProvider.notifier).loadProjects(),
        child: projectsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text('Failed to load workspaces: $err'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.read(projectsNotifierProvider.notifier).loadProjects(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (projects) {
            if (projects.isEmpty) {
              return EmptyStateView(
                icon: Icons.folder_open_rounded,
                title: 'No Cloud Workspaces',
                description: 'Launch your first isolated cloud dev container to start writing and shipping code.',
                actionLabel: 'New Project',
                onAction: () => NewProjectSheet.show(context),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                // Top quick action buttons (Thumb-friendly row)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => NewProjectSheet.show(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => CloneRepoSheet.show(context),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Clone Repo', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Recent Workspaces header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Projects',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '${projects.length} containers',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cards
                ...projects.map((project) {
                  final isCurrent = currentProject?.id == project.id;
                  final isSleeping = project.status == ProjectStatus.sleeping;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        ref.read(currentProjectProvider.notifier).state = project;
                        if (isSleeping) {
                          ref.read(projectsNotifierProvider.notifier).wakeProject(project.id);
                        }
                        context.go('/editor');
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getStackIcon(project.stack),
                                    color: AppColors.primaryLight,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              project.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'ACTIVE',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primaryLight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        project.stackLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.darkTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusChip(status: project.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              project.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.darkTextMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Opened ${_formatTimeAgo(project.lastOpened)}',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.darkTextMuted),
                                    ),
                                  ],
                                ),
                                if (isSleeping)
                                  TextButton.icon(
                                    onPressed: () {
                                      ref.read(projectsNotifierProvider.notifier).wakeProject(project.id);
                                    },
                                    icon: const Icon(Icons.power_settings_new_rounded, size: 14),
                                    label: const Text('Wake', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      foregroundColor: AppColors.warning,
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      Text(
                                        'Port ${project.port}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accentCyan,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.darkTextMuted),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
