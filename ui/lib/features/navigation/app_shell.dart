import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/command_palette_sheet.dart';
import '../../services/settings_service.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 720;

    // 6 primary tabs
    final navItems = const [
      NavigationDestination(
        icon: Icon(Icons.folder_outlined, size: 22, color: Colors.white),
        selectedIcon: Icon(Icons.folder_rounded, size: 22, color: Colors.white),
        label: 'Files',
      ),
      NavigationDestination(
        icon: Icon(Icons.code_rounded, size: 22, color: Colors.white),
        selectedIcon: Icon(Icons.code_rounded, size: 22, color: Colors.white),
        label: 'Editor',
      ),
      NavigationDestination(
        icon: Icon(Icons.terminal_outlined, size: 22, color: Colors.white),
        selectedIcon: Icon(Icons.terminal_rounded, size: 22, color: Colors.white),
        label: 'Terminal',
      ),
      NavigationDestination(
        icon: Icon(Icons.devices_outlined, size: 22, color: Colors.white),
        selectedIcon: Icon(Icons.devices_rounded, size: 22, color: Colors.white),
        label: 'Preview',
      ),
      NavigationDestination(
        icon: Icon(Icons.extension_outlined, size: 22, color: Colors.white),
        selectedIcon: Icon(Icons.extension_rounded, size: 22, color: Colors.white),
        label: 'Extensions',
      ),
      NavigationDestination(
        icon: Icon(Icons.auto_awesome_outlined, size: 22, color: Colors.white),
        selectedIcon: Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
        label: 'AI',
      ),
    ];

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (idx) => _onTap(context, idx),
              labelType: NavigationRailLabelType.all,
              indicatorColor: const Color(0xFF3A3A3A),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: IconButton(
                  tooltip: 'Projects',
                  icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
                  onPressed: () => context.push('/projects'),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_outlined, color: Colors.white),
                      onPressed: () => context.push('/settings'),
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined, color: Colors.white),
                  selectedIcon: Icon(Icons.folder_rounded, color: Colors.white),
                  label: Text('Files', style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.code_rounded, color: Colors.white),
                  selectedIcon: Icon(Icons.code_rounded, color: Colors.white),
                  label: Text('Editor', style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.terminal_outlined, color: Colors.white),
                  selectedIcon: Icon(Icons.terminal_rounded, color: Colors.white),
                  label: Text('Terminal', style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.devices_outlined, color: Colors.white),
                  selectedIcon: Icon(Icons.devices_rounded, color: Colors.white),
                  label: Text('Preview', style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.extension_outlined, color: Colors.white),
                  selectedIcon: Icon(Icons.extension_rounded, color: Colors.white),
                  label: Text('Extensions', style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_outlined, color: Colors.white),
                  selectedIcon: Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  label: Text('AI', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Stack(
                children: [
                  navigationShell,
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton.extended(
                      heroTag: 'command_palette_tablet',
                      onPressed: () => CommandPaletteSheet.show(context),
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: const Text('Palette'),
                      backgroundColor: const Color(0xFF3A3A3A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,

          // Optional Floating Command Palette Button (when configured as floating)
          if (settings.cmdButtonPosition == 'floating')
            Positioned(
              right: 16,
              bottom: 12,
              child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3A3A3A).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => CommandPaletteSheet.show(context),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Cmd',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (idx) => _onTap(context, idx),
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 60,
            indicatorColor: const Color(0xFF3A3A3A),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              return const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              );
            }),
            destinations: navItems,
          ),
        ),
      ),
    );
  }
}
