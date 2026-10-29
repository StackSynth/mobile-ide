import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/terminal_session.dart';
import 'settings_service.dart';

abstract class TerminalService {
  Future<List<TerminalSession>> getSessions();
  Future<TerminalSession> createSession(String title);
  Future<void> closeSession(String sessionId);
  void sendInput(String sessionId, String input);
  Stream<String> getOutput(String sessionId);
  Future<void> reconnectSession(String sessionId);
}

class MockTerminalService implements TerminalService {
  final Map<String, StreamController<String>> _outputControllers = {};
  String _prompt = '\x1b[38;5;114mdeveloper@stack-container\x1b[0m:\x1b[38;5;39m~/workspace/react-shop\x1b[0m\$ ';

  /// Update the terminal prompt dynamically from user settings.
  set prompt(String newPrompt) => _prompt = newPrompt;
  final List<TerminalSession> _sessions = [
    const TerminalSession(
      id: 'term_dev',
      title: 'Vite Dev Server',
      history: [
        'pnpm install',
        'pnpm dev',
        'git status',
        'git diff src/App.tsx',
      ],
      connectionState: TerminalConnectionState.connected,
    ),
    const TerminalSession(
      id: 'term_bash',
      title: 'Bash Shell',
      history: [
        'ls -la',
        'cat package.json',
        'git status',
      ],
      connectionState: TerminalConnectionState.connected,
    ),
  ];

  MockTerminalService() {
    _initDevServerStream('term_dev');
    _initBashStream('term_bash');
  }

  void _initDevServerStream(String id) {
    final controller = StreamController<String>.broadcast();
    _outputControllers[id] = controller;
    
    // Initial banner
    Timer(const Duration(milliseconds: 100), () {
      controller.add('\\x1b[38;5;81m  VITE v6.2.0\\x1b[0m  ready in \\x1b[32m184 ms\\x1b[0m\\r\\n\\r\\n');
      controller.add('  \\x1b[32m➜\\x1b[0m  \\x1b[1mLocal:\\x1b[0m   http://localhost:\\x1b[1;36m5173\\x1b[0m/\\r\\n');
      controller.add('  \\x1b[32m➜\\x1b[0m  \\x1b[1mNetwork:\\x1b[0m http://172.18.0.2:\\x1b[1;36m5173\\x1b[0m/\\r\\n');
      controller.add('  \\x1b[2m➜\\x1b[0m  \\x1b[2mpress h + enter to show help\\x1b[0m\\r\\n\\r\\n');
      controller.add('\\x1b[38;5;141m[vite]\\x1b[0m \\x1b[32mhmr update\\x1b[0m /src/App.tsx (x2)\\r\\n');
    });
  }

  void _initBashStream(String id) {
    final controller = StreamController<String>.broadcast();
    _outputControllers[id] = controller;

    Timer(const Duration(milliseconds: 100), () {
      controller.add(_prompt);
    });
  }

  @override
  Future<List<TerminalSession>> getSessions() async {
    return List.from(_sessions);
  }

  @override
  Future<TerminalSession> createSession(String title) async {
    final newSession = TerminalSession(
      id: 'term_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      history: ['ls -la', 'git status'],
      connectionState: TerminalConnectionState.connected,
    );
    _sessions.add(newSession);
    _initBashStream(newSession.id);
    return newSession;
  }

