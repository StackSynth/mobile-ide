import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SymbolToolbar extends StatelessWidget {
  final ValueChanged<String> onInsertSymbol;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onSelectLine;
  final VoidCallback onToggleComment;
  final VoidCallback onTabIndent;

  const SymbolToolbar({
    super.key,
    required this.onInsertSymbol,
    required this.onUndo,
    required this.onRedo,
    required this.onSelectLine,
    required this.onToggleComment,
    required this.onTabIndent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final keyBg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final symbols = [
      '{', '}', '[', ']', '(', ')',
      '<', '>', ';', ':', '"', "'",
      '`', '=', '=>', '/', '\\', '#', '\$',
      '&', '|', '!', '?', '+', '-', '*',
    ];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        children: [
          // Undo & Redo
          _buildActionButton(
            context: context,
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onTap: onUndo,
            keyBg: keyBg,
          ),
          const SizedBox(width: 4),
          _buildActionButton(
            context: context,
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onTap: onRedo,
            keyBg: keyBg,
          ),
          const SizedBox(width: 6),
          // Tab Key
          _buildSpecialKey(
            label: 'Tab',
            onTap: onTabIndent,
            keyBg: keyBg,
            textColor: AppColors.accentCyan,
          ),
          const SizedBox(width: 4),
          // Select Line
          _buildSpecialKey(
            label: 'Line',
            onTap: onSelectLine,
            keyBg: keyBg,
            textColor: textColor,
          ),
          const SizedBox(width: 4),
          // Comment Button
          _buildSpecialKey(
            label: '//',
            onTap: onToggleComment,
            keyBg: keyBg,
            textColor: AppColors.syntaxComment,
          ),
          const SizedBox(width: 6),
          // Divider
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            color: borderColor,
          ),
          const SizedBox(width: 4),
          // Quick Symbols
          ...symbols.map((sym) {
            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child: InkWell(
                onTap: () => onInsertSymbol(sym),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 36),
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: keyBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    sym,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color keyBg,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: keyBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required String label,
    required VoidCallback onTap,
    required Color keyBg,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: keyBg,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
