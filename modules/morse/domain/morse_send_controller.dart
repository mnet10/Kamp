import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../flashlight/domain/flashlight_service.dart';
import '../domain/morse_service.dart';

/// Controller to manage background Morse send tasks.
class MorseSendController {
  final FlashlightService flashService;
  final MorseService morseService;

  String? _currentTaskId;
  bool _cancelRequested = false;
  StreamController<double>? _progressController;

  MorseSendController({required this.flashService, required this.morseService});

  Stream<double>? get progressStream => _progressController?.stream;

  String startSending(String text) {
    if (_currentTaskId != null) throw Exception('A task is already running');
    _currentTaskId = DateTime.now().millisecondsSinceEpoch.toString();
    _cancelRequested = false;
    _progressController = StreamController<double>();

    // Offload timing calculation to compute (isolate)
    compute(_prepareTimings, {'text': text, 'dot': morseService.dotDuration, 'dash': morseService.dashDuration, 'intra': morseService.intraCharGap, 'inter': morseService.interCharGap, 'word': morseService.interWordGap}).then((List<int> timings) async {
      final total = timings.fold<int>(0, (p, e) => p + e);
      int elapsed = 0;
      bool currentlyOn = false;

      for (int i = 0; i < timings.length; i++) {
        if (_cancelRequested) break;
        final duration = timings[i];
        if (!currentlyOn) {
          try {
            await flashService.turnOn();
            currentlyOn = true;
          } catch (e) {
            // ignore
          }
          await Future.delayed(Duration(milliseconds: duration));
        } else {
          try {
            await flashService.turnOff();
            currentlyOn = false;
          } catch (e) {
            // ignore
          }
          await Future.delayed(Duration(milliseconds: duration));
        }
        elapsed += duration;
        _progressController?.add(elapsed / total);
      }

      // ensure off
      try {
        await flashService.turnOff();
      } catch (e) {}

      _progressController?.close();
      _currentTaskId = null;
    });

    return _currentTaskId!;
  }

  void cancel() {
    _cancelRequested = true;
  }
}

// This function runs in an isolate via compute
List<int> _prepareTimings(Map<String, dynamic> payload) {
  final text = payload['text'] as String;
  final dot = payload['dot'] as int;
  final dash = payload['dash'] as int;
  final intra = payload['intra'] as int;
  final inter = payload['inter'] as int;
  final word = payload['word'] as int;

  // We'll reuse MorseService's logic but reimplement minimal mapping here to avoid
  // sending closures across isolate boundary.
  const Map<String, String> charToMorse = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---', '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..', '9': '----.',
  };

  final normalized = text.toUpperCase();
  final timings = <int>[];
  final words = normalized.split(' ');
  for (int w = 0; w < words.length; w++) {
    final letters = words[w].split('');
    for (int l = 0; l < letters.length; l++) {
      final symbol = charToMorse[letters[l]];
      if (symbol == null) continue;
      for (int s = 0; s < symbol.length; s++) {
        final ch = symbol[s];
        if (ch == '.') timings.add(dot);
        else if (ch == '-') timings.add(dash);
        if (s < symbol.length - 1) timings.add(intra);
      }
      if (l < letters.length - 1) timings.add(inter);
    }
    if (w < words.length - 1) timings.add(word);
  }
  return timings;
}
