import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommandHistorySheet extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onSelectCommand;

  const CommandHistorySheet({
    super.key,
    required this.history,
    required this.onSelectCommand,
  });

  static Future<void> show({
    required BuildContext context,
    required List<String> history,
    required ValueChanged<String> onSelectCommand,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommandHistorySheet(
        history: history,
        onSelectCommand: onSelectCommand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderHighlight : AppColors.lightBorderHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, size: 20, color: AppColors.accentCyan),
                    SizedBox(width: 8),
                    Text(
                      'Command History',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  '${history.length} commands',
                  style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'No past commands in this session',
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cmd = history[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.terminal_rounded, size: 18, color: AppColors.primaryLight),
                        title: Text(
                          cmd,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.darkTextMuted),
                        onTap: () {
                          Navigator.pop(context);
                          onSelectCommand(cmd);
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
