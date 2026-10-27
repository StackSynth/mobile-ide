import 'package:flutter/material.dart';

enum ProjectStatus {
  running,
  sleeping,
  starting,
  error;

  String get label {
    switch (this) {
      case ProjectStatus.running:
        return 'Running';
      case ProjectStatus.sleeping:
        return 'Sleeping';
      case ProjectStatus.starting:
        return 'Starting';
      case ProjectStatus.error:
        return 'Error';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.running:
        return const Color(0xFF10B981); // Emerald
      case ProjectStatus.sleeping:
        return const Color(0xFF94A3B8); // Slate
      case ProjectStatus.starting:
        return const Color(0xFFF59E0B); // Amber
      case ProjectStatus.error:
        return const Color(0xFFEF4444); // Red
    }
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final String stack; // 'react_vite', 'nextjs', 'node', 'python', 'flutter', 'blank'
  final String stackLabel;
  final String stackIcon; // icon identifier or label
  final DateTime lastOpened;
  final ProjectStatus status;
  final String? containerUrl;
  final int port;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.stack,
    required this.stackLabel,
    required this.stackIcon,
    required this.lastOpened,
    required this.status,
    this.containerUrl,
    this.port = 5173,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? stack,
    String? stackLabel,
    String? stackIcon,
    DateTime? lastOpened,
    ProjectStatus? status,
    String? containerUrl,
    int? port,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      stack: stack ?? this.stack,
      stackLabel: stackLabel ?? this.stackLabel,
      stackIcon: stackIcon ?? this.stackIcon,
      lastOpened: lastOpened ?? this.lastOpened,
      status: status ?? this.status,
      containerUrl: containerUrl ?? this.containerUrl,
      port: port ?? this.port,
    );
  }
}
