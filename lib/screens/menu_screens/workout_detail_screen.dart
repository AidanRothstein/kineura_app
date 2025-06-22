import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:convert';


class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  const WorkoutDetailScreen({super.key, required this.sessionData});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  List<FlSpot> _filteredSpots = [];
  List<FlSpot> _rmsSpots = [];
  bool _loading = false;
  String? _error;

  Future<void> _downloadAndParseEMG() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print("DEBUG: sessionData = ${jsonEncode(widget.sessionData)}");

      final s3Key = widget.sessionData['emgProcessedS3Key'] ?? widget.sessionData['emgS3Key'];

      if (s3Key == null || s3Key is! String || s3Key.isEmpty) {
        setState(() {
          _error = 'No valid S3 key found for this session.';
          _loading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/processed.csv';

      await Amplify.Storage.downloadFile(
        key: s3Key,
        localFile: AWSFile.fromPath(localPath),
        options: const StorageDownloadFileOptions(
          accessLevel: StorageAccessLevel.protected,
        ),
      ).result;

      final file = File(localPath);
      final csvStr = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvStr);

      final filtered = <FlSpot>[];
      final rms = <FlSpot>[];
      for (var i = 1; i < rows.length; i++) {
        final t = double.tryParse(rows[i][0].toString()) ?? (i - 1) / 1000.0;
        final fVal = double.tryParse(rows[i][1].toString()) ?? 0;
        final rVal = rows.length > 2 ? double.tryParse(rows[i][2].toString()) : null;

        filtered.add(FlSpot(t, fVal));
        if (rVal != null) {
          rms.add(FlSpot(t, rVal));
        }
      }

      setState(() {
        _filteredSpots = filtered;
        _rmsSpots = rms;
        _loading = false;
      });
    } catch (e) {
      print('Download/parse failed: $e');
      setState(() {
        _error = 'Failed to download or parse EMG data.';
        _loading = false;
      });
    }
  }

  Widget _buildChart() {
    if (_filteredSpots.isEmpty) return const Text('No EMG data loaded yet.');

    final lineBars = [
      LineChartBarData(
        spots: _filteredSpots,
        isCurved: false,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: Colors.blue,
        barWidth: 1.5,
      ),
    ];

    if (_rmsSpots.isNotEmpty) {
      lineBars.add(
        LineChartBarData(
          spots: _rmsSpots,
          isCurved: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          color: Colors.orange,
          barWidth: 1.5,
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: _filteredSpots.first.x,
          maxX: _filteredSpots.last.x,
          lineBarsData: lineBars,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.5,
                getTitlesWidget: (value, _) => Text('${value.toStringAsFixed(1)}s'),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildMetricsTable() {
    final metrics = [
      'peakRMS', 'averageRMS', 'fatigueIndex', 'elasticityIndex',
      'activationRatio', 'medianFrequency', 'meanFrequency',
      'signalToNoiseRatio', 'baselineDrift', 'zeroCrossingRate'
    ];

    return DataTable(
      columns: const [
        DataColumn(label: Text('Metric')),
        DataColumn(label: Text('Value')),
      ],
      rows: metrics.map((key) {
        final value = widget.sessionData[key];
        final display = value is num ? value.toStringAsFixed(4) : 'N/A';
        return DataRow(cells: [
          DataCell(Text(key)),
          DataCell(Text(display)),
        ]);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(widget.sessionData['timestamp']).toLocal();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Workout Type: ${widget.sessionData['workoutType']}'),
            Text('Timestamp: $timestamp'),
            Text('Duration: ${widget.sessionData['durationSeconds']}s'),
            Text('Notes: ${widget.sessionData['notes'] ?? "None"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _downloadAndParseEMG,
              child: const Text('Download Processed EMG'),
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_filteredSpots.isNotEmpty) _buildChart(),
            const SizedBox(height: 24),
            _buildMetricsTable(),
          ],
        ),
      ),
    );
  }
}
