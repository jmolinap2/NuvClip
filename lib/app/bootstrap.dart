import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuvclip/core/providers.dart';

enum BootstrapStage { starting, ready }

class BootstrapState {
  const BootstrapState({this.stage = BootstrapStage.starting});

  final BootstrapStage stage;

  bool get isReady => stage == BootstrapStage.ready;
}

final bootstrapProvider = NotifierProvider<BootstrapController, BootstrapState>(BootstrapController.new);

/// Arranque de la app: motor primero, notificacion despues. La notificacion
/// depende de un permiso que el usuario puede rechazar, pero eso no debe
/// bloquear poder analizar y descargar (a diferencia de NuvTune, aqui no hay
/// un permiso de lectura que sea estrictamente necesario para funcionar).
class BootstrapController extends Notifier<BootstrapState> {
  @override
  BootstrapState build() => const BootstrapState();

  Future<void> start() async {
    await ref.read(engineBridgeProvider).ensureInitialized();
    await ref.read(permissionServiceProvider).requestNotifications();
    state = const BootstrapState(stage: BootstrapStage.ready);
  }
}
