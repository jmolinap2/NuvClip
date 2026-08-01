enum SaveLocation { downloads, movies }

enum ThemePreference { light, dark, system }

extension SaveLocationLabel on SaveLocation {
  String get label => switch (this) {
        SaveLocation.downloads => 'Descargas',
        SaveLocation.movies => 'Galeria',
      };
}

extension ThemePreferenceLabel on ThemePreference {
  String get label => switch (this) {
        ThemePreference.light => 'Claro',
        ThemePreference.dark => 'Oscuro',
        ThemePreference.system => 'Automatico',
      };
}

/// Ajustes de la app (seccion 4, bloque Configuracion). Se guardan en
/// SharedPreferences: son media docena de valores escalares, no datos
/// relacionales, asi que no ameritan una tabla de Drift.
class AppSettingsData {
  const AppSettingsData({
    this.preferredQualityHeight = 720,
    this.saveLocation = SaveLocation.downloads,
    this.wifiOnly = true,
    this.themePreference = ThemePreference.dark,
  });

  final int preferredQualityHeight;
  final SaveLocation saveLocation;
  final bool wifiOnly;
  final ThemePreference themePreference;

  AppSettingsData copyWith({
    int? preferredQualityHeight,
    SaveLocation? saveLocation,
    bool? wifiOnly,
    ThemePreference? themePreference,
  }) {
    return AppSettingsData(
      preferredQualityHeight: preferredQualityHeight ?? this.preferredQualityHeight,
      saveLocation: saveLocation ?? this.saveLocation,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      themePreference: themePreference ?? this.themePreference,
    );
  }
}
