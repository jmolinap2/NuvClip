import 'package:flutter_test/flutter_test.dart';
import 'package:nuvclip/core/errors/error_messages.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';

void main() {
  test('cada DownloadErrorCode tiene un mensaje en espanol, sin texto tecnico vacio', () {
    for (final code in DownloadErrorCode.values) {
      final message = userMessageFor(code);
      expect(message, isNotEmpty, reason: 'Falta mensaje para $code');
      expect(message, isNot(contains('Exception')), reason: '$code no debe filtrar texto tecnico');
    }
  });
}
