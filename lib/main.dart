import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuvclip/app/app.dart';
import 'package:nuvclip/core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // El historial formatea fechas en español (DateFormat('d MMM yyyy', 'es'));
  // sin esto, DateFormat revienta en tiempo de ejecucion con
  // LocaleDataException apenas la app intenta mostrar la primera fecha.
  await initializeDateFormatting('es');
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NuvClipApp(),
    ),
  );
}
