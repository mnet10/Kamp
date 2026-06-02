import 'package:flutter_test/flutter_test.dart';
import 'package:kamp/modules/morse/domain/morse_service.dart';

void main() {
  group('MorseService encode/decode', () {
    final svc = MorseService(dotDuration: 100);

    test('encodes simple text', () {
      final morse = svc.encode('SOS');
      expect(morse.replaceAll(' ', ''), '...---...');
    });

    test('decodes simple morse', () {
      final text = svc.decode('... --- ...');
      expect(text, 'SOS');
    });

    test('timings generation returns non-empty list', () {
      final timings = svc.morseToTimings('... --- ...');
      expect(timings.isNotEmpty, true);
    });
  });
}
