import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

/// A placeholder Extensions screen for browsing and managing IDE extensions.
class ExtensionsScreen extends ConsumerStatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  ConsumerState<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends ConsumerState<ExtensionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample extension data
  static const _sampleExtensions = [
    _ExtensionInfo(
      name: 'Dart',
      publisher: 'Dart Team',
      description: 'Dart language support and debugger.',
      icon: Icons.flutter_dash_rounded,
      iconColor: AppColors.accentCyan,
      installed: true,
    ),
    _ExtensionInfo(
      name: 'Flutter',
      publisher: 'Flutter Team',
      description: 'Flutter support with hot-reload, widget inspector, and more.',
      icon: Icons.phone_android_rounded,
      iconColor: AppColors.accentCyan,
      installed: true,
    ),
    _ExtensionInfo(
      name: 'Python',
      publisher: 'Microsoft',
      description: 'Rich Python language support with IntelliSense, linting, and debugging.',
      icon: Icons.code_rounded,
      iconColor: Color(0xFF3776AB),
      installed: false,
    ),
    _ExtensionInfo(
      name: 'ESLint',
      publisher: 'dbaeumer',
      description: 'Integrates ESLint JavaScript linting into your editor.',
      icon: Icons.rule_rounded,
      iconColor: Color(0xFF8080F2),
      installed: false,
    ),
    _ExtensionInfo(
      name: 'Prettier',
      publisher: 'Prettier',
      description: 'Opinionated code formatter with support for many languages.',
      icon: Icons.format_paint_rounded,
      iconColor: Color(0xFFF7B93E),
      installed: false,
    ),
    _ExtensionInfo(
      name: 'GitLens',
      publisher: 'GitKraken',
      description: 'Supercharge Git within your editor. Visualize blame, history, and more.',
      icon: Icons.timeline_rounded,
      iconColor: AppColors.accentTeal,
      installed: false,
    ),
    _ExtensionInfo(
      name: 'Docker',
      publisher: 'Microsoft',
      description: 'Build, manage, and deploy containerized applications.',
      icon: Icons.directions_boat_rounded,
      iconColor: Color(0xFF2496ED),
      installed: false,
    ),
    _ExtensionInfo(
      name: 'Tailwind CSS',
      publisher: 'Tailwind Labs',
      description: 'Tailwind CSS IntelliSense with autocomplete, syntax highlighting, and linting.',
      icon: Icons.style_rounded,
      iconColor: Color(0xFF38BDF8),
      installed: false,
    ),
  ];

  List<_ExtensionInfo> get _filteredExtensions {
    if (_searchQuery.isEmpty) return _sampleExtensions;
    return _sampleExtensions
        .where((e) =>
            e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.publisher.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final extensions = _filteredExtensions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extensions'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search extensions...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildChip('All', true, isDark),
                const SizedBox(width: 8),
                _buildChip('Installed', false, isDark),
                const SizedBox(width: 8),
                _buildChip('Popular', false, isDark),
                const SizedBox(width: 8),
                _buildChip('Languages', false, isDark),
                const SizedBox(width: 8),
                _buildChip('Themes', false, isDark),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Extensions list
          Expanded(
            child: extensions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.extension_off_rounded,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No extensions found',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: extensions.length,
                    separatorBuilder: (_, _a) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ext = extensions[index];
                      return _buildExtensionCard(ext, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected, bool isDark) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected
              ? Colors.white
              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      ),
      selected: selected,
      onSelected: (_) {},
      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
      selectedColor: const Color(0xFF3A3A3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? const Color(0xFF5A5A5A) : const Color(0xFF3A3A3A),
        ),
      ),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildExtensionCard(_ExtensionInfo ext, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ext.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ext.icon, size: 22, color: ext.iconColor),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ext.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ext.publisher,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  ext.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Action button
          ext.installed
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: const Color(0xFF5A5A5A), width: 1),
                  ),
                  child: const Text(
                    'Installed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                )
              : SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A3A3A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                    child: const Text('Install',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ExtensionInfo {
  final String name;
  final String publisher;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool installed;

  const _ExtensionInfo({
    required this.name,
    required this.publisher,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.installed,
  });
}
