import 'package:flutter_test/flutter_test.dart';
import 'package:kamp/modules/sos/domain/sos_auto_service.dart';
import 'package:kamp/modules/sos/domain/sos_service.dart';
import 'package:kamp/modules/morse/domain/morse_send_controller.dart';

// This is a very small smoke test that ensures SosAutoService can be instantiated.
void main() {
  test('SosAutoService instantiates', () {
    final sos = SosService.test();
    final morse = MorseSendController(flashService: TestFlash(), morseService: TestMorse());
    final auto = SosAutoService(sosService: sos, morseController: morse, enabled: false);
    expect(auto, isNotNull);
  });
}
