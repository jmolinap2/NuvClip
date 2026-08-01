import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuvclip/core/db/database.dart';
import 'package:nuvclip/core/permissions/permission_service.dart';
import 'package:nuvclip/core/platform/engine_bridge.dart';
import 'package:nuvclip/features/history/data/history_repository.dart';
import 'package:nuvclip/features/settings/data/settings_repository.dart';

/// Se sobreescribe en `main.dart` con la instancia real, obtenida antes de
/// `runApp` (patron estandar de Riverpod para dependencias que solo se
/// pueden crear de forma asincrona).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider no fue sobreescrito en main()'),
);

final engineBridgeProvider = Provider<EngineBridge>((ref) => EngineBridge());

final databaseProvider = Provider<NuvClipDatabase>((ref) {
  final db = NuvClipDatabase();
  ref.onDispose(db.close);
  return db;
});

final permissionServiceProvider = Provider<PermissionService>((ref) => const PermissionService());

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(databaseProvider)),
);
