import 'package:flutter/material.dart';
import 'my_devices_screen.dart'; // Make sure this file exists and is correctly named

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              _navButton(icon: Icons.school, label: 'Learn', onTap: () {
                // TODO
              }),
              _navButton(icon: Icons.history, label: 'Past Workouts', onTap: () {
                // TODO
              }),
              const SizedBox(width: 48), // space for the FAB
              _navButton(
                icon: Icons.devices,
                label: 'My Devices',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyDevicesScreen(),
                    ),
                  );
                },
              ),
              _navButton(icon: Icons.person, label: 'Profile', onTap: () {
                // TODO
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Start Workout',
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to start workout screen
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  static Widget _navButton({
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
