enum DevicePreviewSize {
  phone,
  tablet,
  desktop;

  String get label {
    switch (this) {
      case DevicePreviewSize.phone:
        return 'Phone (390×844)';
      case DevicePreviewSize.tablet:
        return 'Tablet (768×1024)';
      case DevicePreviewSize.desktop:
        return 'Desktop (1280×800)';
    }
  }

  double? get targetWidth {
    switch (this) {
      case DevicePreviewSize.phone:
        return 390;
      case DevicePreviewSize.tablet:
        return 680;
      case DevicePreviewSize.desktop:
        return null; // full width
    }
  }
}

enum ConsoleLogLevel {
  info,
  warn,
  error;

  String get label => name.toUpperCase();
}

class ConsoleLogEntry {
  final String id;
  final ConsoleLogLevel level;
  final String message;
  final DateTime timestamp;
  final String? stackTrace;

  const ConsoleLogEntry({
    required this.id,
    required this.level,
    required this.message,
    required this.timestamp,
    this.stackTrace,
  });
}

class PreviewState {
  final String currentUrl;
  final bool isLoading;
  final DevicePreviewSize deviceSize;
  final List<ConsoleLogEntry> consoleLogs;
  final bool isConsoleOpen;
  final bool isSecure;

  const PreviewState({
    this.currentUrl = 'http://localhost:5173',
    this.isLoading = false,
    this.deviceSize = DevicePreviewSize.phone,
    this.consoleLogs = const [],
    this.isConsoleOpen = false,
    this.isSecure = true,
  });

  PreviewState copyWith({
    String? currentUrl,
    bool? isLoading,
    DevicePreviewSize? deviceSize,
    List<ConsoleLogEntry>? consoleLogs,
    bool? isConsoleOpen,
    bool? isSecure,
  }) {
    return PreviewState(
      currentUrl: currentUrl ?? this.currentUrl,
      isLoading: isLoading ?? this.isLoading,
      deviceSize: deviceSize ?? this.deviceSize,
      consoleLogs: consoleLogs ?? this.consoleLogs,
      isConsoleOpen: isConsoleOpen ?? this.isConsoleOpen,
      isSecure: isSecure ?? this.isSecure,
    );
  }
}
