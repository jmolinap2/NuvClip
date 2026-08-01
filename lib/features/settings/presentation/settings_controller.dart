import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuvclip/core/providers.dart';
import 'package:nuvclip/features/settings/domain/app_settings.dart';

final settingsControllerProvider = NotifierProvider<SettingsController, AppSettingsData>(SettingsController.new);

class SettingsController extends Notifier<AppSettingsData> {
  @override
  AppSettingsData build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> setPreferredQuality(int height) async {
    await ref.read(settingsRepositoryProvider).savePreferredQuality(height);
    state = state.copyWith(preferredQualityHeight: height);
  }

  Future<void> setSaveLocation(SaveLocation location) async {
    await ref.read(settingsRepositoryProvider).saveSaveLocation(location);
    state = state.copyWith(saveLocation: location);
  }

  Future<void> setWifiOnly(bool value) async {
    await ref.read(settingsRepositoryProvider).saveWifiOnly(value);
    state = state.copyWith(wifiOnly: value);
  }

  Future<void> setThemePreference(ThemePreference value) async {
    await ref.read(settingsRepositoryProvider).saveThemePreference(value);
    state = state.copyWith(themePreference: value);
  }
}
