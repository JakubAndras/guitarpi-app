import '../../domain/repositories/effect_transport.dart';

/// No-op [EffectTransport] for platforms where Bluetooth Classic is not
/// available (e.g. iOS). Every operation is a safe no-op.
class UnsupportedTransport implements EffectTransport {
  @override
  bool get isSupported => false;

  @override
  bool get isConnected => false;

  @override
  Future<bool> connect(String address) async => false;

  @override
  Future<void> disconnect() async {}

  @override
  void send(Map<String, dynamic> wireJson) {}
}
