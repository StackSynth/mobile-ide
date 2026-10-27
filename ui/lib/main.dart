import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/app_router.dart';
import 'services/settings_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MobileCloudIdeApp()));
}

class MobileCloudIdeApp extends ConsumerWidget {
  const MobileCloudIdeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'StackSynth IDE',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme(
        fontSize: settings.fontSize,
        fontFamily: settings.fontFamily,
      ),
      darkTheme: AppTheme.darkTheme(
        fontSize: settings.fontSize,
        fontFamily: settings.fontFamily,
      ),
      routerConfig: appRouter,
    );
  }
}
