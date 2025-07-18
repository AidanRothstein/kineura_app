import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> with WidgetsBindingObserver {
  List<BluetoothDevice> connectedDevices = [];
  List<BluetoothDevice> previouslyConnectedDevices = [];
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConnectedDevices();
    _loadPreviouslyConnectedDevices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDeviceStatus();
    }
  }

  Future<void> _refreshDeviceStatus() async {
    await _loadConnectedDevices();
    await _scanForPreviouslyConnectedDevices();
  }

  Future<void> _loadConnectedDevices() async {
    final allConnected = await FlutterBluePlus.connectedSystemDevices;
    setState(() {
      connectedDevices = allConnected;
    });
  }

  Future<void> _loadPreviouslyConnectedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceIds = prefs.getStringList('known_device_ids') ?? [];
    final devices = deviceIds.map((id) => BluetoothDevice(remoteId: DeviceIdentifier(id))).toList();
    setState(() {
      previouslyConnectedDevices = devices;
    });
    await _scanForPreviouslyConnectedDevices();
  }

  Future<void> _savePreviouslyConnectedDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceIds = prefs.getStringList('known_device_ids') ?? [];
    if (!deviceIds.contains(device.remoteId.str)) {
      deviceIds.add(device.remoteId.str);
      await prefs.setStringList('known_device_ids', deviceIds);
    }
  }

  Future<void> _scanForPreviouslyConnectedDevices() async {
    await Permission.bluetoothScan.request();
    if (!await Permission.bluetoothScan.isGranted) return;

    final unique = <String, ScanResult>{};
    final completer = Completer<void>();
    _scanResults.clear();

    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final name = r.device.platformName;
        if (name.contains("Kineura")) {
          unique[r.device.remoteId.str] = r;
        }
      }
      if (!completer.isCompleted && mounted) {
        setState(() => _scanResults = unique.values.toList());
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
    await Future.delayed(const Duration(seconds: 2));
    await FlutterBluePlus.stopScan();
    await completer.future;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan();
      await device.connect(timeout: const Duration(seconds: 10));
      await _savePreviouslyConnectedDevice(device);
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
        final alreadyListed = previouslyConnectedDevices.any((d) => d.remoteId == device.remoteId);
        if (!alreadyListed) {
          previouslyConnectedDevices.add(device);
        }
      });
      await _savePreviouslyConnectedDevice(device);
    } catch (e) {
      print("Disconnection failed: $e");
    }
  }

  Future<void> _clearAllDevices() async {
    for (BluetoothDevice device in connectedDevices) {
      try {
        await device.disconnect();
      } catch (e) {
        print("Failed to disconnect device \${device.remoteId}: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('known_device_ids');

    setState(() {
      connectedDevices.clear();
      previouslyConnectedDevices.clear();
    });
  }

  void _showClearDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: const TextStyle(color: Colors.white70),
        title: const Text('Clear all devices?'),
        content: const Text('This will remove and disconnect all saved devices.'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllDevices();
            },
          ),
        ],
      ),
    );
  }

  void _showBluetoothDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
              contentTextStyle: const TextStyle(color: Colors.white70),
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
                                final name = device.platformName.isNotEmpty ? device.platformName : '(unknown)';
                                return ListTile(
                                  title: Text(name, style: const TextStyle(color: Colors.white)),
                                  subtitle: Text(device.remoteId.str, style: const TextStyle(color: Colors.white70)),
                                  trailing: Text('${_scanResults[index].rssi} dBm', style: const TextStyle(color: Colors.white70)),
                                  onTap: () => _connectToDevice(device),
                                );
                              },
                            ),
                    ),
                    ElevatedButton(
                      onPressed: isScanning ? null : () => _scanForPreviouslyConnectedDevices(),
                      child: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FlutterBluePlus.stopScan();
                    if (mounted) setStateDialog(() => isScanning = false);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close', style: TextStyle(color: Colors.white70)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('My Devices Screen', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshDeviceStatus,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Connected Devices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                if (connectedDevices.isEmpty)
                  const Text('No devices connected.', style: TextStyle(color: Colors.white70))
                else
                  Column(
                    children: connectedDevices.map((device) {
                      return ListTile(
                        title: Text(device.platformName.isNotEmpty ? device.platformName : '(unknown)', style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 12),
                            const SizedBox(width: 6),
                            const Text('Connected', style: TextStyle(color: Colors.white70)),
                            IconButton(
                              icon: const Icon(Icons.link_off, color: Colors.white70),
                              tooltip: 'Disconnect',
                              onPressed: () => _disconnectFromDevice(device),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                const Text('Previously Connected Devices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                if (previouslyConnectedDevices.isEmpty)
                  const Text('No previous devices.', style: TextStyle(color: Colors.white70))
                else
                  Column(
                    children: previouslyConnectedDevices.where((device) =>
                      !connectedDevices.any((c) => c.remoteId == device.remoteId)
                    ).map((device) {
                      final isAvailable = _scanResults.any((r) => r.device.remoteId == device.remoteId);
                      return ListTile(
                        title: Text(device.platformName.isNotEmpty ? device.platformName : '(unknown)', style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: isAvailable ? Colors.orange : Colors.grey, size: 12),
                            const SizedBox(width: 6),
                            Text(isAvailable ? 'Available' : 'Offline', style: const TextStyle(color: Colors.white70)),
                            if (isAvailable)
                              IconButton(
                                icon: const Icon(Icons.link, color: Colors.white70),
                                tooltip: 'Reconnect',
                                onPressed: () => _connectToDevice(device),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 90,
            child: ElevatedButton.icon(
              onPressed: _showClearDevicesDialog,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Devices'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBluetoothDevicesDialog(context),
        backgroundColor: const Color(0xFF2979FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
