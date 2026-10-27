import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_message.dart';
import '../models/file_diff.dart';

abstract class AiService {
  Future<List<AiMessage>> getHistory();
  Future<AiMessage> sendMessage({
    required String prompt,
    required List<String> contextChips,
  });
  Future<void> acceptDiff(String diffId);
  Future<void> rejectDiff(String diffId);
  Future<void> acceptAllDiffs();
}

class MockAiService implements AiService {
  final List<AiMessage> _history = [
    AiMessage(
      id: 'msg_welcome',
      sender: AiMessageSender.assistant,
      content: "Hi! I'm your mobile pair programmer. I can edit files, execute container commands, and explain code. Try asking me to add a badge to the product card or build a checkout flow.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      contextChips: ['src/App.tsx', 'Vite Dev Server (Port 5173)'],
    ),
    AiMessage(
      id: 'msg_user_1',
      sender: AiMessageSender.user,
      content: 'Add an "On Sale" badge to the ProductCard and style it with an emerald highlight.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      contextChips: ['src/components/ProductCard.tsx', 'Lines 12-25'],
    ),
    AiMessage(
      id: 'msg_asst_1',
      sender: AiMessageSender.assistant,
      content: "I've added the sale badge support to `ProductCard.tsx` and updated the default styling to match your emerald theme.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      actions: const [
        AgentAction(
          id: 'action_1',
          type: AgentActionType.fileEdit,
          title: 'Edited src/components/ProductCard.tsx',
          subtitle: '+8 lines, -2 lines',
          diffId: 'diff_product_card',
        ),
        AgentAction(
          id: 'action_2',
          type: AgentActionType.previewReload,
          title: 'Triggered Vite Fast Refresh',
          subtitle: 'HMR update dispatched to preview',
        ),
      ],
      contextChips: ['src/components/ProductCard.tsx', 'Vite Dev Server'],
      diffs: const [
        FileDiff(
          id: 'diff_product_card',
          filePath: 'src/components/ProductCard.tsx',
          fileTitle: 'ProductCard.tsx',
          summary: 'Add isSale prop and emerald discount badge',
          additions: 8,
          deletions: 2,
          lines: [
            DiffLine(
              type: DiffLineType.unchanged,
              text: 'interface ProductCardProps {',
              oldLineNumber: 3,
              newLineNumber: 3,
            ),
            DiffLine(
              type: DiffLineType.unchanged,
              text: '  title: string;',
              oldLineNumber: 4,
              newLineNumber: 4,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '  isSale?: boolean;',
              newLineNumber: 5,
            ),
            DiffLine(
              type: DiffLineType.unchanged,
              text: '  price: number;',
              oldLineNumber: 5,
              newLineNumber: 6,
            ),
            DiffLine(
              type: DiffLineType.deleted,
              text: '        {tag && (',
              oldLineNumber: 15,
            ),
            DiffLine(
              type: DiffLineType.deleted,
              text: '          <span className="text-xs px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-400 font-medium">',
              oldLineNumber: 16,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '        {isSale ? (',
              newLineNumber: 16,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '          <span className="text-xs px-2.5 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 font-semibold border border-emerald-500/40">',
              newLineNumber: 17,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '            SALE 20% OFF',
              newLineNumber: 18,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '          </span>',
              newLineNumber: 19,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '        ) : tag && (',
              newLineNumber: 20,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '          <span className="text-xs px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-400 font-medium">',
              newLineNumber: 21,
            ),
            DiffLine(
              type: DiffLineType.unchanged,
              text: '            {tag}',
              oldLineNumber: 17,
              newLineNumber: 22,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Future<List<AiMessage>> getHistory() async {
    return List.from(_history);
  }

  @override
  Future<AiMessage> sendMessage({
    required String prompt,
    required List<String> contextChips,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // Dynamic mock response based on prompt
    final reply = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiMessageSender.assistant,
      content: 'I analyzed your request: "$prompt". I have prepared changes in the codebase and executed the container checks.',
      timestamp: DateTime.now(),
      actions: [
        AgentAction(
          id: 'action_${DateTime.now().millisecondsSinceEpoch}_1',
          type: AgentActionType.fileEdit,
          title: 'Modified src/App.tsx',
          subtitle: 'Added component imports and responsive layout adjustments',
          diffId: 'diff_app_update',
        ),
        AgentAction(
          id: 'action_${DateTime.now().millisecondsSinceEpoch}_2',
          type: AgentActionType.terminalCommand,
          title: 'Executed pnpm test',
          subtitle: 'Pass: 3 test suites passed in 0.8s',
        ),
      ],
      contextChips: contextChips,
      diffs: [
        const FileDiff(
          id: 'diff_app_update',
          filePath: 'src/App.tsx',
          fileTitle: 'App.tsx',
          summary: 'Connect cart counter and sale banner state',
          additions: 5,
          deletions: 1,
          lines: [
            DiffLine(
              type: DiffLineType.unchanged,
              text: 'export default function App() {',
              oldLineNumber: 5,
              newLineNumber: 5,
            ),
            DiffLine(
              type: DiffLineType.deleted,
              text: '  const [cartCount, setCartCount] = useState(0);',
              oldLineNumber: 6,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '  const [cartCount, setCartCount] = useState(0);',
              newLineNumber: 6,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '  const [hasPromoActive, setHasPromoActive] = useState(true);',
              newLineNumber: 7,
            ),
            DiffLine(
              type: DiffLineType.added,
              text: '  // Handlers synced with mobile touch gestures',
              newLineNumber: 8,
            ),
          ],
        ),
      ],
    );

    return reply;
  }

  @override
  Future<void> acceptDiff(String diffId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> rejectDiff(String diffId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> acceptAllDiffs() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return MockAiService();
});

class AiChatState {
  final List<AiMessage> messages;
  final bool isThinking;
  final List<String> activeContextChips;
  final List<FileDiff> pendingDiffs;

  const AiChatState({
    required this.messages,
    this.isThinking = false,
    this.activeContextChips = const [],
    this.pendingDiffs = const [],
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isThinking,
    List<String>? activeContextChips,
    List<FileDiff>? pendingDiffs,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      activeContextChips: activeContextChips ?? this.activeContextChips,
      pendingDiffs: pendingDiffs ?? this.pendingDiffs,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiService _service;

  AiChatNotifier(this._service)
      : super(const AiChatState(
          messages: [],
          activeContextChips: ['src/App.tsx', 'Vite Dev (5173)', 'Selected: Lines 1-20'],
        )) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _service.getHistory();
    final allDiffs = <FileDiff>[];
    for (final m in history) {
      allDiffs.addAll(m.diffs);
    }
    state = state.copyWith(messages: history, pendingDiffs: allDiffs);
  }

  void addContextChip(String chip) {
    if (!state.activeContextChips.contains(chip)) {
      state = state.copyWith(
        activeContextChips: [...state.activeContextChips, chip],
      );
    }
  }

  void removeContextChip(String chip) {
    state = state.copyWith(
      activeContextChips:
          state.activeContextChips.where((c) => c != chip).toList(),
    );
  }

  Future<void> sendUserMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiMessageSender.user,
      content: prompt.trim(),
      timestamp: DateTime.now(),
      contextChips: List.from(state.activeContextChips),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    try {
      final asstMsg = await _service.sendMessage(
        prompt: prompt,
        contextChips: state.activeContextChips,
      );

      final newDiffs = [...state.pendingDiffs, ...asstMsg.diffs];

      state = state.copyWith(
        messages: [...state.messages, asstMsg],
        isThinking: false,
        pendingDiffs: newDiffs,
      );
    } catch (_) {
      state = state.copyWith(isThinking: false);
    }
  }

  void updateDiffStatus(String diffId, DiffStatus newStatus) {
    final updated = state.pendingDiffs.map((d) {
      if (d.id == diffId) {
        return d.copyWith(status: newStatus);
      }
      return d;
    }).toList();
    state = state.copyWith(pendingDiffs: updated);
  }

  void acceptAll() {
    final updated = state.pendingDiffs.map((d) {
      return d.copyWith(status: DiffStatus.accepted);
    }).toList();
    state = state.copyWith(pendingDiffs: updated);
  }
}

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final service = ref.watch(aiServiceProvider);
  return AiChatNotifier(service);
});
