#!/usr/bin/env bash
# Compila e instala la APK release de NuvClip.
# Uso: tools/deploy.sh [ip:puerto-de-depuracion-inalambrica]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADB="${ADB:-/c/Android/Sdk/platform-tools/adb.exe}"
AAPT="${AAPT:-/c/Android/Sdk/build-tools/36.0.0/aapt.exe}"
FLUTTER="${FLUTTER:-/c/Users/USER/flutter/bin/flutter}"
DEVICE="${1:-}"

APP_NAME="NuvClip"
PACKAGE_NAME="com.nuvclip.app"

usage() {
  cat <<EOF
Uso:
  tools/deploy.sh [ip:puerto]

Ejemplos:
  tools/deploy.sh 192.168.1.108:38723
  tools/deploy.sh

Variables opcionales:
  ADB=/c/Android/Sdk/platform-tools/adb.exe
  AAPT=/c/Android/Sdk/build-tools/36.0.0/aapt.exe
  FLUTTER=/c/Users/USER/flutter/bin/flutter
EOF
}

if [[ "${DEVICE:-}" == "-h" || "${DEVICE:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  echo "No se encontro pubspec.yaml en $ROOT. Crea primero el proyecto Flutter de NuvClip." >&2
  exit 1
fi

for TOOL in "$ADB" "$AAPT" "$FLUTTER"; do
  if [[ ! -x "$TOOL" ]]; then
    echo "No se encontro o no se puede ejecutar: $TOOL" >&2
    echo "Actualiza ADB, AAPT o FLUTTER al inicio de tools/deploy.sh si tu ruta es distinta." >&2
    exit 1
  fi
done

if [[ -n "$DEVICE" ]]; then
  "$ADB" connect "$DEVICE" >/dev/null || true
fi

if [[ -z "$DEVICE" ]]; then
  DEVICE="$($ADB devices | awk '$2 == "device" { print $1; exit }')"
fi

if [[ -z "$DEVICE" ]]; then
  echo "No hay un dispositivo ADB conectado. Indica ip:puerto o activa la depuracion inalambrica." >&2
  exit 2
fi

cd "$ROOT"
echo "==> Compilando APK release de $APP_NAME"
"$FLUTTER" build apk --release

PUBSPEC_VERSION="$(awk '/^version:/ { print $2; exit }' pubspec.yaml)"
if [[ -z "$PUBSPEC_VERSION" ]]; then
  echo "No se encontro version en pubspec.yaml. Define algo como: version: 1.0.1+2" >&2
  exit 5
fi
VERSION_NAME="${PUBSPEC_VERSION%%+*}"
BUILD_NUMBER="${PUBSPEC_VERSION#*+}"
if [[ "$BUILD_NUMBER" == "$PUBSPEC_VERSION" || -z "$BUILD_NUMBER" ]]; then
  echo "La version debe incluir versionCode, por ejemplo: version: ${VERSION_NAME}+2" >&2
  exit 5
fi
FILE_VERSION="${VERSION_NAME}-b${BUILD_NUMBER}"

SOURCE_APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
RELEASE_APK="$ROOT/${APP_NAME}-v${FILE_VERSION}.apk"
# OJO: la carpeta real en el telefono lleva apostrofo, "APK'S", no "APKS".
PHONE_DIR="/sdcard/APK'S - DESARROLLOS"
PHONE_DEST="$PHONE_DIR/${APP_NAME}-v${FILE_VERSION}.apk"

if [[ ! -f "$SOURCE_APK" ]]; then
  echo "No se encontro la APK release generada en $SOURCE_APK." >&2
  exit 3
fi

cp -f "$SOURCE_APK" "$RELEASE_APK"

if ! "$AAPT" dump badging "$RELEASE_APK" | grep -q "package: name='$PACKAGE_NAME'"; then
  echo "La compilacion no corresponde al paquete esperado $PACKAGE_NAME." >&2
  echo "Actualiza PACKAGE_NAME en tools/deploy.sh si el applicationId final es otro." >&2
  exit 4
fi

echo "==> Instalando $APP_NAME $VERSION_NAME+$BUILD_NUMBER en $DEVICE"
# En algunos telefonos Xiaomi/POCO/HyperOS, instalar sin usuario puede fallar
# con INSTALL_FAILED_USER_RESTRICTED. Instalar en el usuario 0 suele evitar ese
# bloqueo sin depender de la opcion "Instalar via USB".
"$ADB" -s "$DEVICE" install -r --user 0 "$RELEASE_APK"

# Git Bash puede reescribir rutas tipo /sdcard/... como rutas de Windows antes
# de pasarlas a adb.exe. MSYS_NO_PATHCONV=1 evita esa conversion para rutas del
# telefono. La APK local se transforma con cygpath para que adb.exe la entienda.
HOST_APK="$(cygpath -m "$RELEASE_APK")"
PHONE_BACKUP_DIR="$PHONE_DIR/respaldo"
export MSYS_NO_PATHCONV=1

# La carpeta lleva un apostrofo en el nombre ("APK'S"), asi que no se puede
# envolver en comillas simples: cada orden va como una sola cadena con la ruta
# entre comillas dobles, y se ejecuta con sh -c del lado del telefono. adb push
# en cambio toma la ruta literal porque no pasa por ningun interprete.
if "$ADB" -s "$DEVICE" shell "test -f \"$PHONE_DEST\""; then
  BACKUP_NAME="$(basename "$PHONE_DEST" .apk)-$(date +%Y%m%d-%H%M%S).apk"
  echo "==> Respaldando la APK anterior del telefono: $BACKUP_NAME"
  "$ADB" -s "$DEVICE" shell "mkdir -p \"$PHONE_BACKUP_DIR\""
  "$ADB" -s "$DEVICE" shell "mv \"$PHONE_DEST\" \"$PHONE_BACKUP_DIR/$BACKUP_NAME\""
fi

echo "==> Copiando la APK al telefono"
"$ADB" -s "$DEVICE" shell "mkdir -p \"$PHONE_DIR\""
"$ADB" -s "$DEVICE" push "$HOST_APK" "$PHONE_DEST"

echo "==> Verificando version instalada"
"$ADB" -s "$DEVICE" shell dumpsys package "$PACKAGE_NAME" | grep -E 'versionCode=|versionName='
echo "==> Despliegue completado: $RELEASE_APK"
