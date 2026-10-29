import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/files/models/file_node.dart';
import '../features/files/models/open_file_tab.dart';
import '../features/files/services/file_service.dart';
import '../features/files/services/local_file_service.dart';
import '../features/files/providers/file_tree_notifier.dart';
import '../features/files/providers/file_tree_state.dart';

export '../features/files/models/file_node.dart';
export '../features/files/models/open_file_tab.dart';
export '../features/files/services/file_service.dart';
export '../features/files/services/local_file_service.dart';
export '../features/files/providers/file_tree_notifier.dart';
export '../features/files/providers/file_tree_state.dart';

// In-memory persistence per project for open tabs
final Map<String, List<String>> _persistedOpenTabs = {};

// Open File Tabs State Notifier
class OpenTabsState {
  final List<OpenFileTab> tabs;
  final int activeIndex;

  const OpenTabsState({
    required this.tabs,
    this.activeIndex = 0,
  });

  OpenFileTab? get activeTab =>
      (tabs.isNotEmpty && activeIndex >= 0 && activeIndex < tabs.length)
          ? tabs[activeIndex]
          : null;

  OpenTabsState copyWith({
    List<OpenFileTab>? tabs,
    int? activeIndex,
  }) {
    return OpenTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

class OpenTabsNotifier extends StateNotifier<OpenTabsState> {
  final FileService _fileService;
  final Ref _ref;

  OpenTabsNotifier(this._fileService, this._ref)
      : super(const OpenTabsState(tabs: [])) {
    _initDefaultTabs();
  }

  String get _currentProjectId => _ref.read(activeProjectIdProvider);

  Future<void> _initDefaultTabs() async {
    final projectId = _currentProjectId;
    final savedPaths = _persistedOpenTabs[projectId];

    if (savedPaths != null && savedPaths.isNotEmpty) {
      final loadedTabs = <OpenFileTab>[];
      for (final path in savedPaths) {
        try {
          final content = await _fileService.readFile(path);
          final name = path.contains('/') ? path.split('/').last : path;
          loadedTabs.add(OpenFileTab(path: path, name: name, content: content));
        } catch (_) {}
      }
      if (loadedTabs.isNotEmpty) {
        state = OpenTabsState(tabs: loadedTabs, activeIndex: 0);
        return;
      }
    }

    // Default starter tabs
    try {
      final appTsx = await _fileService.readFile('/src/App.tsx');
      final headerTsx = await _fileService.readFile('/src/components/Header.tsx');
      state = OpenTabsState(
        tabs: [
          OpenFileTab(path: '/src/App.tsx', name: 'App.tsx', content: appTsx, isDirty: false),
          OpenFileTab(path: '/src/components/Header.tsx', name: 'Header.tsx', content: headerTsx),
        ],
        activeIndex: 0,
      );
      _persistTabs();
    } catch (_) {
      // If project has no initial files, start with empty tabs
      state = const OpenTabsState(tabs: [], activeIndex: 0);
    }
  }

  void _persistTabs() {
    _persistedOpenTabs[_currentProjectId] = state.tabs.map((t) => t.path).toList();
  }

  Future<void> openFile(String path, String name) async {
    var cleanPath = path.replaceAll(r'\', '/');
    if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';

    final existingIndex = state.tabs.indexWhere((t) => t.path == cleanPath);
    if (existingIndex != -1) {
      state = state.copyWith(activeIndex: existingIndex);
      return;
    }

    try {
      final content = await _fileService.readFile(cleanPath);
      final newTabs = List<OpenFileTab>.from(state.tabs)
        ..add(OpenFileTab(path: cleanPath, name: name, content: content));
      state = OpenTabsState(tabs: newTabs, activeIndex: newTabs.length - 1);
      _persistTabs();
    } catch (_) {
      // If file cannot be read yet, open with empty buffer
      final newTabs = List<OpenFileTab>.from(state.tabs)
        ..add(OpenFileTab(path: cleanPath, name: name, content: ''));
      state = OpenTabsState(tabs: newTabs, activeIndex: newTabs.length - 1);
      _persistTabs();
    }
  }

  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;
    final newTabs = List<OpenFileTab>.from(state.tabs)..removeAt(index);
    int newActive = state.activeIndex;
    if (newActive >= newTabs.length) {
      newActive = newTabs.length - 1;
    }
    state = OpenTabsState(tabs: newTabs, activeIndex: newActive >= 0 ? newActive : 0);
    _persistTabs();
  }

  void closeTabByPath(String path) {
    var cleanPath = path.replaceAll(r'\', '/');
    if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
    final index = state.tabs.indexWhere((t) => t.path == cleanPath || t.path.startsWith('$cleanPath/'));
    if (index != -1) {
      closeTab(index);
    }
  }

  void handleFileRenamed(String oldPath, String newPath, String newName) {
    var cleanOld = oldPath.replaceAll(r'\', '/');
    if (!cleanOld.startsWith('/')) cleanOld = '/$cleanOld';
    var cleanNew = newPath.replaceAll(r'\', '/');
    if (!cleanNew.startsWith('/')) cleanNew = '/$cleanNew';

    final index = state.tabs.indexWhere((t) => t.path == cleanOld);
    if (index != -1) {
      final updatedTab = state.tabs[index].copyWith(path: cleanNew, name: newName);
      final newTabs = List<OpenFileTab>.from(state.tabs);
      newTabs[index] = updatedTab;
      state = state.copyWith(tabs: newTabs);
      _persistTabs();
    }
  }

  void setActiveTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      state = state.copyWith(activeIndex: index);
    }
  }

  void updateActiveContent(String newContent) {
    if (state.activeTab == null) return;
    final index = state.activeIndex;
    final updatedTab = state.tabs[index].copyWith(
      content: newContent,
      isDirty: true,
    );
    final newTabs = List<OpenFileTab>.from(state.tabs);
    newTabs[index] = updatedTab;
    state = state.copyWith(tabs: newTabs);
  }

  Future<void> saveActiveTab() async {
    final active = state.activeTab;
    if (active == null) return;
    await _fileService.writeFile(active.path, active.content);
    final index = state.activeIndex;
    final updatedTab = active.copyWith(isDirty: false);
    final newTabs = List<OpenFileTab>.from(state.tabs);
    newTabs[index] = updatedTab;
    state = state.copyWith(tabs: newTabs);
  }
}

final openTabsProvider =
    StateNotifierProvider<OpenTabsNotifier, OpenTabsState>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return OpenTabsNotifier(fileService, ref);
});
