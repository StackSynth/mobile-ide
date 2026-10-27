import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accents
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentPink = Color(0xFFEC4899);

  // Dark Theme Palette (Default - High Contrast & Calm)
  static const Color darkBg = Color(0xFF0B0F17); // Deep OLED navy
  static const Color darkSurface = Color(0xFF131926);
  static const Color darkSurfaceElevated = Color(0xFF1E2638);
  static const Color darkCard = Color(0xFF182030);
  static const Color darkBorder = Color(0xFF283347);
  static const Color darkBorderHighlight = Color(0xFF3B4861);
  
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderHighlight = Color(0xFFCBD5E1);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Status & Git colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  static const Color gitModified = Color(0xFFEAB308); // Amber/Yellow
  static const Color gitAdded = Color(0xFF10B981);    // Green
  static const Color gitDeleted = Color(0xFFEF4444);  // Red
  static const Color gitUntracked = Color(0xFF6366F1);

  // Terminal
  static const Color terminalBg = Color(0xFF070A0F);
  static const Color terminalForeground = Color(0xFFE2E8F0);
  static const Color terminalCursor = Color(0xFF38BDF8);
  static const Color terminalSelection = Color(0xFF283652);

  // Code Syntax Highlighting
  static const Color syntaxKeyword = Color(0xFFFF7B72);
  static const Color syntaxString = Color(0xFFA5D6FF);
  static const Color syntaxNumber = Color(0xFF7EE787);
  static const Color syntaxFunction = Color(0xFFD2A8FF);
  static const Color syntaxVariable = Color(0xFF79C0FF);
  static const Color syntaxComment = Color(0xFF8B949E);
  static const Color syntaxTag = Color(0xFF7EE787);
  static const Color syntaxPunctuation = Color(0xFFE6EDF3);
}
