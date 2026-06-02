enum MorseChannel { flash, audio }

class MorseMessage {
  final String id;
  final String text;
  final String morseCode;
  final DateTime timestamp;
  final MorseChannel channel;

  MorseMessage({
    required this.id,
    required this.text,
    required this.morseCode,
    required this.timestamp,
    this.channel = MorseChannel.flash,
  });
}
