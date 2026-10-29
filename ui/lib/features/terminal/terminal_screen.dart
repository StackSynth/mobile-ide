import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/connection_status_banner.dart';
import '../../core/widgets/cmd_palette_button.dart';
import '../../models/terminal_session.dart';
import '../../services/terminal_service.dart';
import 'terminal_key_row.dart';
import 'command_history_sheet.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Terminal> _terminals = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final TextEditingController _commandInputController = TextEditingController();
  bool _isCtrlActive = false;

  final List<String> _quickCommands = [
    'pnpm install',
    'pnpm dev',
    'git status',
    'git commit -m "update"',
    'pnpm build',
    'clear',
  ];

  @override
  void initState() {
    super.initState();
    final sessions = ref.read(terminalSessionsProvider);
    _tabController = TabController(
      length: sessions.isNotEmpty ? sessions.length : 1,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
    _initTerminals(sessions);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      ref.read(terminalSessionsProvider.notifier).setActiveSession(_tabController.index);
    }
  }

  void _initTerminals(List<TerminalSession> sessions) {
    for (final session in sessions) {
      if (!_terminals.containsKey(session.id)) {
        final terminal = Terminal(maxLines: 2000);
        _terminals[session.id] = terminal;

        // Listen for user input on the xterm surface
        terminal.onOutput = (data) {
          ref.read(terminalServiceProvider).sendInput(session.id, data);
        };

        // Listen for container output stream
        final sub = ref.read(terminalServiceProvider).getOutput(session.id).listen((output) {
          terminal.write(output);
        });
        _subscriptions[session.id] = sub;
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _commandInputController.dispose();
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;
    final sessions = ref.read(terminalSessionsProvider);
    final activeIndex = _tabController.index;
    if (activeIndex >= 0 && activeIndex < sessions.length) {
      final session = sessions[activeIndex];
      // sendInput routes to the service stream listener which writes to terminal once, preventing duplication
      ref.read(terminalServiceProvider).sendInput(session.id, '$command\r\n');
      ref.read(terminalSessionsProvider.notifier).addCommandToHistory(session.id, command);
      _commandInputController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _handleKeyPress(String key) {
    final sessions = ref.read(terminalSessionsProvider);
    final activeIndex = _tabController.index;
    if (activeIndex >= 0 && activeIndex < sessions.length) {
      final session = sessions[activeIndex];
      ref.read(terminalServiceProvider).sendInput(session.id, key);
    }
  }

  void _showNewSessionDialog() {
    final controller = TextEditingController(text: 'Terminal ${ref.read(terminalSessionsProvider).length + 1}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Terminal Session'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Session title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                ref.read(terminalSessionsProvider.notifier).createSession(title);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(terminalSessionsProvider);

    // Sync tab controller if session count changed
    if (_tabController.length != sessions.length && sessions.isNotEmpty) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: sessions.length,
        vsync: this,
        initialIndex: oldIndex < sessions.length ? oldIndex : sessions.length - 1,
      );
      _tabController.addListener(_handleTabChange);
      _initTerminals(sessions);
    }

    final activeSession = (sessions.isNotEmpty && _tabController.index < sessions.length)
        ? sessions[_tabController.index]
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: AppColors.terminalBg,
      appBar: AppBar(
        backgroundColor: tabBg,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.terminal_rounded, size: 20, color: AppColors.accentCyan),
            SizedBox(width: 8),
            Text(
              'Terminal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          const CmdPaletteButton(),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 22),
            tooltip: 'New Terminal Tab',
            onPressed: _showNewSessionDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Reconnect Container',
            onPressed: () {
              if (activeSession != null) {
                ref.read(terminalSessionsProvider.notifier).reconnect(activeSession.id);
              }
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            decoration: BoxDecoration(
              color: tabBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.accentCyan,
              indicatorWeight: 2.5,
              labelColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              unselectedLabelColor: AppColors.darkTextMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: sessions.map((s) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: s.connectionState == TerminalConnectionState.connected
                              ? AppColors.success
                              : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(s.title),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Flaky Network Connection Banner
          if (activeSession != null)
            ConnectionStatusBanner(
              state: activeSession.connectionState,
              onReconnect: () {
                ref.read(terminalSessionsProvider.notifier).reconnect(activeSession.id);
              },
            ),

          // Quick Commands Chips (Thumb-friendly row)
          Container(
            height: 38,
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: _quickCommands.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cmd = _quickCommands[index];
                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurfaceElevated,
                  label: Text(
                    cmd,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  onPressed: () => _executeCommand(cmd),
                );
              },
            ),
          ),

          // Terminal Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: sessions.map((session) {
                final terminal = _terminals[session.id] ?? Terminal();
                return Container(
                  color: AppColors.terminalBg,
                  padding: const EdgeInsets.all(8),
                  child: TerminalView(
                    terminal,
                    backgroundOpacity: 1.0,
                    autofocus: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // Quick command input bar (above custom keys)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                const Text(
                  '\$ ',
                  style: TextStyle(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 15,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _commandInputController,
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Type container bash command...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    onSubmitted: _executeCommand,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20, color: AppColors.primaryLight),
                  onPressed: () => _executeCommand(_commandInputController.text),
                ),
              ],
            ),
          ),

          // Custom Key Row
          TerminalKeyRow(
            onKeyPress: _handleKeyPress,
            onToggleHistory: () {
              if (activeSession != null) {
                CommandHistorySheet.show(
                  context: context,
                  history: activeSession.history,
                  onSelectCommand: _executeCommand,
                );
              }
            },
            onClear: () {
              _handleKeyPress('clear\r\n');
            },
            isCtrlActive: _isCtrlActive,
            onToggleCtrl: () {
              setState(() => _isCtrlActive = !_isCtrlActive);
            },
          ),
        ],
      ),
    );
  }
}
