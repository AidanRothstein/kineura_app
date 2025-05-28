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
  List<BluetoothDevice> _connectedDevices = [];
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
  }

  Future<void> _loadConnectedDevices() async {
    final devices = await FlutterBluePlus.connectedSystemDevices;
    setState(() => _connectedDevices = devices);
  }

  void _showBluetoothDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                onPressed: isScanning ? null : _startDeviceScan,
                child: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FlutterBluePlus.stopScan();
              setState(() => isScanning = false);
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDeviceScan() async {
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

    setState(() {
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

      setState(() => _scanResults = unique.values.toList());
    });

    Future.delayed(const Duration(seconds: 10), () async {
      await FlutterBluePlus.stopScan();
      setState(() => isScanning = false);
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan();

      var connectedDevices = await FlutterBluePlus.connectedSystemDevices;
      if (!connectedDevices.any((d) => d.remoteId == device.remoteId)) {
        await device.connect(timeout: const Duration(seconds: 10));
      }

      await _loadConnectedDevices();

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Connected to ${device.platformName}"),
            content: const Text("BLE connection successful."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Connection failed: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Connection Error"),
            content: Text("Failed to connect: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
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
        title: const Text("My Devices Screen"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _connectedDevices.isEmpty
          ? const Center(child: Text('No devices connected.'))
          : ListView.builder(
              itemCount: _connectedDevices.length,
              itemBuilder: (context, index) {
                final device = _connectedDevices[index];
                final name = device.platformName.isNotEmpty
                    ? device.platformName
                    : '(unknown)';
                return ListTile(
                  title: Text(name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      SizedBox(width: 6),
                      Text('Connected', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Tooltip(
        message: 'Manage Bluetooth Devices',
        child: FloatingActionButton(
          onPressed: () => _showBluetoothDevicesDialog(context),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
