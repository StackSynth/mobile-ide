import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Account Section
          _buildSectionHeader('Account & Cloud Profile'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Text('AM', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(settings.accountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(settings.accountEmail, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'GitHub Pro Connected',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cloud Container Resources Usage
          _buildSectionHeader('Cloud Container Quotas'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildResourceBar(
                  label: 'Compute Hours',
                  current: settings.cloudHoursUsed,
                  max: settings.cloudHoursLimit,
                  unit: 'hrs',
                  color: AppColors.accentCyan,
                ),
                const SizedBox(height: 14),
                _buildResourceBar(
                  label: 'Active RAM',
                  current: settings.ramUsedGb,
                  max: settings.ramLimitGb,
                  unit: 'GB',
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 14),
                _buildResourceBar(
                  label: 'NVMe Storage',
                  current: settings.diskUsedGb,
                  max: settings.diskLimitGb,
                  unit: 'GB',
                  color: AppColors.accentTeal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Editor & Appearance Section
          _buildSectionHeader('Editor & Appearance'),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                // Theme Mode
                ListTile(
                  leading: const Icon(Icons.palette_outlined, size: 20, color: AppColors.primaryLight),
                  title: const Text('Theme Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox.shrink(),
                    onChanged: (mode) {
                      if (mode != null) ref.read(settingsProvider.notifier).setThemeMode(mode);
                    },
                    items: const [
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark (Default)')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Font Size
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Editor Font Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${settings.fontSize.toInt()} px', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentCyan)),
                        ],
                      ),
                      Slider(
                        value: settings.fontSize,
                        min: 11,
                        max: 22,
                        divisions: 11,
                        activeColor: AppColors.accentCyan,
                        onChanged: (val) => ref.read(settingsProvider.notifier).setFontSize(val),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Font Family
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded, size: 20, color: AppColors.primaryLight),
                  title: const Text('Font Family', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<String>(
                    value: settings.fontFamily,
                    underline: const SizedBox.shrink(),
                    onChanged: (font) {
                      if (font != null) ref.read(settingsProvider.notifier).setFontFamily(font);
                    },
                    items: const [
                      DropdownMenuItem(value: 'JetBrains Mono', child: Text('JetBrains Mono')),
                      DropdownMenuItem(value: 'Fira Code', child: Text('Fira Code')),
                      DropdownMenuItem(value: 'Source Code Pro', child: Text('Source Code Pro')),
                      DropdownMenuItem(value: 'Courier', child: Text('System Monospace')),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Keybar Layout
                ListTile(
                  leading: const Icon(Icons.keyboard_outlined, size: 20, color: AppColors.primaryLight),
                  title: const Text('Keybar Layout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<String>(
                    value: settings.keybarLayout,
                    underline: const SizedBox.shrink(),
                    onChanged: (layout) {
                      if (layout != null) ref.read(settingsProvider.notifier).setKeybarLayout(layout);
                    },
                    items: const [
                      DropdownMenuItem(value: 'Default Developer', child: Text('Developer')),
                      DropdownMenuItem(value: 'Compact Minimal', child: Text('Compact')),
                      DropdownMenuItem(value: 'Extended Web', child: Text('Web & JSX')),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Command Palette Position setting
                ListTile(
                  leading: const Icon(Icons.search_rounded, size: 20, color: AppColors.accentCyan),
                  title: const Text('Cmd Palette Button', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Position or hide the Cmd button', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                  trailing: DropdownButton<String>(
                    value: settings.cmdButtonPosition,
                    underline: const SizedBox.shrink(),
                    onChanged: (pos) {
                      if (pos != null) ref.read(settingsProvider.notifier).setCmdButtonPosition(pos);
                    },
                    items: const [
                      DropdownMenuItem(value: 'top', child: Text('Top Bar (Up)')),
                      DropdownMenuItem(value: 'floating', child: Text('Floating Bottom')),
                      DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // AI Model Configuration
          _buildSectionHeader('AI Model Selection'),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: ListTile(
              leading: const Icon(Icons.psychology_outlined, size: 22, color: AppColors.accentCyan),
              title: const Text('Model Architecture', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(settings.aiModel, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
              trailing: DropdownButton<String>(
                value: settings.aiModel,
                underline: const SizedBox.shrink(),
                onChanged: (model) {
                  if (model != null) ref.read(settingsProvider.notifier).setAiModel(model);
                },
                items: const [
                  DropdownMenuItem(value: 'Claude 3.7 Sonnet', child: Text('Claude 3.7 Sonnet')),
                  DropdownMenuItem(value: 'GPT-4.5', child: Text('GPT-4.5')),
                  DropdownMenuItem(value: 'Gemini 2.5 Flash', child: Text('Gemini 2.5 Flash')),
                  DropdownMenuItem(value: 'DeepSeek Coder', child: Text('DeepSeek Coder')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildResourceBar({
    required String label,
    required double current,
    required double max,
    required String unit,
    required Color color,
  }) {
    final percent = (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(
              '$current / $max $unit (${(percent * 100).toInt()}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
