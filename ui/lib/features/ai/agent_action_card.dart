import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ai_message.dart';

class AgentActionCard extends StatelessWidget {
  final AgentAction action;
  final VoidCallback? onViewDiff;

  const AgentActionCard({
    super.key,
    required this.action,
    this.onViewDiff,
  });

  IconData _getIcon() {
    switch (action.type) {
      case AgentActionType.fileEdit:
        return Icons.edit_document;
      case AgentActionType.fileCreate:
        return Icons.note_add_rounded;
      case AgentActionType.fileDelete:
        return Icons.delete_outline_rounded;
      case AgentActionType.terminalCommand:
        return Icons.terminal_rounded;
      case AgentActionType.previewReload:
        return Icons.refresh_rounded;
    }
  }

  Color _getIconColor() {
    switch (action.type) {
      case AgentActionType.fileEdit:
        return AppColors.accentCyan;
      case AgentActionType.fileCreate:
        return AppColors.success;
      case AgentActionType.fileDelete:
        return AppColors.error;
      case AgentActionType.terminalCommand:
        return AppColors.primaryLight;
      case AgentActionType.previewReload:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconColor = _getIconColor();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(), size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                Text(
                  action.subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),
          if (action.diffId != null && onViewDiff != null)
            TextButton(
              onPressed: onViewDiff,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: AppColors.primary.withOpacity(0.15),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Review Diff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primaryLight),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
