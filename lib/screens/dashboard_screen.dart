import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSub;

  void _showBluetoothDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Devices'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
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
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: () => _startDeviceScan(),
                child: const Text('Scan for Devices'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDeviceScan() async {
    // Request permissions
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();

    // Clear previous results
    setState(() => _scanResults.clear());

    // Start scan
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      continuousUpdates: true,
    );

    // Cancel previous subscription if any
    await _scanSub?.cancel();

    // Listen to scan results
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      // Remove duplicates by device id
      final unique = <String, ScanResult>{};
      for (var r in results) {
        unique[r.device.remoteId.str] = r;
      }
      setState(() => _scanResults = unique.values.toList());
    });
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
              _navButton(
                icon: Icons.school,
                label: 'Learn',
                onTap: () {},
              ),
              _navButton(
                icon: Icons.history,
                label: 'Past Workouts',
                onTap: () {},
              ),
              const SizedBox(width: 48),
              _navButton(
                icon: Icons.devices,
                label: 'My Devices',
                onTap: () {},
              ),
              _navButton(
                icon: Icons.person,
                label: 'Profile',
                onTap: () {},
              ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
