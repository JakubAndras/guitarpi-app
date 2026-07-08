import 'dart:async';

import 'package:bc_ui_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../utils/BluetoothSupport.dart';

import '../presentation/connection/connection_notifier.dart';
import '../widget/CustomPageBackground.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';

class ConnectionPage extends ConsumerStatefulWidget {
  final Function switchToMainPage;

  const ConnectionPage({super.key, required this.switchToMainPage});

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionPage();
}

class _ConnectionPage extends ConsumerState<ConnectionPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Timer? _discoverableTimeoutTimer;
  bool displayStaysAwake = false;

  @override
  void initState() {
    super.initState();

    if (!isBluetoothSupported) return;

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
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
    if (isBluetoothSupported) {
      FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    }
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
                activeThumbColor: AppColors.mainColor,
                onChanged: (bool value) async {
                  setState(() {
                    displayStaysAwake = value;
                    if (displayStaysAwake) {
                      WakelockPlus.enable();
                    }
                    else {
                      WakelockPlus.disable();
                    }
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Enable Bluetooth'),
                value: _bluetoothState.isEnabled,
                activeThumbColor: AppColors.mainColor,
                onChanged: (bool value) {
                  if (!isBluetoothSupported) {
                    showBluetoothUnsupported(context);
                    return;
                  }
                  // Do the request and update with the true value then
                  future() async {
                    // async lambda seems to not working
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
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
                    if (!isBluetoothSupported) {
                      showBluetoothUnsupported(context);
                      return;
                    }
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
                      if (!isBluetoothSupported) {
                        showBluetoothUnsupported(context);
                        return;
                      }
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DiscoveryPage();
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        debugPrint(
                            'Discovery -> selected ${selectedDevice.address}');
                      } else {
                        debugPrint('Discovery -> no device selected');
                      }
                    }),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('Connect to your Raspberry Pi'),
                  onPressed: () async {
                    if (!isBluetoothSupported) {
                      showBluetoothUnsupported(context);
                      return;
                    }
                    final BluetoothDevice? selected =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (!context.mounted) return;
                    if (selected != null) {
                      debugPrint('Connect -> selected ${selected.address}');
                      // Kick off the connection (fire-and-forget) and move to
                      // the pedalboard; ConnectionNotifier tracks the outcome.
                      ref
                          .read(connectionProvider.notifier)
                          .connect(selected.address);
                      _start(context, selected);
                    } else {
                      debugPrint('Connect -> no device selected');
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
