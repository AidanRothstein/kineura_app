import 'dart:async';
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
              title: const Text('Connected Devices'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: connectedDevices.isEmpty
                    ? const Center(child: Text('No connected devices'))
                    : ListView.builder(
                        itemCount: connectedDevices.length,
                        itemBuilder: (context, index) {
                          final device = connectedDevices[index];
                          final deviceId = device.remoteId.str;
                          final isSelected = selectedDeviceIds.contains(deviceId);
                          final name = device.platformName.isNotEmpty ? device.platformName : '(unknown)';

                          return ListTile(
                            title: Text(name),
                            subtitle: Text(deviceId),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.radio_button_unchecked),
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LiveWorkoutScreen(),
                        ),
                      );
                    },
                    child: const Text("Start Workout"),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
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
      body: const Center(
        child: Text(
          "You're in!",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
              _navButton(icon: Icons.school, label: 'Learn', onTap: () => _navigateTo(const LearnScreen())),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), onPressed: onTap),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
