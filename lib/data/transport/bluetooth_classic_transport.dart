import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../domain/repositories/effect_transport.dart';

/// Android implementation of [EffectTransport] over Bluetooth Classic (SPP)
/// using `flutter_bluetooth_serial`.
class BluetoothClassicTransport implements EffectTransport {
  BluetoothConnection? _connection;

  @override
  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isConnected => _connection?.isConnected ?? false;

  @override
  Future<bool> connect(String address) async {
    if (!isSupported) return false;
    try {
      _connection = await BluetoothConnection.toAddress(address);
      return _connection?.isConnected ?? false;
    } catch (e) {
      debugPrint('BluetoothClassicTransport.connect failed: $e');
      _connection = null;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (e) {
      debugPrint('BluetoothClassicTransport.disconnect failed: $e');
    } finally {
      _connection = null;
    }
  }

  @override
  void send(Map<String, dynamic> wireJson) {
    try {
      final connection = _connection;
      if (connection == null || !connection.isConnected) return;
      connection.output.add(utf8.encode(jsonEncode(wireJson)));
    } catch (e) {
      // Fire-and-forget: never throw.
      debugPrint('BluetoothClassicTransport.send failed: $e');
    }
  }
}
