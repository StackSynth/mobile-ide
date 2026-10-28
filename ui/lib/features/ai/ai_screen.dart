import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cmd_palette_button.dart';
import '../../models/ai_message.dart';
import '../../models/file_diff.dart';
import '../../services/ai_service.dart';
import 'agent_action_card.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _promptSuggestions = [
    'Add checkout modal with credit card fields',
    'Fix React 19 unmemoized hook warning',
    'Run test suite and fix failing tests',
    'Add dark mode toggle button to Header',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    ref.read(aiChatProvider.notifier).sendUserMessage(text);
    _promptController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiChatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final pendingDiffCount = aiState.pendingDiffs.where((d) => d.status == DiffStatus.pending).length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primaryLight),
            SizedBox(width: 8),
            Text(
              'AI Pair Programmer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          const CmdPaletteButton(),
          if (pendingDiffCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/ai/diff-review'),
                icon: const Icon(Icons.rate_review_rounded, size: 14),
                label: Text(
                  'Diffs ($pendingDiffCount)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Context Chips Header (What the AI can see)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 16, color: AppColors.accentCyan),
                const SizedBox(width: 8),
                const Text(
                  'Context:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: aiState.activeContextChips.map((chip) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Chip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                            label: Text(
                              chip,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close_rounded, size: 12),
                            onDeleted: () {
                              ref.read(aiChatProvider.notifier).removeContextChip(chip);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: aiState.messages.length + (aiState.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == aiState.messages.length && aiState.isThinking) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryLight),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AI is editing files & running container checks...',
                          style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  );
                }

                final msg = aiState.messages[index];
                final isUser = msg.sender == AiMessageSender.user;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accentCyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColors.primary
                                : (isDark ? AppColors.darkCard : AppColors.lightCard),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isUser ? 14 : 2),
                              bottomRight: Radius.circular(isUser ? 2 : 14),
                            ),
                            border: isUser
                                ? null
                                : Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: isUser
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  height: 1.4,
                                ),
                              ),
                              // Render Agent Action Cards
                              if (msg.actions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...msg.actions.map((act) {
                                  return AgentActionCard(
                                    action: act,
                                    onViewDiff: act.diffId != null
                                        ? () => context.push('/ai/diff-review')
                                        : null,
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.accentCyan.withOpacity(0.2),
                          child: const Icon(Icons.person_rounded, size: 16, color: AppColors.accentCyan),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Quick Prompt suggestions (Thumb-friendly row)
          Container(
            height: 36,
            color: surfaceColor,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _promptSuggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final suggestion = _promptSuggestions[index];
                return InkWell(
                  onTap: () {
                    _promptController.text = suggestion;
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                    ),
                  ),
                );
              },
            ),
          ),

          // Prompt box pinned above the keyboard
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Describe changes: "Add checkout button"...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
