import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool isScanning = false;

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

    print("🚀 Starting BLE scan...");
    await _scanSub?.cancel();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      print("📡 Found ${results.length} devices:");
      for (var r in results) {
        print("🔍 ${r.device.platformName} - ${r.device.remoteId.str} (${r.rssi} dBm)");
      }

      final unique = <String, ScanResult>{};
      for (var r in results) {
        unique[r.device.remoteId.str] = r;
      }

      setState(() => _scanResults = unique.values.toList());
    });

    // Stop scan after timeout
    Future.delayed(const Duration(seconds: 10), () async {
      await FlutterBluePlus.stopScan();
      setState(() => isScanning = false);
      print("⏹️ Scan stopped");
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    print("▶️ Trying to connect to: ${device.platformName} [${device.remoteId.str}]");

    try {
      await FlutterBluePlus.stopScan();

      var connectedDevices = await FlutterBluePlus.connectedSystemDevices;
      if (connectedDevices.any((d) => d.remoteId == device.remoteId)) {
        print("🔁 Already connected to ${device.platformName}");
      } else {
        await device.connect(timeout: const Duration(seconds: 10));
        print("✅ Connected to ${device.platformName}");
      }

      final services = await device.discoverServices();
      for (var service in services) {
        print("🔧 Service: ${service.uuid}");
        for (var char in service.characteristics) {
          print("  - Characteristic: ${char.uuid}");
        }
      }

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
      body: const Center(
        child: Text(
          "You're in!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navButton(icon: Icons.school, label: 'Learn', onTap: () {}),
              _navButton(icon: Icons.history, label: 'Past Workouts', onTap: () {}),
              const SizedBox(width: 48),
              _navButton(icon: Icons.devices, label: 'My Devices', onTap: () {}),
              _navButton(icon: Icons.person, label: 'Profile', onTap: () {}),
            ],
          ),
        ),
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

  Widget _navButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
