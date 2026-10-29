import 'package:flutter/foundation.dart';

@immutable
class OpenFileTab {
  final String path;
  final String name;
  final bool isDirty;
  final String content;

  const OpenFileTab({
    required this.path,
    required this.name,
    this.isDirty = false,
    required this.content,
  });

  OpenFileTab copyWith({
    String? path,
    String? name,
    bool? isDirty,
    String? content,
  }) {
    return OpenFileTab(
      path: path ?? this.path,
      name: name ?? this.name,
      isDirty: isDirty ?? this.isDirty,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenFileTab &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          name == other.name &&
          isDirty == other.isDirty &&
          content == other.content;

  @override
  int get hashCode => Object.hash(path, name, isDirty, content);

  @override
  String toString() => 'OpenFileTab(path: $path, name: $name, isDirty: $isDirty)';
}
