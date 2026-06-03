import 'package:flutter_test/flutter_test.dart';
import 'package:kamp/modules/morse/domain/morse_service.dart';

void main() {
  group('Morse timings', () {
    final svc = MorseService(dotDuration: 100);

    test('timings for SOS', () {
      final timings = svc.morseToTimings('... --- ...');
      expect(timings.isNotEmpty, true);
    });
  });
}
