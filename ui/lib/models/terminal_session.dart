enum TerminalConnectionState {
  connected,
  reconnecting,
  disconnected;

  String get label {
    switch (this) {
      case TerminalConnectionState.connected:
        return 'Container Connected';
      case TerminalConnectionState.reconnecting:
        return 'Reconnecting to container...';
      case TerminalConnectionState.disconnected:
        return 'Container Disconnected';
    }
  }
}

class TerminalSession {
  final String id;
  final String title;
  final String initialCommand;
  final List<String> history;
  final TerminalConnectionState connectionState;

  const TerminalSession({
    required this.id,
    required this.title,
    this.initialCommand = '',
    this.history = const [],
    this.connectionState = TerminalConnectionState.connected,
  });

  TerminalSession copyWith({
    String? id,
    String? title,
    String? initialCommand,
    List<String>? history,
    TerminalConnectionState? connectionState,
  }) {
    return TerminalSession(
      id: id ?? this.id,
      title: title ?? this.title,
      initialCommand: initialCommand ?? this.initialCommand,
      history: history ?? this.history,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
