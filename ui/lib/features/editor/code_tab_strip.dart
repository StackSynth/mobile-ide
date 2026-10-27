import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/file_service.dart';

class CodeTabStrip extends ConsumerWidget {
  const CodeTabStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openTabsState = ref.watch(openTabsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (openTabsState.tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: openTabsState.tabs.length,
        itemBuilder: (context, index) {
          final tab = openTabsState.tabs[index];
          final isActive = index == openTabsState.activeIndex;

          return InkWell(
            onTap: () {
              ref.read(openTabsProvider.notifier).setActiveTab(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? AppColors.darkBg : Colors.white)
                    : Colors.transparent,
                border: Border(
                  right: BorderSide(color: borderColor, width: 1),
                  top: BorderSide(
                    color: isActive ? AppColors.accentCyan : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.name.endsWith('.tsx') || tab.name.endsWith('.ts')
                        ? Icons.code_rounded
                        : (tab.name.endsWith('.css')
                            ? Icons.style_rounded
                            : Icons.insert_drive_file_outlined),
                    size: 14,
                    color: isActive ? AppColors.accentCyan : AppColors.darkTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : AppColors.darkTextMuted,
                    ),
                  ),
                  if (tab.isDirty) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      ref.read(openTabsProvider.notifier).closeTab(index);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.close_rounded, size: 14, color: AppColors.darkTextMuted),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
