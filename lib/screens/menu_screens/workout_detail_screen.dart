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

      final rawKey = widget.sessionData['emgProcessedS3Key'] ??
          widget.sessionData['emgS3Key'];

      if (rawKey == null || rawKey is! String || rawKey.isEmpty) {
        setState(() {
          _error = 'No valid S3 key found for this session.';
          _loading = false;
        });
        return;
      }

      final match = RegExp(r'^[^/]+/[^/]+/(.*)').firstMatch(rawKey);
      final logicalKey = match != null ? match.group(1)! : rawKey;

      final tempDir = await getApplicationDocumentsDirectory();

      final localPath = '${tempDir.path}/processed.csv';

      await Amplify.Storage.downloadFile(
        key: logicalKey,
        localFile: AWSFile.fromPath(localPath),
        options: const StorageDownloadFileOptions(
          accessLevel: StorageAccessLevel.protected,
        ),
      ).result;

      final file = File(localPath);
      final csvStr = await file.readAsString();

      final rawRows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvStr);
      final rows = rawRows.skip(1).toList();

      final filtered = <FlSpot>[];
      final rms = <FlSpot>[];
      for (var i = 0; i < rows.length; i++) {
        final t = double.tryParse(rows[i][0].toString()) ?? (i / 1000.0);
        final fVal = double.tryParse(rows[i][1].toString());
        final rVal = rows[i].length > 2 ? double.tryParse(rows[i][2].toString()) : null;

        if (fVal != null && fVal.isFinite) {
          filtered.add(FlSpot(t, fVal));
        }
        if (rVal != null && rVal.isFinite) {
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
    if (_filteredSpots.length < 2) {
      return const Text('Not enough EMG data to show graph.');
    }

    final minX = _filteredSpots.map((e) => e.x).reduce(min);
    final maxX = _filteredSpots.map((e) => e.x).reduce(max);
    final minY = [..._filteredSpots, ..._rmsSpots].map((e) => e.y).reduce(min);
    final maxY = [..._filteredSpots, ..._rmsSpots].map((e) => e.y).reduce(max);

    final lineBars = [
      LineChartBarData(
        spots: _filteredSpots,
        isCurved: false,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: Colors.blue,
        barWidth: 1.5,
      ),
      LineChartBarData(
        spots: _rmsSpots,
        isCurved: false,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: Colors.orange,
        barWidth: 1.5,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: lineBars,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: ((maxX - minX) / 6).clamp(0.1, double.infinity),
                    getTitlesWidget: (value, _) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${value.toStringAsFixed(1)}s',
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: ((maxY - minY) / 6).clamp(1.0, double.infinity),
                    getTitlesWidget: (value, _) => Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.square, color: Colors.blue, size: 12),
            SizedBox(width: 4),
            Text('Filtered EMG'),
            SizedBox(width: 12),
            Icon(Icons.square, color: Colors.orange, size: 12),
            SizedBox(width: 4),
            Text('RMS Envelope'),
          ],
        )
      ],
    );
  }

  Widget _buildMetricsTable() {
    final metrics = [
      'peakRMS',
      'averageRMS',
      'fatigueIndex',
      'elasticityIndex',
      'activationRatio',
      'medianFrequency',
      'meanFrequency',
      'signalToNoiseRatio',
      'baselineDrift',
      'zeroCrossingRate'
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
