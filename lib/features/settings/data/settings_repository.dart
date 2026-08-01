import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuvclip/features/settings/domain/app_settings.dart';

class SettingsRepository {
  const SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kQuality = 'preferred_quality_height';
  static const _kSaveLocation = 'save_location';
  static const _kWifiOnly = 'wifi_only';
  static const _kTheme = 'theme_preference';

  AppSettingsData load() {
    return AppSettingsData(
      preferredQualityHeight: _prefs.getInt(_kQuality) ?? 720,
      saveLocation: SaveLocation.values.firstWhere(
        (v) => v.name == _prefs.getString(_kSaveLocation),
        orElse: () => SaveLocation.downloads,
      ),
      wifiOnly: _prefs.getBool(_kWifiOnly) ?? true,
      themePreference: ThemePreference.values.firstWhere(
        (v) => v.name == _prefs.getString(_kTheme),
        orElse: () => ThemePreference.dark,
      ),
    );
  }

  Future<void> savePreferredQuality(int height) => _prefs.setInt(_kQuality, height);

  Future<void> saveSaveLocation(SaveLocation location) => _prefs.setString(_kSaveLocation, location.name);

  Future<void> saveWifiOnly(bool value) => _prefs.setBool(_kWifiOnly, value);

  Future<void> saveThemePreference(ThemePreference value) => _prefs.setString(_kTheme, value.name);
}
