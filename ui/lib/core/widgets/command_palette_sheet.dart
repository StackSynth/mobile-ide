import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../services/settings_service.dart';
import '../../services/file_service.dart';

class CommandPaletteItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String category;
  final VoidCallback onSelect;

  const CommandPaletteItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.onSelect,
  });
}

class CommandPaletteSheet extends ConsumerStatefulWidget {
  const CommandPaletteSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CommandPaletteSheet(),
    );
  }

  @override
  ConsumerState<CommandPaletteSheet> createState() => _CommandPaletteSheetState();
}

class _CommandPaletteSheetState extends ConsumerState<CommandPaletteSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final allCommands = <CommandPaletteItem>[
      CommandPaletteItem(
        icon: Icons.code_rounded,
        title: 'Open src/App.tsx',
        subtitle: 'Go to React main application component',
        category: 'Files',
        onSelect: () {
          ref.read(openTabsProvider.notifier).openFile('src/App.tsx', 'App.tsx');
          context.go('/editor');
        },
      ),
      CommandPaletteItem(
        icon: Icons.integration_instructions_rounded,
        title: 'Open src/components/Header.tsx',
        subtitle: 'Go to Header navigation component',
        category: 'Files',
        onSelect: () {
          ref.read(openTabsProvider.notifier).openFile('src/components/Header.tsx', 'Header.tsx');
          context.go('/editor');
        },
      ),
      CommandPaletteItem(
        icon: Icons.play_arrow_rounded,
        title: 'Run "pnpm dev"',
        subtitle: 'Start Vite development server in terminal',
        category: 'Scripts',
        onSelect: () {
          context.go('/terminal');
        },
      ),
      CommandPaletteItem(
        icon: Icons.terminal_rounded,
        title: 'Run "git status"',
        subtitle: 'Check modified and untracked files',
        category: 'Scripts',
        onSelect: () {
          context.go('/terminal');
        },
      ),
      CommandPaletteItem(
        icon: Icons.note_add_outlined,
        title: 'New File',
        subtitle: 'Create a new file in workspace',
        category: 'Files',
        onSelect: () {
          context.go('/files');
        },
      ),
      CommandPaletteItem(
        icon: Icons.dashboard_outlined,
        title: 'Switch Project',
        subtitle: 'View recent workspaces or create new',
        category: 'Projects',
        onSelect: () {
          context.go('/projects');
        },
      ),
      CommandPaletteItem(
        icon: Icons.auto_awesome_rounded,
        title: 'Ask AI Assistant',
        subtitle: 'Chat or review pending file diffs',
        category: 'AI',
        onSelect: () {
          context.go('/ai');
        },
      ),
      CommandPaletteItem(
        icon: Icons.brightness_4_rounded,
        title: 'Toggle Theme',
        subtitle: 'Switch between dark and light appearance',
        category: 'Preferences',
        onSelect: () {
          ref.read(settingsProvider.notifier).toggleTheme();
        },
      ),
      CommandPaletteItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'Configure fonts, keybars, AI models, account',
        category: 'Preferences',
        onSelect: () {
          context.go('/settings');
        },
      ),
    ];

    final filtered = _query.isEmpty
        ? allCommands
        : allCommands.where((item) {
            final q = _query.toLowerCase();
            return item.title.toLowerCase().contains(q) ||
                item.subtitle.toLowerCase().contains(q) ||
                item.category.toLowerCase().contains(q);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderHighlight : AppColors.lightBorderHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                hintText: 'Type a command, file name, or action...',
                isDense: true,
              ),
            ),
          ),

          const Divider(),

          // Command list
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching commands found',
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return ListTile(
                        dense: true,
                        minLeadingWidth: 28,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, size: 18, color: AppColors.primaryLight),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        subtitle: Text(
                          item.subtitle,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.lightSurfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          item.onSelect();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
