import 'package:permission_handler/permission_handler.dart';

/// Unico permiso en tiempo de ejecucion que necesita la app: la notificacion
/// de descarga en curso (seccion 4). Guardar el archivo no pide ningun
/// permiso porque, con minSdk 29, insertar en MediaStore desde el
/// ContentResolver de la propia app no lo requiere.
class PermissionService {
  const PermissionService();

  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
