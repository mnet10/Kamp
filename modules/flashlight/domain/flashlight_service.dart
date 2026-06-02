import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightService {
  Future<void> turnOn() async {
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      // Rethrow as generic exception for now
      throw Exception('Could not enable torch: $e');
    }
  }

  Future<void> turnOff() async {
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      throw Exception('Could not disable torch: $e');
    }
  }

  Future<bool> hasTorch() async {
    try {
      return await TorchLight.isTorchAvailable();
    } catch (e) {
      return false;
    }
  }
}
