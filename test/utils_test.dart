import 'package:flutter_test/flutter_test.dart';
import 'package:nuvclip/core/utils/byte_format.dart';
import 'package:nuvclip/core/utils/duration_format.dart';
import 'package:nuvclip/core/utils/filename_sanitizer.dart';

void main() {
  group('formatBytes', () {
    test('menor a 1 KB se muestra en bytes enteros', () {
      expect(formatBytes(512), '512 B');
    });

    test('MB con un decimal, como en las referencias visuales', () {
      expect(formatBytes(19503677), '18.6 MB');
    });

    test('GB con un decimal', () {
      expect(formatBytes(3435973836), '3.2 GB');
    });

    test('cero o negativo no revienta', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(-5), '0 B');
    });
  });

  group('formatDuration', () {
    test('clip corto en mm:ss', () {
      expect(formatDuration(28), '00:28');
    });

    test('minutos de dos digitos', () {
      expect(formatDuration(872), '14:32');
    });

    test('una hora o mas agrega el componente de horas', () {
      expect(formatDuration(3600), '1:00:00');
    });

    test('negativo se trata como cero en vez de fallar', () {
      expect(formatDuration(-3), '00:00');
    });
  });

  group('sanitizeFileName', () {
    test('quita caracteres no validos en un nombre de archivo', () {
      expect(sanitizeFileName('Viaje: "increible" / 2024', extension: 'mp4'), 'Viaje increible 2024.mp4');
    });

    test('colapsa espacios repetidos y saltos de linea', () {
      expect(sanitizeFileName('Titulo   con\nvarias   lineas', extension: 'mp4'), 'Titulo con varias lineas.mp4');
    });

    test('titulo vacio cae en un nombre por defecto', () {
      expect(sanitizeFileName('   ', extension: 'mp4'), 'video.mp4');
    });

    test('titulos muy largos se recortan a 80 caracteres', () {
      final long = 'a' * 200;
      final result = sanitizeFileName(long, extension: 'mp4');
      expect(result, '${'a' * 80}.mp4');
    });
  });
}
