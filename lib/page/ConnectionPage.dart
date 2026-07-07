import 'dart:async';

import 'package:bc_ui_flutter/model/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:wakelock/wakelock.dart';

import '../widget/CustomPageBackground.dart';
import '../model/BluetoothServer.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';

class ConnectionPage extends StatefulWidget {
  final Function switchToMainPage;

  ConnectionPage({required this.switchToMainPage});

  @override
  _ConnectionPage createState() => _ConnectionPage();
}

class _ConnectionPage extends State<ConnectionPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  bool displayStaysAwake = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection & Settings',  style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const CustomPageBackground(),
          ListView(
            children: <Widget>[
              const Divider(),
              const ListTile(title: Text('General')),
              SwitchListTile(
                title: const Text('Display stays awake'),
                value: displayStaysAwake,
                activeColor: AppColors.mainColor,
                onChanged: (bool value) async {
                  setState(() {
                    displayStaysAwake = value;
                    if (displayStaysAwake) {
                      Wakelock.enable();
                    }
                    else {
                      Wakelock.disable();
                    }
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Enable Bluetooth'),
                value: _bluetoothState.isEnabled,
                activeColor: AppColors.mainColor,
                onChanged: (bool value) {
                  // Do the request and update with the true value then
                  future() async {
                    // async lambda seems to not working
                    if (value)
                      await FlutterBluetoothSerial.instance.requestEnable();
                    else
                      await FlutterBluetoothSerial.instance.requestDisable();
                  }

                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
              ListTile(
                title: const Text('Bluetooth status'),
                subtitle: Text(_bluetoothState.toString()),
                trailing: ElevatedButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    FlutterBluetoothSerial.instance.openSettings();
                  },
                ),
              ),
              const Divider(
                thickness: 1.5,
              ),
              const ListTile(title: Text('Devices discovery and connection')),
              ListTile(
                title: ElevatedButton(
                    child: const Text('Explore discovered devices'),
                    onPressed: () async {
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DiscoveryPage();
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        print(
                            'Discovery -> selected ' + selectedDevice.address);
                      } else {
                        print('Discovery -> no device selected');
                      }
                    }),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('Connect to your Raspberry Pi'),
                  onPressed: () async {
                    BluetoothServer.server = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (BluetoothServer.server != null) {
                      print('Connect -> selected ' + BluetoothServer.server!.address);
                      _start(context, BluetoothServer.server!);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _start(BuildContext context, BluetoothDevice server) {
    widget.switchToMainPage();
  }
}
