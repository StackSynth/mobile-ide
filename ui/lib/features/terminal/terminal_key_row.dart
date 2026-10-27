import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TerminalKeyRow extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onToggleHistory;
  final VoidCallback onClear;
  final bool isCtrlActive;
  final VoidCallback onToggleCtrl;

  const TerminalKeyRow({
    super.key,
    required this.onKeyPress,
    required this.onToggleHistory,
    required this.onClear,
    required this.isCtrlActive,
    required this.onToggleCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final keyBg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        children: [
          // Command History Sheet trigger
          _buildSpecialKey(
            label: 'History',
            icon: Icons.history_rounded,
            onTap: onToggleHistory,
            keyBg: keyBg,
            textColor: AppColors.accentCyan,
          ),
          const SizedBox(width: 4),

          // Ctrl modifier toggle
          InkWell(
            onTap: onToggleCtrl,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isCtrlActive ? AppColors.primary : keyBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCtrlActive ? AppColors.primaryLight : borderColor.withOpacity(0.4),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Ctrl',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCtrlActive ? Colors.white : textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Esc key
          _buildSpecialKey(
            label: 'Esc',
            onTap: () => onKeyPress('\x1b'),
            keyBg: keyBg,
            textColor: textColor,
          ),
          const SizedBox(width: 4),

          // Tab key
          _buildSpecialKey(
            label: 'Tab',
            onTap: () => onKeyPress('\t'),
            keyBg: keyBg,
            textColor: textColor,
          ),
          const SizedBox(width: 4),

          // Arrow keys
          _buildIconKey(icon: Icons.arrow_upward_rounded, onTap: () => onKeyPress('\x1b[A'), keyBg: keyBg),
          const SizedBox(width: 3),
          _buildIconKey(icon: Icons.arrow_downward_rounded, onTap: () => onKeyPress('\x1b[B'), keyBg: keyBg),
          const SizedBox(width: 3),
          _buildIconKey(icon: Icons.arrow_back_rounded, onTap: () => onKeyPress('\x1b[D'), keyBg: keyBg),
          const SizedBox(width: 3),
          _buildIconKey(icon: Icons.arrow_forward_rounded, onTap: () => onKeyPress('\x1b[C'), keyBg: keyBg),
          const SizedBox(width: 6),

          // Symbol keys: |, ~, /, -
          _buildCharKey('|', () => onKeyPress('|'), keyBg, textColor),
          const SizedBox(width: 3),
          _buildCharKey('~', () => onKeyPress('~'), keyBg, textColor),
          const SizedBox(width: 3),
          _buildCharKey('/', () => onKeyPress('/'), keyBg, textColor),
          const SizedBox(width: 3),
          _buildCharKey('-', () => onKeyPress('-'), keyBg, textColor),
          const SizedBox(width: 6),

          // Clear screen
          _buildSpecialKey(
            label: 'Clear',
            icon: Icons.cleaning_services_rounded,
            onTap: onClear,
            keyBg: keyBg,
            textColor: AppColors.darkTextMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialKey({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
    required Color keyBg,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: keyBg,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconKey({
    required IconData icon,
    required VoidCallback onTap,
    required Color keyBg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: keyBg,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCharKey(String char, VoidCallback onTap, Color keyBg, Color textColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: keyBg,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          char,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: textColor,
          ),
        ),
      ),
    );
  }
}
