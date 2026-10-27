import 'file_diff.dart';

enum AiMessageSender {
  user,
  assistant,
  system;
}

enum AgentActionType {
  fileEdit,
  fileCreate,
  fileDelete,
  terminalCommand,
  previewReload;

  String get iconName {
    switch (this) {
      case AgentActionType.fileEdit:
        return 'edit';
      case AgentActionType.fileCreate:
        return 'add_box';
      case AgentActionType.fileDelete:
        return 'delete';
      case AgentActionType.terminalCommand:
        return 'terminal';
      case AgentActionType.previewReload:
        return 'refresh';
    }
  }
}

class AgentAction {
  final String id;
  final AgentActionType type;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final String? diffId;

  const AgentAction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.isCompleted = true,
    this.diffId,
  });
}

class AiMessage {
  final String id;
  final AiMessageSender sender;
  final String content;
  final DateTime timestamp;
  final List<AgentAction> actions;
  final List<String> contextChips;
  final List<FileDiff> diffs;

  const AiMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.actions = const [],
    this.contextChips = const [],
    this.diffs = const [],
  });

  AiMessage copyWith({
    String? id,
    AiMessageSender? sender,
    String? content,
    DateTime? timestamp,
    List<AgentAction>? actions,
    List<String>? contextChips,
    List<FileDiff>? diffs,
  }) {
    return AiMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      actions: actions ?? this.actions,
      contextChips: contextChips ?? this.contextChips,
      diffs: diffs ?? this.diffs,
    );
  }
}
