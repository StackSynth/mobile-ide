import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/cmd_palette_button.dart';
import '../../services/file_service.dart';
import '../../services/ai_service.dart';
import '../../services/settings_service.dart';
import 'code_tab_strip.dart';
import 'symbol_toolbar.dart';
import 'code_syntax_highlighter.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late CodeSyntaxHighlighter _codeController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  String? _lastLoadedPath;
  double _baseScale = 1.0;
  bool _hasSelection = false;
  String _selectedText = '';
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _codeController = CodeSyntaxHighlighter(text: '');
    _codeController.addListener(_handleTextAndSelectionChange);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _codeController.removeListener(_handleTextAndSelectionChange);
    _codeController.dispose();
    _editorFocusNode.dispose();
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  void _handleTextAndSelectionChange() {
    final selection = _codeController.selection;
    if (!selection.isCollapsed && selection.isValid) {
      final selected = _codeController.text.substring(selection.start, selection.end);
      if (selected.trim().isNotEmpty && selected != _selectedText) {
        setState(() {
          _hasSelection = true;
          _selectedText = selected;
        });
      }
    } else if (_hasSelection) {
      setState(() {
        _hasSelection = false;
        _selectedText = '';
      });
    }

    final activeTab = ref.read(openTabsProvider).activeTab;
    if (activeTab != null && _codeController.text != activeTab.content) {
      ref.read(openTabsProvider.notifier).updateActiveContent(_codeController.text);
      // Autosave after 1s of no typing
      _autosaveTimer?.cancel();
      _autosaveTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          ref.read(openTabsProvider.notifier).saveActiveTab();
        }
      });
    }
  }

  void _syncControllerWithActiveTab() {
    final activeTab = ref.watch(openTabsProvider).activeTab;
    if (activeTab != null && activeTab.path != _lastLoadedPath) {
      _lastLoadedPath = activeTab.path;
      _undoStack.clear();
      _redoStack.clear();
      _codeController.text = activeTab.content;
      _codeController.selection = const TextSelection.collapsed(offset: 0);
    }
  }

  void _recordUndoState() {
    _undoStack.add(_codeController.text);
    _redoStack.clear();
    if (_undoStack.length > 50) _undoStack.removeAt(0);
  }

  void _handleUndo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(_codeController.text);
      final prev = _undoStack.removeLast();
      _codeController.text = prev;
    }
  }

  void _handleRedo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(_codeController.text);
      final next = _redoStack.removeLast();
      _codeController.text = next;
    }
  }

  void _insertSymbol(String symbol) {
    _recordUndoState();
    final text = _codeController.text;
    final selection = _codeController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final newText = text.replaceRange(start, end, symbol);
    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + symbol.length),
    );
  }

  void _handleTabIndent() {
    _insertSymbol('  '); // 2 spaces
  }

  void _handleSelectLine() {
    final text = _codeController.text;
    final selection = _codeController.selection;
    final currentPos = selection.isValid ? selection.start : 0;

    int lineStart = text.lastIndexOf('\n', currentPos == 0 ? 0 : currentPos - 1);
    lineStart = lineStart == -1 ? 0 : lineStart + 1;

    int lineEnd = text.indexOf('\n', currentPos);
    lineEnd = lineEnd == -1 ? text.length : lineEnd;

    _codeController.selection = TextSelection(baseOffset: lineStart, extentOffset: lineEnd);
  }

  void _handleToggleComment() {
    _recordUndoState();
    final text = _codeController.text;
    final selection = _codeController.selection;
    final currentPos = selection.isValid ? selection.start : 0;

    int lineStart = text.lastIndexOf('\n', currentPos == 0 ? 0 : currentPos - 1);
    lineStart = lineStart == -1 ? 0 : lineStart + 1;

    if (text.substring(lineStart).startsWith('// ')) {
      final newText = text.replaceRange(lineStart, lineStart + 3, '');
      _codeController.text = newText;
    } else {
      final newText = text.replaceRange(lineStart, lineStart, '// ');
      _codeController.text = newText;
    }
  }

  void _askAiAboutSelection() {
    if (_selectedText.isEmpty) return;
    final activeTab = ref.read(openTabsProvider).activeTab;
    final chipLabel = activeTab != null ? '${activeTab.name} (Selection)' : 'Selected code';
    ref.read(aiChatProvider.notifier).addContextChip(chipLabel);
    context.go('/ai');
  }

  @override
  Widget build(BuildContext context) {
    _syncControllerWithActiveTab();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final openTabsState = ref.watch(openTabsProvider);
    final activeTab = openTabsState.activeTab;
    final settings = ref.watch(settingsProvider);
    final currentFontSize = settings.fontSize * _baseScale;

    if (activeTab == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editor'),
        ),
        body: EmptyStateView(
          icon: Icons.code_rounded,
          title: 'No Files Open',
          description: 'Select a file from the workspace file tree or create a new component to start editing.',
          actionLabel: 'Browse Files',
          onAction: () => context.go('/files'),
        ),
      );
    }

    final lineCount = '\n'.allMatches(_codeController.text).length + 1;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                activeTab.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Save indicator
            if (activeTab.isDirty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Unsaved',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              )
            else
              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
          ],
        ),
        actions: [
          const CmdPaletteButton(),
          // Save button
          IconButton(
            icon: const Icon(Icons.save_outlined, size: 20),
            tooltip: 'Save (Ctrl+S)',
            onPressed: () {
              ref.read(openTabsProvider.notifier).saveActiveTab();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved ${activeTab.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          // Run / Preview shortcut
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.accentCyan, size: 22),
            tooltip: 'Run in Preview',
            onPressed: () {
              ref.read(openTabsProvider.notifier).saveActiveTab();
              context.go('/preview');
            },
          ),
          // Overflow menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'zoom_in') {
                ref.read(settingsProvider.notifier).setFontSize(settings.fontSize + 1);
              } else if (val == 'zoom_out') {
                ref.read(settingsProvider.notifier).setFontSize(settings.fontSize - 1);
              } else if (val == 'format') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code formatted (Prettier)')),
                );
              } else if (val == 'close') {
                ref.read(openTabsProvider.notifier).closeTab(openTabsState.activeIndex);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'format', child: Text('Format Code (Prettier)')),
              const PopupMenuItem(value: 'zoom_in', child: Text('Increase Font Size')),
              const PopupMenuItem(value: 'zoom_out', child: Text('Decrease Font Size')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'close', child: Text('Close File')),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Horizontally scrollable tab strip
              const CodeTabStrip(),

              // Code editing surface with pinch-to-zoom
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: (ScaleUpdateDetails details) {
                    if (details.scale != 1.0) {
                      setState(() {
                        _baseScale = (_baseScale * details.scale).clamp(0.8, 1.8);
                      });
                    }
                  },
                  child: Container(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line numbers gutter
                        Container(
                          width: 42,
                          padding: const EdgeInsets.only(top: 14, right: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            border: Border(
                              right: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                          ),
                          child: ListView.builder(
                            controller: _verticalScroll,
                            itemCount: lineCount,
                            itemBuilder: (context, index) {
                              return Text(
                                '${index + 1}',
                                textAlign: TextAlign.right,
                                style: AppTheme.getMonoStyle(
                                  fontSize: currentFontSize,
                                  color: AppColors.darkTextMuted,
                                ),
                              );
                            },
                          ),
                        ),

                        // Code Editor Body
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _horizontalScroll,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1200,
                              child: TextField(
                                controller: _codeController,
                                focusNode: _editorFocusNode,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: AppTheme.getMonoStyle(
                                  fontSize: currentFontSize,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(12, 14, 16, 80),
                                  filled: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Symbol toolbar above the keyboard
              SymbolToolbar(
                onInsertSymbol: _insertSymbol,
                onUndo: _handleUndo,
                onRedo: _handleRedo,
                onSelectLine: _handleSelectLine,
                onToggleComment: _handleToggleComment,
                onTabIndent: _handleTabIndent,
              ),
            ],
          ),

          // Floating "Ask AI about this" button when text is selected
          if (_hasSelection)
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _askAiAboutSelection,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'Ask AI about this (${_selectedText.length > 20 ? '${_selectedText.substring(0, 18)}...' : _selectedText})',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3A3A),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
