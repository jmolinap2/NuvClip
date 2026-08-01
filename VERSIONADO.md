# Versionado de la app

Cada avance que se instale en el celular debe cambiar la version de la app.
Esto evita confusiones como no saber si el telefono tiene la ultima build o una
APK anterior con el mismo nombre.

## Donde se cambia la version

En Flutter la version se define en `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

El valor tiene dos partes:

```text
1.0.0+1
|     |
|     versionCode Android
versionName visible
```

- `1.0.0` es el `versionName`: la version visible para humanos.
- `+1` es el `versionCode`: numero interno de Android. Debe subir siempre.

## Regla practica

Para cada avance probado o instalado en el celular:

1. Subir siempre el numero despues de `+`.
2. Subir tambien el numero visible cuando el cambio sea relevante.
3. Ejecutar deploy despues de cambiar la version.

Ejemplos:

```yaml
version: 1.0.0+1
version: 1.0.1+2
version: 1.0.2+3
```

Para avances pequenos de desarrollo tambien se puede usar:

```yaml
version: 1.0.0+2
version: 1.0.0+3
```

pero el `+numero` debe subir igual.

## Como lo usa el deploy

`tools/deploy.sh` lee la version desde `pubspec.yaml` y genera una APK con ese
nombre:

```text
NuvClip-v1.0.1-b2.apk
```

Android instala internamente el `versionCode`. Por eso, si solo cambia el codigo
pero no cambia `version:`, es facil perder trazabilidad.

## Checklist antes de deploy

Antes de ejecutar:

```bash
tools/deploy.sh 192.168.1.108:38723
```

verifica:

- `pubspec.yaml` tiene una version nueva.
- El numero despues de `+` subio respecto al ultimo deploy.
- El APK generado tendra un nombre distinto porque incluye `versionName` y
  `versionCode`.

## Recomendacion

Para no confundirse con archivos, en cada avance normal conviene subir ambos:

```yaml
version: 1.0.1+2
```

Asi el celular, Android y el archivo APK quedan alineados.
