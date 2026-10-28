import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CodeSyntaxHighlighter extends TextEditingController {
  final Map<RegExp, TextStyle> _patterns = {};

  CodeSyntaxHighlighter({super.text}) {
    _initPatterns();
  }

  void _initPatterns() {
    // Keywords (JS/TS/React/Dart/Python)
    final keywords = RegExp(
      r'\b(import|export|from|default|return|const|let|var|function|class|interface|type|extends|implements|if|else|for|while|switch|case|break|try|catch|finally|async|await|yield|new|this|typeof|instanceof)\b',
    );
    // Builtins / Booleans / Null
    final builtins = RegExp(r'\b(true|false|null|undefined|void|any|string|number|boolean)\b');
    // Strings
    final strings = RegExp(r'''("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`(?:[^`\\]|\\.)*`)''');
    // Numbers
    final numbers = RegExp(r'\b\d+(\.\d+)?\b');
    // JSX / TSX tags
    final tags = RegExp(r'(</?[a-zA-Z0-9_\-]+|/?>)');
    // Comments
    final comments = RegExp(r'(//.*|/\*[\s\S]*?\*/)');
    // Functions
    final functions = RegExp(r'\b([a-zA-Z0-9_]+)(?=\s*\()');

    _patterns[comments] = const TextStyle(color: AppColors.syntaxComment, fontStyle: FontStyle.italic);
    _patterns[strings] = const TextStyle(color: AppColors.syntaxString);
    _patterns[keywords] = const TextStyle(color: AppColors.syntaxKeyword, fontWeight: FontWeight.bold);
    _patterns[builtins] = const TextStyle(color: AppColors.accentCyan);
    _patterns[numbers] = const TextStyle(color: AppColors.syntaxNumber);
    _patterns[tags] = const TextStyle(color: AppColors.syntaxTag);
    _patterns[functions] = const TextStyle(color: AppColors.syntaxFunction);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> spans = [];
    final text = this.text;

    if (text.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    // Split lines or tokens
    int currentPos = 0;
    final combinedRegex = RegExp(
      r'''(//.*|/\*[\s\S]*?\*/)|("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`(?:[^`\\]|\\.)*`)|(\b(?:import|export|from|default|return|const|let|var|function|class|interface|type|extends|implements|if|else|for|while|switch|case|break|try|catch|finally|async|await|yield|new|this|typeof|instanceof)\b)|(\b(?:true|false|null|undefined|void|any|string|number|boolean)\b)|(</?[a-zA-Z0-9_\-]+|/?>)|(\b\d+(\.\d+)?\b)|(\b[a-zA-Z0-9_]+(?=\s*\())''',
      multiLine: true,
    );

    for (final match in combinedRegex.allMatches(text)) {
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: text.substring(currentPos, match.start),
          style: style,
        ));
      }

      final matchedText = match.group(0)!;
      TextStyle? matchedStyle;

      for (final entry in _patterns.entries) {
        if (entry.key.hasMatch(matchedText)) {
          matchedStyle = entry.value;
          break;
        }
      }

      spans.add(TextSpan(
        text: matchedText,
        style: style?.merge(matchedStyle) ?? matchedStyle,
      ));

      currentPos = match.end;
    }

    if (currentPos < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPos),
        style: style,
      ));
    }

    return TextSpan(style: style, children: spans);
  }
}
