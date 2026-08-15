import 'package:flutter_test/flutter_test.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';
import 'package:nuvclip/core/platform/url_helper.dart';

void main() {
  group('detectPlatform', () {
    test('reconoce enlaces de TikTok, incluidas las variantes cortas', () {
      expect(detectPlatform('https://www.tiktok.com/@user/video/123'), SourcePlatform.tiktok);
      expect(detectPlatform('https://vm.tiktok.com/ZMabc123/'), SourcePlatform.tiktok);
      expect(detectPlatform('https://vt.tiktok.com/ZMabc123/'), SourcePlatform.tiktok);
    });

    test('reconoce enlaces de Instagram', () {
      expect(detectPlatform('https://www.instagram.com/reel/abc123/'), SourcePlatform.instagram);
      expect(detectPlatform('https://instagram.com/p/abc123/'), SourcePlatform.instagram);
    });

    test('reconoce enlaces de Facebook, incluidos los cortos de fb.watch', () {
      expect(detectPlatform('https://www.facebook.com/watch/?v=123456'), SourcePlatform.facebook);
      expect(detectPlatform('https://facebook.com/user/videos/123456'), SourcePlatform.facebook);
      expect(detectPlatform('https://m.facebook.com/story.php?story_fbid=1'), SourcePlatform.facebook);
      expect(detectPlatform('https://fb.watch/abc123/'), SourcePlatform.facebook);
    });

    test('reconoce enlaces de YouTube, incluidos los cortos de youtu.be', () {
      expect(detectPlatform('https://www.youtube.com/watch?v=abc123'), SourcePlatform.youtube);
      expect(detectPlatform('https://youtube.com/shorts/abc123'), SourcePlatform.youtube);
      expect(detectPlatform('https://m.youtube.com/watch?v=abc123'), SourcePlatform.youtube);
      expect(detectPlatform('https://youtu.be/abc123'), SourcePlatform.youtube);
    });

    test('un dominio ajeno no se marca como compatible', () {
      expect(detectPlatform('https://www.twitter.com/x/status/abc'), SourcePlatform.unknown);
    });

    test('texto vacio o invalido no revienta', () {
      expect(detectPlatform(''), SourcePlatform.unknown);
      expect(detectPlatform('no es un enlace'), SourcePlatform.unknown);
    });
  });

  group('platformLabel', () {
    test('devuelve el nombre visible de cada plataforma', () {
      expect(platformLabel(SourcePlatform.tiktok), 'TikTok');
      expect(platformLabel(SourcePlatform.instagram), 'Instagram');
      expect(platformLabel(SourcePlatform.facebook), 'Facebook');
      expect(platformLabel(SourcePlatform.youtube), 'YouTube');
    });
  });

  group('looksLikeUrl', () {
    test('acepta http y https', () {
      expect(looksLikeUrl('https://tiktok.com/x'), isTrue);
      expect(looksLikeUrl('http://tiktok.com/x'), isTrue);
    });

    test('rechaza texto que no es una URL', () {
      expect(looksLikeUrl('hola mundo'), isFalse);
    });
  });
}
