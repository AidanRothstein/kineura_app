import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'workout_detail_screen.dart'; // Placeholder screen for details

class PastWorkoutsScreen extends StatefulWidget {
  const PastWorkoutsScreen({super.key});

  @override
  State<PastWorkoutsScreen> createState() => _PastWorkoutsScreenState();
}

class _PastWorkoutsScreenState extends State<PastWorkoutsScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  Future<List<Map<String, dynamic>>> fetchSessions() async {
    const listSessionsQuery = '''query ListSessions {
      listSessions(limit: 1000) {
        items {
          id
          timestamp
          durationSeconds
          workoutType
          notes
          emgS3Key
        }
      }
    }''';

    try {
      final request = GraphQLRequest<String>(document: listSessionsQuery);
      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data!)['listSessions']['items'];
      final sessions = List<Map<String, dynamic>>.from(data);
      sessions.sort((a, b) =>
          DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      return sessions;
    } catch (e) {
      print("Failed to fetch sessions: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Workouts')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load workouts'));
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No workouts found.'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final timestamp = DateTime.parse(session['timestamp']).toLocal();
              final duration = session['durationSeconds'] ?? 0;
              final workoutType = session['workoutType'] ?? 'Unknown';
              final notes = session['notes'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    workoutType,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${timestamp.toLocal()}'),
                      Text('Duration: ${duration}s'),
                      if (notes.isNotEmpty) Text('Notes: $notes'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkoutDetailScreen(sessionData: session),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
