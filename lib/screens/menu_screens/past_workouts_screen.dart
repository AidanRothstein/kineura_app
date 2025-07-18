import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
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

            emg_ch1_peakRMS
            emg_ch1_averageRMS
            emg_ch1_fatigueIndex
            emg_ch1_elasticityIndex
            emg_ch1_activationRatio
            emg_ch1_medianFrequency
            emg_ch1_meanFrequency
            emg_ch1_signalToNoiseRatio
            emg_ch1_baselineDrift
            emg_ch1_zeroCrossingRate
            emg_ch1_rateOfRise
            emg_ch1_rateOfFall
            emg_ch1_rfdAnalog
            emg_ch1_snrTimeRaw
            emg_ch1_snrTimeDenoised
            emg_ch1_snrFreqRaw
            emg_ch1_snrFreqDenoised

            emg_ch2_peakRMS
            emg_ch2_averageRMS
            emg_ch2_fatigueIndex
            emg_ch2_elasticityIndex
            emg_ch2_activationRatio
            emg_ch2_medianFrequency
            emg_ch2_meanFrequency
            emg_ch2_signalToNoiseRatio
            emg_ch2_baselineDrift
            emg_ch2_zeroCrossingRate
            emg_ch2_rateOfRise
            emg_ch2_rateOfFall
            emg_ch2_rfdAnalog
            emg_ch2_snrTimeRaw
            emg_ch2_snrTimeDenoised
            emg_ch2_snrFreqRaw
            emg_ch2_snrFreqDenoised
          }
        }
      }
    ''';

    try {
      final request = GraphQLRequest<String>(
        document: query,
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;
      final items = jsonDecode(response.data!)['listSessions']['items'] as List<dynamic>;
      final sessions = List<Map<String, dynamic>>.from(items);

      sessions.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      return sessions;
    } catch (e) {
      debugPrint('Failed to fetch sessions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Past Workouts'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load workouts', style: TextStyle(color: Colors.white70)));
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('No workouts found.', style: TextStyle(color: Colors.white70)));
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
                color: Colors.grey[850],
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'SourceSans3',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Date: $ts', style: const TextStyle(color: Colors.white70, fontFamily: 'SourceSans3')),
                      Text('Duration: ${dur}s', style: const TextStyle(color: Colors.white70, fontFamily: 'SourceSans3')),
                      if (notes.isNotEmpty)
                        Text('Notes: $notes', style: const TextStyle(color: Colors.white70, fontFamily: 'SourceSans3')),
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
