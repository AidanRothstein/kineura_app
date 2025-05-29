import 'package:flutter/material.dart';

class PastWorkoutsScreen extends StatelessWidget {
  const PastWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Workouts')),
      body: const Center(
        child: Text(
          'Past Workouts Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
