import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FileIconWidget extends StatelessWidget {
  final String fileName;
  final bool isFolder;
  final bool isExpanded;
  final double size;

  const FileIconWidget({
    super.key,
    required this.fileName,
    this.isFolder = false,
    this.isExpanded = false,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (isFolder) {
      return Icon(
        isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
        size: size,
        color: AppColors.accentCyan,
      );
    }

    final ext = _getExtension(fileName);
    final iconData = _getIconData(ext);
    final color = _getColor(ext);

    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }

  static String _getExtension(String name) {
    final idx = name.lastIndexOf('.');
    if (idx == -1) return '';
    return name.substring(idx + 1).toLowerCase();
  }

  static IconData _getIconData(String ext) {
    switch (ext) {
      case 'dart':
        return Icons.flutter_dash_rounded;
      case 'ts':
      case 'tsx':
      case 'js':
      case 'jsx':
        return Icons.javascript_rounded;
      case 'json':
        return Icons.data_object_rounded;
      case 'md':
      case 'markdown':
        return Icons.article_rounded;
      case 'css':
      case 'scss':
      case 'sass':
      case 'less':
        return Icons.style_rounded;
      case 'html':
      case 'htm':
        return Icons.html_rounded;
      case 'py':
      case 'python':
        return Icons.terminal_rounded;
      case 'sh':
      case 'bash':
      case 'zsh':
        return Icons.terminal_rounded;
      case 'yaml':
      case 'yml':
        return Icons.settings_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'svg':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  static Color _getColor(String ext) {
    switch (ext) {
      case 'dart':
        return const Color(0xFF40C4FF);
      case 'ts':
      case 'tsx':
        return const Color(0xFF3178C6);
      case 'js':
      case 'jsx':
        return const Color(0xFFF7DF1E);
      case 'json':
        return const Color(0xFFFFA726);
      case 'md':
      case 'markdown':
        return const Color(0xFF818CF8);
      case 'css':
      case 'scss':
      case 'sass':
      case 'less':
        return const Color(0xFF38BDF8);
      case 'html':
      case 'htm':
        return const Color(0xFFFF6D00);
      case 'py':
      case 'python':
        return const Color(0xFF34D399);
      case 'sh':
      case 'bash':
      case 'zsh':
        return const Color(0xFFA3E635);
      case 'yaml':
      case 'yml':
        return const Color(0xFFFB7185);
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'svg':
      case 'gif':
      case 'webp':
        return const Color(0xFFA78BFA);
      default:
        return AppColors.darkTextMuted;
    }
  }
}
