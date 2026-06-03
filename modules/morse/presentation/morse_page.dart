import 'package:flutter/material.dart';
import '../../morse/domain/morse_service.dart';
import '../../flashlight/domain/flashlight_service.dart';
import '../../morse/domain/morse_send_controller.dart';

class MorsePage extends StatefulWidget {
  final MorseService? morseService;
  final FlashlightService? flashlightService;

  const MorsePage({Key? key, this.morseService, this.flashlightService}) : super(key: key);

  @override
  State<MorsePage> createState() => _MorsePageState();
}

class _MorsePageState extends State<MorsePage> {
  late final MorseService _morseService;
  late final FlashlightService _flashService;
  late final MorseSendController _controller;
  final _controllerText = TextEditingController();
  double _progress = 0.0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _morseService = widget.morseService ?? MorseService();
    _flashService = widget.flashlightService ?? FlashlightService();
    _controller = MorseSendController(flashService: _flashService, morseService: _morseService);
  }

  @override
  void dispose() {
    _controllerText.dispose();
    super.dispose();
  }

  void _startSend() {
    final text = _controllerText.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _sending = true;
      _progress = 0.0;
    });
    final taskId = _controller.startSending(text);
    _controller.progressStream?.listen((p) {
      setState(() => _progress = p);
    }, onDone: () {
      setState(() => _sending = false);
    });
  }

  void _cancelSend() {
    _controller.cancel();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mors Sinyali')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _controllerText, decoration: const InputDecoration(labelText: 'Gönderilecek metin')),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _sending ? _progress : null),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: _sending ? null : _startSend, child: const Text('Fener ile Gönder')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _sending ? _cancelSend : null, child: const Text('İptal')),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Not: Uzun mesajlarda gönderim arka planda çalışır ve iptal edilebilir.'),
          ],
        ),
      ),
    );
  }
}
