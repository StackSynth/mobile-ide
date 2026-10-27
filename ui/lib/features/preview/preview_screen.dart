import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/preview_state.dart';
import '../../services/preview_service.dart';
import 'console_drawer.dart';
import 'interactive_preview_canvas.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(previewStateNotifierProvider).currentUrl;
    _urlController = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewState = ref.watch(previewStateNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topBarBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (_urlController.text != previewState.currentUrl) {
      _urlController.text = previewState.currentUrl;
    }

    final targetWidth = previewState.deviceSize.targetWidth;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: topBarBg,
        title: Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_rounded, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: false,
                  ),
                  onSubmitted: (url) {
                    ref.read(previewStateNotifierProvider.notifier).navigateUrl(url);
                  },
                ),
              ),
              if (previewState.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InkWell(
                  onTap: () {
                    ref.read(previewStateNotifierProvider.notifier).reload();
                  },
                  child: const Icon(Icons.refresh_rounded, size: 16),
                ),
            ],
          ),
        ),
        actions: [
          // Device-size toggle (Phone, Tablet, Desktop)
          PopupMenuButton<DevicePreviewSize>(
            icon: Icon(
              previewState.deviceSize == DevicePreviewSize.phone
                  ? Icons.smartphone_rounded
                  : (previewState.deviceSize == DevicePreviewSize.tablet
                      ? Icons.tablet_rounded
                      : Icons.laptop_rounded),
              size: 20,
            ),
            tooltip: 'Toggle Device Size',
            onSelected: (size) {
              ref.read(previewStateNotifierProvider.notifier).setDeviceSize(size);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: DevicePreviewSize.phone,
                child: Row(
                  children: [
                    Icon(Icons.smartphone_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Phone (390×844)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DevicePreviewSize.tablet,
                child: Row(
                  children: [
                    Icon(Icons.tablet_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Tablet (768×1024)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DevicePreviewSize.desktop,
                child: Row(
                  children: [
                    Icon(Icons.laptop_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Full Width Desktop'),
                  ],
                ),
              ),
            ],
          ),
          // Toggle Console drawer
          IconButton(
            icon: Badge(
              label: Text('${previewState.consoleLogs.length}'),
              isLabelVisible: previewState.consoleLogs.isNotEmpty,
              backgroundColor: AppColors.accentCyan,
              child: const Icon(Icons.terminal_rounded, size: 20),
            ),
            tooltip: 'DevTools Console',
            onPressed: () {
              ref.read(previewStateNotifierProvider.notifier).toggleConsole();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Preview Surface with optional device frame
          Center(
            child: Container(
              width: targetWidth,
              decoration: targetWidth != null
                  ? BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(color: borderColor, width: 2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: const InteractivePreviewCanvas(),
            ),
          ),

          // Console / Error Drawer that slides up from the bottom
          if (previewState.isConsoleOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ConsoleDrawer(
                logs: previewState.consoleLogs,
                onClose: () {
                  ref.read(previewStateNotifierProvider.notifier).toggleConsole();
                },
                onClear: () {
                  ref.read(previewStateNotifierProvider.notifier).clearLogs();
                },
              ),
            ),
        ],
      ),
    );
  }
}
