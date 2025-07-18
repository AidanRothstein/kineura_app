import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'menu_screens/learn_screen.dart';
import 'menu_screens/past_workouts_screen.dart';
import 'menu_screens/my_devices_screen.dart';
import 'menu_screens/profile_screen.dart';
import 'menu_screens/live_workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<BluetoothDevice> connectedDevices = [];
  Set<String> selectedDeviceIds = {};

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
  }

  Future<void> _loadConnectedDevices() async {
    final devices = await FlutterBluePlus.connectedSystemDevices;
    setState(() {
      connectedDevices = devices;
    });
  }

  void _showConnectedDevicesPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.black.withOpacity(0.8),
              title: const Text('Connected Devices', style: TextStyle(color: Colors.white, fontFamily: 'SourceSans3')),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: connectedDevices.isEmpty
                    ? const Center(child: Text('No connected devices', style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        itemCount: connectedDevices.length,
                        itemBuilder: (context, index) {
                          final device = connectedDevices[index];
                          final deviceId = device.remoteId.str;
                          final isSelected = selectedDeviceIds.contains(deviceId);
                          final name = device.platformName.isNotEmpty ? device.platformName : '(unknown)';

                          return ListTile(
                            title: Text(name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(deviceId, style: const TextStyle(color: Colors.white70)),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.radio_button_unchecked, color: Colors.white54),
                            onTap: () {
                              setStateDialog(() {
                                if (isSelected) {
                                  selectedDeviceIds.remove(deviceId);
                                } else {
                                  selectedDeviceIds.add(deviceId);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                if (selectedDeviceIds.isNotEmpty)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                    ),
                    onPressed: () async {
                      const serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
                      const characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

                      for (var device in connectedDevices) {
                        if (selectedDeviceIds.contains(device.remoteId.str)) {
                          try {
                            if (device.connectionState != BluetoothConnectionState.connected) {
                              debugPrint("Connecting to \${device.remoteId}...");
                              await device.connect();
                            }

                            List<BluetoothService> services = await device.discoverServices();
                            final service = services.firstWhere(
                              (s) => s.uuid.toString().toLowerCase() == serviceUuid,
                              orElse: () => throw Exception("Service not found"),
                            );

                            final characteristic = service.characteristics.firstWhere(
                              (c) => c.uuid.toString().toLowerCase() == characteristicUuid,
                              orElse: () => throw Exception("Characteristic not found"),
                            );

                            if (characteristic.properties.write) {
                              debugPrint("Writing 'start' to \${device.remoteId}...");
                              await characteristic.write(utf8.encode("start"), withoutResponse: false);
                              debugPrint("✅ Start command sent to \${device.remoteId}");
                            } else {
                              debugPrint("❌ Characteristic not writable on \${device.remoteId}");
                            }
                          } catch (e) {
                            debugPrint("🚫 Failed to send 'start' to \${device.remoteId}: \$e");
                          }
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LiveWorkoutScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text("Start Workout", style: TextStyle(fontFamily: 'SourceSans3')),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(color: Colors.white70, fontFamily: 'SourceSans3')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "You're in!",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'SourceSans3'),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navButton(icon: Icons.history, label: 'Past Workouts', onTap: () => _navigateTo(const PastWorkoutsScreen())),
              const SizedBox(width: 48),
              _navButton(icon: Icons.devices, label: 'My Devices', onTap: () => _navigateTo(const MyDevicesScreen())),
              _navButton(icon: Icons.person, label: 'Profile', onTap: () => _navigateTo(const ProfileScreen())),
            ],
          ),
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Connected Devices',
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1976D2),
          onPressed: () {
            _loadConnectedDevices().then((_) => _showConnectedDevicesPopup(context));
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'SourceSans3'),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
