import 'package:flutter/material.dart';

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> {
  bool showStartWorkoutLabel = false;

  void _toggleWorkoutLabel() {
    setState(() {
      showStartWorkoutLabel = !showStartWorkoutLabel;
    });
  }

  void _navigateToStartWorkout() {
    setState(() {
      showStartWorkoutLabel = false;
    });
    // TODO: Navigate to Start Workout screen
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (showStartWorkoutLabel) {
          setState(() {
            showStartWorkoutLabel = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My Devices')),
        body: const Center(
          child: Text('This is the My Devices screen.'),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SafeArea( // ✅ FIX applied here
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(icon: Icons.school, label: 'Learn'),
                  _navButton(icon: Icons.history, label: 'Past Workouts'),
                  const SizedBox(width: 48), // space for FAB
                  _navButton(icon: Icons.devices, label: 'My Devices'),
                  _navButton(icon: Icons.person, label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (showStartWorkoutLabel)
              Positioned(
                bottom: 70,
                child: ElevatedButton(
                  onPressed: _navigateToStartWorkout,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("Start Workout"),
                ),
              ),
            FloatingActionButton(
              onPressed: _toggleWorkoutLabel,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _navButton({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            // TODO: Add navigation logic
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
