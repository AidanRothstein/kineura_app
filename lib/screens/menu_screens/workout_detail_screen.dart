import 'dart:io';
import 'dart:math';
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
  final Map<String, List<FlSpot>> _channelFiltered = {};
  final Map<String, List<FlSpot>> _channelRMS = {};
  bool _loading = false;
  String? _error;

  Future<void> _downloadAndParseEMG() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rawKey = widget.sessionData['emgProcessedS3Key'] ?? widget.sessionData['emgS3Key'];
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
        options: const StorageDownloadFileOptions(accessLevel: StorageAccessLevel.protected),
      ).result;

      final file = File(localPath);
      final csvStr = await file.readAsString();
      final rawRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(csvStr);
      if (rawRows.isEmpty) throw Exception("CSV is empty");

      final headers = List<String>.from(rawRows.first.map((e) => e.toString()));
      final rows = rawRows.skip(1).toList();

      final time = <double>[];
      final filteredData = <String, List<double>>{};
      final rmsData = <String, List<double>>{};

      for (int i = 1; i < headers.length; i++) {
        final name = headers[i];
        if (name.endsWith('_filtered')) {
          filteredData[name] = [];
        } else if (name.endsWith('_rms')) {
          rmsData[name] = [];
        }
      }

      for (int i = 0; i < rows.length; i++) {
        final t = double.tryParse(rows[i][0].toString()) ?? (i / 1000.0);
        time.add(t);
        for (int j = 1; j < headers.length; j++) {
          final key = headers[j];
          final val = double.tryParse(rows[i][j].toString());
          if (val != null && val.isFinite) {
            if (key.endsWith('_filtered')) {
              filteredData[key]?.add(val);
            } else if (key.endsWith('_rms')) {
              rmsData[key]?.add(val);
            }
          } else {
            if (key.endsWith('_filtered')) filteredData[key]?.add(double.nan);
            if (key.endsWith('_rms')) rmsData[key]?.add(double.nan);
          }
        }
      }

      final filteredSpots = <String, List<FlSpot>>{};
      final rmsSpots = <String, List<FlSpot>>{};

      for (final key in filteredData.keys) {
        final prefix = key.replaceAll('_filtered', '');
        final f = <FlSpot>[];
        for (int i = 0; i < time.length; i++) {
          final val = filteredData[key]?[i];
          if (val != null && val.isFinite) f.add(FlSpot(time[i], val));
        }
        filteredSpots[prefix] = f;
      }

      for (final key in rmsData.keys) {
        final prefix = key.replaceAll('_rms', '');
        final r = <FlSpot>[];
        for (int i = 0; i < time.length; i++) {
          final val = rmsData[key]?[i];
          if (val != null && val.isFinite) r.add(FlSpot(time[i], val));
        }
        rmsSpots[prefix] = r;
      }

      setState(() {
        _channelFiltered.clear();
        _channelRMS.clear();
        _channelFiltered.addAll(filteredSpots);
        _channelRMS.addAll(rmsSpots);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to download or parse EMG data.';
        _loading = false;
      });
    }
  }

  Widget _buildChart(String channel) {
    final fSpots = _channelFiltered[channel] ?? [];
    final rSpots = _channelRMS[channel] ?? [];
    if (fSpots.length < 2 || rSpots.length < 2) {
      return const Text('Not enough EMG data to show graph.');
    }

    final minX = fSpots.map((e) => e.x).reduce(min);
    final maxX = fSpots.map((e) => e.x).reduce(max);
    final minY = [...fSpots, ...rSpots].map((e) => e.y).reduce(min);
    final maxY = [...fSpots, ...rSpots].map((e) => e.y).reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(channel, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: fSpots,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  color: Colors.blue,
                  barWidth: 1.5,
                ),
                LineChartBarData(
                  spots: rSpots,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  color: Colors.orange,
                  barWidth: 1.5,
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: ((maxX - minX) / 6).clamp(0.1, double.infinity),
                    getTitlesWidget: (value, _) => Text('${value.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 10)),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: ((maxY - minY) / 6).clamp(1.0, double.infinity),
                    getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                  ),
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMetricsTable() {
    final metrics = widget.sessionData.entries.where((e) => e.key.startsWith('emg_')).toList();
    metrics.sort((a, b) => a.key.compareTo(b.key));

    return DataTable(
      columns: const [
        DataColumn(label: Text('Metric')),
        DataColumn(label: Text('Value')),
      ],
      rows: metrics.map((e) {
        final display = e.value is num ? (e.value as num).toStringAsFixed(4) : 'N/A';
        return DataRow(cells: [
          DataCell(Text(e.key)),
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
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ..._channelFiltered.keys.map(_buildChart).toList(),
            const SizedBox(height: 24),
            _buildMetricsTable(),
          ],
        ),
      ),
    );
  }
}
