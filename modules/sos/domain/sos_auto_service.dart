import 'dart:async';

import '../../morse/domain/morse_send_controller.dart';
import '../../sos/domain/sos_service.dart';

/// SosAutoService - listens for SOS events and optionally triggers flashlight/Morse sending.
class SosAutoService {
  final SosService sosService;
  final MorseSendController morseController;
  bool enabled;

  StreamSubscription<SosEvent>? _sub;

  SosAutoService({required this.sosService, required this.morseController, this.enabled = false});

  void start() {
    _sub = sosService.events.listen((evt) {
      if (!enabled) return;
      if (evt.type == SosEventType.triggered) {
        // Send location/message via Morse using existing controller
        final message = evt.message ?? 'SOS';
        try {
          morseController.startSending(message);
        } catch (e) {
          // ignore if already running
        }
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    stop();
  }
}
