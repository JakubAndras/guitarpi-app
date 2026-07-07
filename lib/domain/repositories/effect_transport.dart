/// Abstraction over the channel used to push pedalboard state to the Pi.
///
/// Implementations must guarantee that [send] never throws (fire-and-forget).
abstract class EffectTransport {
  /// Whether this transport can operate on the current platform.
  bool get isSupported;

  /// Connect to the device at [address]. Returns whether the connection
  /// succeeded.
  Future<bool> connect(String address);

  /// Tear down any active connection.
  Future<void> disconnect();

  /// Whether there is currently an open connection.
  bool get isConnected;

  /// Fire-and-forget send of the wire JSON. Must never throw.
  void send(Map<String, dynamic> wireJson);
}
