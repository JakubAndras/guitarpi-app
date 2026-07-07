import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// `flutter_bluetooth_serial` only implements Android (Bluetooth Classic / SPP).
/// On any other platform the plugin isn't registered, so every call throws a
/// `MissingPluginException`. Guard all Bluetooth access with this flag.
bool get isBluetoothSupported => defaultTargetPlatform == TargetPlatform.android;

/// Shows a one-line notice that Bluetooth isn't available on this platform.
void showBluetoothUnsupported(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Bluetooth is only supported on Android.'),
    ),
  );
}
