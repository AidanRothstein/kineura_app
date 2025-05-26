import 'package:flutter/material.dart';

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
              _navButton(icon: Icons.school, label: 'Learn'),
              _navButton(icon: Icons.history, label: 'Past Workouts'),
              const SizedBox(width: 48), // space for the FAB
              _navButton(icon: Icons.devices, label: 'My Devices'),
              _navButton(icon: Icons.person, label: 'Profile'),
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

  Widget _navButton({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            // TODO: Navigate to respective screen
          },
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
