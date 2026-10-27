import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preview_state.dart';

abstract class PreviewService {
  Future<void> reload();
  Future<void> setUrl(String url);
  Future<void> clearLogs();
}

class MockPreviewService implements PreviewService {
  @override
  Future<void> reload() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> setUrl(String url) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> clearLogs() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

final previewServiceProvider = Provider<PreviewService>((ref) {
  return MockPreviewService();
});

class PreviewStateNotifier extends StateNotifier<PreviewState> {
  final PreviewService _service;

  PreviewStateNotifier(this._service)
      : super(PreviewState(
          currentUrl: 'http://localhost:5173',
          isLoading: false,
          deviceSize: DevicePreviewSize.phone,
          isConsoleOpen: false,
          consoleLogs: [
            ConsoleLogEntry(
              id: 'log_1',
              level: ConsoleLogLevel.info,
              message: '[vite] connecting...',
              timestamp: DateTime.now().subtract(const Duration(seconds: 45)),
            ),
            ConsoleLogEntry(
              id: 'log_2',
              level: ConsoleLogLevel.info,
              message: '[vite] connected.',
              timestamp: DateTime.now().subtract(const Duration(seconds: 44)),
            ),
            ConsoleLogEntry(
              id: 'log_3',
              level: ConsoleLogLevel.warn,
              message: 'Warning: React has detected a component with an unmemoized callback.',
              timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
              stackTrace: 'at ProductCard (src/components/ProductCard.tsx:12:1)',
            ),
            ConsoleLogEntry(
              id: 'log_4',
              level: ConsoleLogLevel.info,
              message: '[vite] hot update: /src/App.tsx',
              timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
            ),
          ],
        ));

  void setDeviceSize(DevicePreviewSize size) {
    state = state.copyWith(deviceSize: size);
  }

  void toggleConsole() {
    state = state.copyWith(isConsoleOpen: !state.isConsoleOpen);
  }

  Future<void> reload() async {
    state = state.copyWith(isLoading: true);
    await _service.reload();
    final newLogs = [
      ...state.consoleLogs,
      ConsoleLogEntry(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        level: ConsoleLogLevel.info,
        message: '[vite] page reload triggered by user',
        timestamp: DateTime.now(),
      ),
    ];
    state = state.copyWith(isLoading: false, consoleLogs: newLogs);
  }

  Future<void> navigateUrl(String url) async {
    state = state.copyWith(isLoading: true, currentUrl: url);
    await _service.setUrl(url);
    state = state.copyWith(isLoading: false);
  }

  void clearLogs() {
    state = state.copyWith(consoleLogs: []);
  }
}

final previewStateNotifierProvider =
    StateNotifierProvider<PreviewStateNotifier, PreviewState>((ref) {
  final service = ref.watch(previewServiceProvider);
  return PreviewStateNotifier(service);
});
