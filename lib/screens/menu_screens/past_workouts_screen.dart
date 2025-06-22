import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';   // 👈 make sure this import is here
import 'package:amplify_flutter/amplify_flutter.dart';
import 'workout_detail_screen.dart';

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
    _sessionsFuture = _fetchSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    const query = r'''
      query ListSessions {
        listSessions(limit: 1000) {
          items {
            id
            userID
            timestamp
            durationSeconds
            emgS3Key
            emgProcessedS3Key
            imuS3Key
            workoutType
            notes
            peakRMS
            averageRMS
            fatigueIndex
            elasticityIndex
            activationRatio
            medianFrequency
            meanFrequency
            signalToNoiseRatio
            baselineDrift
            zeroCrossingRate
          }
        }
      }
    ''';

    try {
      final request = GraphQLRequest<String>(
        document: query,
        authorizationMode:
             APIAuthorizationType.userPools,          // ⭐ use the API key to read
      );

      final response = await Amplify.API.query(request: request).response;
      final items =
          jsonDecode(response.data!)['listSessions']['items'] as List<dynamic>;
      final sessions = List<Map<String, dynamic>>.from(items);

      sessions.sort((a, b) =>
          DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      return sessions;
    } catch (e) {
      debugPrint('Failed to fetch sessions: $e');
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
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('No workouts found.'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              final ts = DateTime.parse(s['timestamp']).toLocal();
              final dur = s['durationSeconds'] ?? 0;
              final type = s['workoutType'] ?? 'Unknown';
              final notes = s['notes'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(type,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $ts'),
                      Text('Duration: ${dur}s'),
                      if (notes.isNotEmpty) Text('Notes: $notes'),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(sessionData: s),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