  @override
  Future<void> closeSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    _outputControllers[sessionId]?.close();
    _outputControllers.remove(sessionId);
  }

  @override
  void sendInput(String sessionId, String input) {
    final controller = _outputControllers[sessionId];
    if (controller == null || controller.isClosed) return;

    // Esc key: avoid placing raw escape codes on the screen
    if (input == '\x1b') {
      return;
    }

    // Ctrl+C (SIGINT)
    if (input == '\x03') {
      controller.add('^C\r\n$_prompt');
      return;
    }

    // Command submission (ends with newline/carriage return)
    if (input.endsWith('\r\n') || input.endsWith('\n') || input.endsWith('\r') || input.endsWith('\\r\\n') || input.endsWith('\\n') || input.endsWith('\\r')) {
      final cmd = input.replaceAll(RegExp(r'[\r\n\\]'), ' ').trim();
      if (cmd.isEmpty) {
        controller.add('\r\n$_prompt');
        return;
      }

      if (cmd == 'clear') {
        controller.add('\x1b[2J\x1b[H$_prompt');
        return;
      }

      controller.add('$cmd\r\n');
      if (cmd == 'pnpm dev') {
        controller.add('\x1b[38;5;81m  VITE v6.2.0\x1b[0m  ready in \x1b[32m125 ms\x1b[0m\r\n\r\n  \x1b[32m➜\x1b[0m  \x1b[1mLocal:\x1b[0m   http://localhost:\x1b[1;36m5173\x1b[0m/\r\n  \x1b[32m➜\x1b[0m  \x1b[1mNetwork:\x1b[0m http://172.18.0.2:\x1b[1;36m5173\x1b[0m/\r\n');
      } else if (cmd == 'pnpm install') {
        controller.add('\x1b[2mResolving dependencies...\x1b[0m\r\n\x1b[32m✔ All dependencies are installed and up to date\x1b[0m\r\n');
      } else if (cmd == 'git status') {
        controller.add('On branch main\r\nYour branch is up to date with \'origin/main\'.\r\n\x1b[32mworking tree clean\x1b[0m\r\n');
      } else if (cmd == 'pnpm build') {
        controller.add('\x1b[2mvite v6.2.0 building for production...\x1b[0m\r\n\x1b[32m✓ 48 modules transformed.\x1b[0m\r\n\x1b[32m✓ built in 340ms\x1b[0m\r\n');
      } else if (cmd.startsWith('git commit')) {
        controller.add('[main 4a8f9c2] update files\r\n 2 files changed, 14 insertions(+)\r\n');
      }
      controller.add(_prompt);
      return;
    }

    // Regular character input
    controller.add(input);
  }

  @override
  Stream<String> getOutput(String sessionId) {
    if (!_outputControllers.containsKey(sessionId)) {
      _initBashStream(sessionId);
    }
    return _outputControllers[sessionId]!.stream;
  }

  @override
  Future<void> reconnectSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        connectionState: TerminalConnectionState.connected,
      );
      _outputControllers[sessionId]?.add('\\r\\n\\x1b[32m[Container Reconnected Successfully]\\x1b[0m\\r\\n');
    }
  }
}

final terminalServiceProvider = Provider<TerminalService>((ref) {
  final settings = ref.watch(settingsProvider);
  final service = MockTerminalService();
  service.prompt = settings.terminalPrompt;
  return service;
});

class TerminalStateNotifier extends StateNotifier<List<TerminalSession>> {
  final TerminalService _service;
  int activeIndex = 0;

  TerminalStateNotifier(this._service) : super([]) {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _service.getSessions();
    state = sessions;
  }

  TerminalSession? get activeSession =>
      (state.isNotEmpty && activeIndex >= 0 && activeIndex < state.length)
          ? state[activeIndex]
          : null;

  void setActiveSession(int index) {
    if (index >= 0 && index < state.length) {
      activeIndex = index;
      state = List.from(state);
    }
  }

  Future<void> createSession(String title) async {
    final newSession = await _service.createSession(title);
    state = [...state, newSession];
    activeIndex = state.length - 1;
  }

  Future<void> closeSession(int index) async {
    if (state.length <= 1) return; // Keep at least one
    final session = state[index];
    await _service.closeSession(session.id);
    final updated = List<TerminalSession>.from(state)..removeAt(index);
    if (activeIndex >= updated.length) {
      activeIndex = updated.length - 1;
    }
    state = updated;
  }

  Future<void> reconnect(String sessionId) async {
    // Show reconnecting state
    final index = state.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final list = List<TerminalSession>.from(state);
      list[index] = list[index].copyWith(
        connectionState: TerminalConnectionState.reconnecting,
      );
      state = list;
    }
    await _service.reconnectSession(sessionId);
    final list = List<TerminalSession>.from(state);
    list[index] = list[index].copyWith(
      connectionState: TerminalConnectionState.connected,
    );
    state = list;
  }

  void addCommandToHistory(String sessionId, String command) {
    final index = state.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = state[index];
      if (!session.history.contains(command)) {
        final newHistory = [command, ...session.history];
        final list = List<TerminalSession>.from(state);
        list[index] = session.copyWith(history: newHistory);
        state = list;
      }
    }
  }
}

final terminalSessionsProvider =
    StateNotifierProvider<TerminalStateNotifier, List<TerminalSession>>((ref) {
  final service = ref.watch(terminalServiceProvider);
  return TerminalStateNotifier(service);
});
