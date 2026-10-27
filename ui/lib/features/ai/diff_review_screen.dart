import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/file_diff.dart';
import '../../services/ai_service.dart';

class DiffReviewScreen extends ConsumerStatefulWidget {
  const DiffReviewScreen({super.key});

  @override
  ConsumerState<DiffReviewScreen> createState() => _DiffReviewScreenState();
}

class _DiffReviewScreenState extends ConsumerState<DiffReviewScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiChatProvider);
    final diffs = aiState.pendingDiffs;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (diffs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Diffs')),
        body: const Center(
          child: Text('No pending diffs to review.', style: TextStyle(color: AppColors.darkTextMuted)),
        ),
      );
    }

    final safeIndex = _currentIndex.clamp(0, diffs.length - 1);
    final currentDiff = diffs[safeIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review AI Diffs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '${safeIndex + 1} of ${diffs.length} files • +${currentDiff.additions} -${currentDiff.deletions}',
              style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(aiChatProvider.notifier).acceptAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Accepted all pending AI diffs'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.success),
            label: const Text('Accept All', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // File header with status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: surfaceColor,
            child: Row(
              children: [
                const Icon(Icons.code_rounded, size: 18, color: AppColors.accentCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentDiff.filePath,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: currentDiff.status == DiffStatus.accepted
                        ? AppColors.success.withOpacity(0.18)
                        : (currentDiff.status == DiffStatus.rejected
                            ? AppColors.error.withOpacity(0.18)
                            : AppColors.warning.withOpacity(0.18)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentDiff.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: currentDiff.status == DiffStatus.accepted
                          ? AppColors.success
                          : (currentDiff.status == DiffStatus.rejected
                              ? AppColors.error
                              : AppColors.warning),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Swipe instruction hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_left_rounded, size: 16, color: AppColors.error),
                SizedBox(width: 4),
                Text('Swipe Left to Reject', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                SizedBox(width: 16),
                Text('•', style: TextStyle(color: AppColors.darkTextMuted)),
                SizedBox(width: 16),
                Text('Swipe Right to Accept', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                SizedBox(width: 4),
                Icon(Icons.swipe_right_rounded, size: 16, color: AppColors.success),
              ],
            ),
          ),

          // Unified Diff Viewer inside Dismissible card
          Expanded(
            child: Dismissible(
              key: Key(currentDiff.id),
              direction: DismissDirection.horizontal,
              background: Container(
                color: AppColors.success.withOpacity(0.2),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 32),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
                    SizedBox(width: 8),
                    Text('Accept Diff', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              secondaryBackground: Container(
                color: AppColors.error.withOpacity(0.2),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 32),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Reject Diff', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.cancel_rounded, color: AppColors.error, size: 36),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  ref.read(aiChatProvider.notifier).updateDiffStatus(currentDiff.id, DiffStatus.accepted);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Accepted diff for ${currentDiff.fileTitle}'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ref.read(aiChatProvider.notifier).updateDiffStatus(currentDiff.id, DiffStatus.rejected);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rejected diff for ${currentDiff.fileTitle}'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                return false; // keep card visible with updated status chip
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF070A0F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: currentDiff.lines.length,
                  itemBuilder: (context, index) {
                    final line = currentDiff.lines[index];
                    final isAdded = line.type == DiffLineType.added;
                    final isDeleted = line.type == DiffLineType.deleted;

                    final lineBg = isAdded
                        ? AppColors.gitAdded.withOpacity(0.12)
                        : (isDeleted ? AppColors.gitDeleted.withOpacity(0.12) : Colors.transparent);

                    final textColor = isAdded
                        ? AppColors.gitAdded
                        : (isDeleted ? AppColors.gitDeleted : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary));

                    final prefix = isAdded ? '+' : (isDeleted ? '-' : ' ');

                    return Container(
                      color: lineBg,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line numbers
                          SizedBox(
                            width: 28,
                            child: Text(
                              line.oldLineNumber != null ? '${line.oldLineNumber}' : '',
                              style: AppTheme.getMonoStyle(fontSize: 11, color: AppColors.darkTextMuted),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 28,
                            child: Text(
                              line.newLineNumber != null ? '${line.newLineNumber}' : '',
                              style: AppTheme.getMonoStyle(fontSize: 11, color: AppColors.darkTextMuted),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            prefix,
                            style: AppTheme.getMonoStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              line.text,
                              style: AppTheme.getMonoStyle(
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Navigation Buttons (Accept / Reject / Next / Previous)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(aiChatProvider.notifier).updateDiffStatus(currentDiff.id, DiffStatus.rejected);
                    },
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                    label: const Text('Reject', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(aiChatProvider.notifier).updateDiffStatus(currentDiff.id, DiffStatus.accepted);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                    label: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
