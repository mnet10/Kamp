import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../flashlight/domain/flashlight_service.dart';
import 'package:uuid/uuid.dart';
import 'morse_model.dart';
import ' _morse_maps.dart';

/// MorseService provides encoding/decoding utilities and a simple
/// mechanism to send Morse messages via a flashlight service.
class MorseService {
  final int dotDuration; // milliseconds
  final int dashDuration; // milliseconds
  final int intraCharGap; // gap between parts of same letter
  final int interCharGap; // gap between letters
  final int interWordGap; // gap between words

  MorseService({
    this.dotDuration = 200,
    int? dashDuration,
    this.intraCharGap = 200,
    this.interCharGap = 600,
    this.interWordGap = 1400,
  }) : dashDuration = dashDuration ?? (dotDuration * 3);

  /// Encode plain text to morse string using '/' as word separator.
  String encode(String input) {
    final sb = StringBuffer();
    final normalized = input.toUpperCase();
    for (int i = 0; i < normalized.length; i++) {
      final ch = normalized[i];
      final code = _charToMorse[ch];
      if (code != null) {
        if (sb.isNotEmpty) sb.write(' ');
        sb.write(code);
      } else {
        // ignore unknown chars
      }
    }
    return sb.toString();
  }

  /// Decode morse string to text. Assumes letters separated by spaces and words by '/'.
  String decode(String morse) {
    final parts = morse.trim().split(' ');
    final sb = StringBuffer();
    for (var p in parts) {
      if (p == '/') {
        sb.write(' ');
      } else {
        final ch = _morseToChar[p];
        if (ch != null) sb.write(ch);
      }
    }
    return sb.toString();
  }

  /// Convert morse string into a sequence of on/off durations (milliseconds).
  /// Returns list of durations where even indices are ON durations and odd indices are OFF durations.
  List<int> morseToTimings(String morse) {
    final timings = <int>[];
    final words = morse.split('/');
    for (int w = 0; w < words.length; w++) {
      final letters = words[w].trim().split(' ');
      for (int l = 0; l < letters.length; l++) {
        final symbol = letters[l];
        for (int s = 0; s < symbol.length; s++) {
          final ch = symbol[s];
          if (ch == '.') {
            timings.add(dotDuration); // ON
          } else if (ch == '-') {
            timings.add(dashDuration);
          }
          // intra-character gap (off) after each dot/dash except last
          if (s < symbol.length - 1) timings.add(intraCharGap);
        }
        // after each letter, add interCharGap (off) except last letter
        if (l < letters.length - 1) timings.add(interCharGap);
      }
      // after each word, add interWordGap (off) except last word
      if (w < words.length - 1) timings.add(interWordGap);
    }
    return timings;
  }

  /// Create a MorseMessage model for storage or sending.
  MorseMessage createMessage(String text, {String? id}) {
    final code = encode(text);
    return MorseMessage(
      id: id ?? const Uuid().v4(),
      text: text,
      morseCode: code,
      timestamp: DateTime.now(),
      channel: MorseChannel.flash,
    );
  }

  /// Send morse via flashlight using provided [flashService].
  /// This is a simple blocking implementation: it toggles the torch
  /// according to timings. Callers should run this in a separate isolate
  /// or ensure they handle long-running operations.
  Future<void> sendViaFlash(FlashlightService flashService, String text,
      {bool cancelIfFlashNotAvailable = true}) async {
    final morse = encode(text);
    final timings = morseToTimings(morse);

    final hasTorch = await flashService.hasTorch();
    if (!hasTorch) {
      if (cancelIfFlashNotAvailable) return;
    }

    // The timings list is ON, OFF, ON, OFF ... but our algorithm currently only emits ON durations
    // and expects us to wait OFF durations in between. We'll iterate and toggle accordingly.
    bool currentlyOn = false;
    for (int i = 0; i < timings.length; i++) {
      final duration = timings[i];
      // If currently off, turn on for duration, else turn off and wait duration.
      if (!currentlyOn) {
        try {
          await flashService.turnOn();
          currentlyOn = true;
        } catch (e) {
          debugPrint('Failed to turn flashlight on: $e');
        }
        await Future.delayed(Duration(milliseconds: duration));
      } else {
        try {
          await flashService.turnOff();
          currentlyOn = false;
        } catch (e) {
          debugPrint('Failed to turn flashlight off: $e');
        }
        await Future.delayed(Duration(milliseconds: duration));
      }
    }

    // ensure off at end
    if (currentlyOn) await flashService.turnOff();
  }
}
