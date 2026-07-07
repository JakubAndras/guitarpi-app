import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothServer {

  static BluetoothDevice? server;

  BluetoothDevice? getServer() {
    return server;
  }

  void setServer(BluetoothDevice? device) {
    server = device;
  }
}