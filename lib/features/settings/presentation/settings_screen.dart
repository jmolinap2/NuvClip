import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/core/providers.dart';
import 'package:nuvclip/features/settings/domain/app_settings.dart';
import 'package:nuvclip/features/settings/presentation/settings_controller.dart';
import 'package:nuvclip/shared/widgets/glass.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Tokens.gutter, Tokens.space5, Tokens.gutter, Tokens.space7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajustes', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: Tokens.space1),
              Text(
                'Personaliza tu experiencia de descarga',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Palette.textSecondary),
              ),
              const SizedBox(height: Tokens.space6),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.hd_rounded,
                      title: 'Calidad preferida',
                      subtitle: 'Define la calidad por defecto',
                      value: '${settings.preferredQualityHeight}p',
                      onTap: () => _pickQuality(context, controller, settings.preferredQualityHeight),
                    ),
                    const Divider(height: 1, indent: Tokens.space5, endIndent: Tokens.space5),
                    _SettingsRow(
                      icon: Icons.folder_rounded,
                      title: 'Guardar en',
                      subtitle: 'Carpeta de destino',
                      value: settings.saveLocation.label,
                      onTap: () => _pickSaveLocation(context, controller, settings.saveLocation),
                    ),
                    const Divider(height: 1, indent: Tokens.space5, endIndent: Tokens.space5),
                    _SwitchRow(
                      icon: Icons.wifi_rounded,
                      title: 'Solo con Wi-Fi',
                      subtitle: 'Evita usar datos moviles',
                      value: settings.wifiOnly,
                      onChanged: controller.setWifiOnly,
                    ),
                    const Divider(height: 1, indent: Tokens.space5, endIndent: Tokens.space5),
                    _SettingsRow(
                      icon: Icons.dark_mode_rounded,
                      title: 'Tema',
                      subtitle: 'Apariencia de la aplicacion',
                      value: settings.themePreference.label,
                      onTap: () => _pickTheme(context, controller, settings.themePreference),
                    ),
                    const Divider(height: 1, indent: Tokens.space5, endIndent: Tokens.space5),
                    const _UpdateExtractorRow(),
                    const Divider(height: 1, indent: Tokens.space5, endIndent: Tokens.space5),
                    _SettingsRow(
                      icon: Icons.delete_outline_rounded,
                      iconColor: Palette.danger,
                      title: 'Limpiar historial',
                      subtitle: 'Elimina tu historial de descargas',
                      onTap: () => _confirmClearHistory(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.space5),
              GlassCard(
                borderColor: Palette.accentBlue,
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Palette.accentBlue),
                    const SizedBox(width: Tokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sin anuncios · Sin suscripcion', style: Theme.of(context).textTheme.titleMedium),
                          Text('NuvClip es 100% gratis. Siempre lo sera.', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.space4),
              const Center(child: _VersionLabel()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickQuality(BuildContext context, SettingsController controller, int current) async {
    final selected = await _showPicker<int>(
      context,
      title: 'Calidad preferida',
      options: const [1080, 720, 480],
      labelOf: (height) => '${height}p',
      current: current,
    );
    if (selected != null) controller.setPreferredQuality(selected);
  }

  Future<void> _pickSaveLocation(BuildContext context, SettingsController controller, SaveLocation current) async {
    final selected = await _showPicker<SaveLocation>(
      context,
      title: 'Guardar en',
      options: SaveLocation.values,
      labelOf: (v) => v.label,
      current: current,
    );
    if (selected != null) controller.setSaveLocation(selected);
  }

  Future<void> _pickTheme(BuildContext context, SettingsController controller, ThemePreference current) async {
    final selected = await _showPicker<ThemePreference>(
      context,
      title: 'Tema',
      options: ThemePreference.values,
      labelOf: (v) => v.label,
      current: current,
    );
    if (selected != null) controller.setThemePreference(selected);
  }

  Future<T?> _showPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T) labelOf,
    required T current,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Palette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tokens.radiusLarge))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: Tokens.space3),
              for (final option in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(labelOf(option)),
                  trailing: option == current ? const Icon(Icons.check_rounded, color: Palette.accentBlue) : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.surface,
        title: const Text('Limpiar historial'),
        content: const Text('Se eliminaran todos los registros del historial. Los videos ya guardados no se borran.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(historyRepositoryProvider).clearAll();
    }
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.space5, vertical: Tokens.space1),
      leading: _RowIcon(icon: icon, color: iconColor),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(value!, style: const TextStyle(color: Palette.accentBlue, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right_rounded, color: Palette.textMuted),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.space5, vertical: Tokens.space1),
      leading: _RowIcon(icon: icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _RowIcon extends StatelessWidget {
  const _RowIcon({required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Tokens.space2),
      decoration: BoxDecoration(color: Palette.background, borderRadius: BorderRadius.circular(Tokens.radiusSmall)),
      child: Icon(icon, color: color ?? Palette.accentBlue, size: 20),
    );
  }
}

class _UpdateExtractorRow extends ConsumerStatefulWidget {
  const _UpdateExtractorRow();

  @override
  ConsumerState<_UpdateExtractorRow> createState() => _UpdateExtractorRowState();
}

class _UpdateExtractorRowState extends ConsumerState<_UpdateExtractorRow> {
  bool _checking = false;

  Future<void> _update() async {
    setState(() => _checking = true);
    try {
      final result = await ref.read(engineBridgeProvider).updateExtractor();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.updated
                ? 'Extractor actualizado a ${result.versionName ?? "una version nueva"}.'
                : 'El extractor ya esta al dia.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo comprobar actualizaciones del extractor.')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _checking ? null : _update,
      contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.space5, vertical: Tokens.space1),
      leading: const _RowIcon(icon: Icons.system_update_rounded),
      title: Text('Actualizar extractor', style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text('Manten el extractor siempre al dia', style: Theme.of(context).textTheme.bodySmall),
      trailing: _checking
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.chevron_right_rounded, color: Palette.textMuted),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        return Text(
          version.isEmpty ? '' : 'Version $version',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}
