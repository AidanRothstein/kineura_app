import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> {
  List<BluetoothDevice> connectedDevices = [];
  List<BluetoothDevice> previouslyConnectedDevices = [];
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
  }

  Future<void> _loadConnectedDevices() async {
    final allConnected = await FlutterBluePlus.connectedSystemDevices;
    setState(() {
      connectedDevices = allConnected;
    });
  }

  void _showBluetoothDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Bluetooth Devices'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    if (isScanning)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 12),
                            Text("Scanning for devices..."),
                          ],
                        ),
                      ),
                    Expanded(
                      child: _scanResults.isEmpty
                          ? const Center(child: Text('No devices found'))
                          : ListView.builder(
                              itemCount: _scanResults.length,
                              itemBuilder: (context, index) {
                                final device = _scanResults[index].device;
                                final name = device.platformName.isNotEmpty
                                    ? device.platformName
                                    : '(unknown)';
                                return ListTile(
                                  title: Text(name),
                                  subtitle: Text(device.remoteId.str),
                                  trailing: Text('${_scanResults[index].rssi} dBm'),
                                  onTap: () => _connectToDevice(device),
                                );
                              },
                            ),
                    ),
                    ElevatedButton(
                      onPressed: isScanning
                          ? null
                          : () => _startDeviceScan(setStateDialog),
                      child: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FlutterBluePlus.stopScan();
                    setStateDialog(() => isScanning = false);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _startDeviceScan(void Function(void Function()) setStateDialog) async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();

    if (!await Permission.bluetoothScan.isGranted ||
        !await Permission.bluetoothConnect.isGranted ||
        !await Permission.locationWhenInUse.isGranted) {
      print("❌ Missing required permissions.");
      return;
    }

    setStateDialog(() {
      _scanResults.clear();
      isScanning = true;
    });

    await _scanSub?.cancel();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final unique = <String, ScanResult>{};
      for (var r in results) {
        unique[r.device.remoteId.str] = r;
      }

      setStateDialog(() => _scanResults = unique.values.toList());
    });

    Future.delayed(const Duration(seconds: 10), () async {
      await FlutterBluePlus.stopScan();
      setStateDialog(() => isScanning = false);
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan();
      await device.connect(timeout: const Duration(seconds: 10));
      setState(() {
        connectedDevices.add(device);
        previouslyConnectedDevices.removeWhere((d) => d.remoteId == device.remoteId);
      });
    } catch (e) {
      print("Connection failed: $e");
    }
  }

  Future<void> _disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      setState(() {
        connectedDevices.removeWhere((d) => d.remoteId == device.remoteId);
        previouslyConnectedDevices.add(device);
      });
    } catch (e) {
      print("Disconnection failed: $e");
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devices Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connected Devices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (connectedDevices.isEmpty)
              const Text('No devices connected.')
            else
              Column(
                children: connectedDevices.map((device) {
                  return ListTile(
                    title: Text(device.platformName.isNotEmpty ? device.platformName : '(unknown)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 12),
                        const SizedBox(width: 6),
                        const Text('Connected'),
                        IconButton(
                          icon: const Icon(Icons.link_off),
                          tooltip: 'Disconnect',
                          onPressed: () => _disconnectFromDevice(device),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            const Text('Previously Connected Devices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (previouslyConnectedDevices.isEmpty)
              const Text('No previous devices.')
            else
              Column(
                children: previouslyConnectedDevices.map((device) {
                  return ListTile(
                    title: Text(device.platformName.isNotEmpty ? device.platformName : '(unknown)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.circle, color: Colors.grey, size: 12),
                        SizedBox(width: 6),
                        Text('Not Connected'),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBluetoothDevicesDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
