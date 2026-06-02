import 'dart:async';

import 'package:flutter/material.dart';
import '../../domain/flashlight_service.dart';

class FlashlightPage extends StatefulWidget {
  final FlashlightService? service;

  const FlashlightPage({Key? key, this.service}) : super(key: key);

  @override
  State<FlashlightPage> createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage> {
  late final FlashlightService _service;
  bool _isOn = false;
  bool _isSos = false;
  Timer? _sosTimer;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? FlashlightService();
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    if (_isOn) {
      _service.turnOff();
    }
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_isOn) {
      await _service.turnOff();
      setState(() => _isOn = false);
    } else {
      await _service.turnOn();
      setState(() => _isOn = true);
    }
  }

  void _startSos() {
    if (_isSos) return;
    _isSos = true;
    // Simple blink pattern for SOS
    const pattern = [300, 300, 300, 900, 900, 900, 300, 300, 300];
    int index = 0;
    _sosTimer = Timer.periodic(const Duration(milliseconds: 300), (t) async {
      final duration = pattern[index % pattern.length];
      if ((_isOn)) {
        await _service.turnOff();
        setState(() => _isOn = false);
      } else {
        await _service.turnOn();
        setState(() => _isOn = true);
      }
      index++;
    });
    setState(() {});
  }

  void _stopSos() {
    _sosTimer?.cancel();
    _isSos = false;
    _service.turnOff();
    setState(() => _isOn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Fener'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on,
              size: 96,
              color: _isOn ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _toggleFlash,
              child: Text(_isOn ? 'Kapat' : 'Aç'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: _isOn ? Colors.redAccent : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSos ? _stopSos : _startSos,
              child: Text(_isSos ? 'SOS Durdur' : 'SOS Başlat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                backgroundColor: _isSos ? Colors.grey : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SOS modu telefonun flaşını düzenli aralıklarla yakıp söndürerek basit bir SOS sinyali üretir. Cihazınızın flaşına erişim izni gereklidir.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
