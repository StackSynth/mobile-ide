import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/preview_state.dart';

class ConsoleDrawer extends StatelessWidget {
  final List<ConsoleLogEntry> logs;
  final VoidCallback onClose;
  final VoidCallback onClear;

  const ConsoleDrawer({
    super.key,
    required this.logs,
    required this.onClose,
    required this.onClear,
  });

  Color _getLevelColor(ConsoleLogLevel level) {
    switch (level) {
      case ConsoleLogLevel.error:
        return AppColors.error;
      case ConsoleLogLevel.warn:
        return AppColors.warning;
      case ConsoleLogLevel.info:
        return AppColors.accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dvr_rounded, size: 16, color: AppColors.accentCyan),
                    const SizedBox(width: 6),
                    const Text(
                      'DevTools Console',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${logs.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentCyan,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      tooltip: 'Clear Console',
                      onPressed: onClear,
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                      tooltip: 'Collapse Console',
                      onPressed: onClose,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No console output or errors',
                      style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = logs[index];
                      final color = _getLevelColor(entry.level);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.level.label,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.message,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  if (entry.stackTrace != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      entry.stackTrace!,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        color: AppColors.darkTextMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              '${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.darkTextMuted,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
