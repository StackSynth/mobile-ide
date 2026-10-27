import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final ThemeMode themeMode;
  final double fontSize;
  final String fontFamily;
  final String keybarLayout;
  final String aiModel;
  final String accountName;
  final String accountEmail;
  final double cloudHoursUsed;
  final double cloudHoursLimit;
  final double ramUsedGb;
  final double ramLimitGb;
  final double diskUsedGb;
  final double diskLimitGb;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.fontSize = 13.0,
    this.fontFamily = 'JetBrains Mono',
    this.keybarLayout = 'Default Developer',
    this.aiModel = 'Claude 3.7 Sonnet',
    this.accountName = 'Alex Mercer',
    this.accountEmail = 'alex.mercer@clouddev.io',
    this.cloudHoursUsed = 18.5,
    this.cloudHoursLimit = 100.0,
    this.ramUsedGb = 2.4,
    this.ramLimitGb = 8.0,
    this.diskUsedGb = 5.8,
    this.diskLimitGb = 25.0,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    String? fontFamily,
    String? keybarLayout,
    String? aiModel,
    String? accountName,
    String? accountEmail,
    double? cloudHoursUsed,
    double? cloudHoursLimit,
    double? ramUsedGb,
    double? ramLimitGb,
    double? diskUsedGb,
    double? diskLimitGb,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      keybarLayout: keybarLayout ?? this.keybarLayout,
      aiModel: aiModel ?? this.aiModel,
      accountName: accountName ?? this.accountName,
      accountEmail: accountEmail ?? this.accountEmail,
      cloudHoursUsed: cloudHoursUsed ?? this.cloudHoursUsed,
      cloudHoursLimit: cloudHoursLimit ?? this.cloudHoursLimit,
      ramUsedGb: ramUsedGb ?? this.ramUsedGb,
      ramLimitGb: ramLimitGb ?? this.ramLimitGb,
      diskUsedGb: diskUsedGb ?? this.diskUsedGb,
      diskLimitGb: diskLimitGb ?? this.diskLimitGb,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(10.0, 24.0));
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }

  void setKeybarLayout(String layout) {
    state = state.copyWith(keybarLayout: layout);
  }

  void setAiModel(String model) {
    state = state.copyWith(aiModel: model);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
