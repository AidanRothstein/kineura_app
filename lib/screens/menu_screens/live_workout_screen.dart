import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class LiveWorkoutScreen extends StatefulWidget {
  const LiveWorkoutScreen({super.key});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String charUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyChar;
  BluetoothCharacteristic? writeChar;

  List<int> emgData = [];
  String latestValue = "-";
  int? latestTimestamp;
  int? startTimestamp;

  bool isRecording = false;
  File? tempFile;
  IOSink? tempSink;

  StreamSubscription<List<int>>? notifySubscription;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluePlus.connectedSystemDevices;

      if (devices.isNotEmpty) {
        connectedDevice = devices.first;
        List<BluetoothService> services = await connectedDevice!.discoverServices();
        for (BluetoothService service in services) {
          if (service.uuid.toString() == serviceUUID) {
            for (BluetoothCharacteristic c in service.characteristics) {
              if (c.uuid.toString() == charUUID) {
                if (c.properties.notify) {
                  notifyChar = c;
                  await notifyChar!.setNotifyValue(true);
                  notifySubscription = notifyChar!.onValueReceived.listen(_handleNotification);
                }
                if (c.properties.write) {
                  writeChar = c;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("⚠️ Error in setupNotifications: $e");
    }
  }

  void _handleNotification(List<int> value) {
    if (value.length == 20) {
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
      for (int i = 0; i < 10; i++) {
        int sample = byteData.getInt16(i * 2, Endian.little);
        emgData.add(sample);
        if (isRecording && tempSink != null) {
          tempSink!.writeln(sample);
        }
      }
      if (emgData.length > 300) {
        emgData.removeRange(0, emgData.length - 300);
      }
      setState(() {
        latestValue = emgData.last.toString();
      });
    } else if (value.length == 4) {
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
      int timestamp = byteData.getUint32(0, Endian.little);
      if (isRecording && startTimestamp == null) {
        startTimestamp = timestamp;
      }
      setState(() {
        latestTimestamp = timestamp;
      });
    }
  }

  Future<void> _sendBLECommand(String command) async {
    if (writeChar != null) {
      await writeChar!.write(command.codeUnits, withoutResponse: false);
    }
  }

  void _toggleRecording() async {
    if (isRecording) {
      await _sendBLECommand("stop");
      setState(() => isRecording = false);
      await tempSink?.flush();
      await tempSink?.close();
      _showSaveDialog();
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/emg_${DateTime.now().millisecondsSinceEpoch}.csv');
      tempFile = file;
      tempSink = file.openWrite();
      startTimestamp = null;
      await _sendBLECommand("start");
      setState(() => isRecording = true);
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Workout?"),
        content: const Text("Would you like to save or discard this recording?"),
        actions: [
          TextButton(
            onPressed: _saveWorkout,
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: _confirmDiscard,
            child: const Text("Discard"),
          ),
        ],
      ),
    );
  }

  void _confirmDiscard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This will delete the recorded EMG data permanently."),
        actions: [
          TextButton(
            onPressed: () async {
              await tempFile?.delete();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Workout discarded.")),
              );
            },
            child: const Text("Yes, Discard"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkout() async {
    Navigator.of(context).pop();
    if (tempFile == null || startTimestamp == null || latestTimestamp == null) return;

    try {
      final user = await Amplify.Auth.getCurrentUser();
      final userId = user.userId;

      final duration = ((latestTimestamp! - startTimestamp!) / 1000).round();
      final key = 'emg/$userId/${DateTime.now().toIso8601String()}.csv';

      final operation = Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(tempFile!.path),
        key: key,
        options: StorageUploadFileOptions(
          accessLevel: StorageAccessLevel.protected,
        ),
      );
      final result = await operation.result;
      final uploadedKey = result.uploadedItem.key;

      final nowIso = DateTime.now().toIso8601String().split('.').first + 'Z';

      final mutation = '''
        mutation CreateSession {
          createSession(input: {
            userID: "$userId",
            timestamp: "$nowIso",
            durationSeconds: $duration,
            emgS3Key: "$uploadedKey",
            imuS3Key: null,
            workoutType: "Default",
            notes: ""
          }) {
            id
          }
        }
      ''';

      final request = GraphQLRequest<String>(document: mutation);
      final response = await Amplify.API.mutate(request: request).response;
      print("Mutation response: \${response.data}");
      print("Mutation errors: \${response.errors}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout saved!")),
      );
    } catch (e) {
      print("⚠️ Upload or mutation error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving workout: $e")),
      );
    }
  }

  @override
  void dispose() {
    notifySubscription?.cancel();
    notifyChar?.setNotifyValue(false);
    tempSink?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Live EMG Data", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Current Value: $latestValue", style: const TextStyle(fontSize: 20)),
            if (latestTimestamp != null)
              Text("Timestamp: \${latestTimestamp!} ms", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: EMGPainter(emgData),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(isRecording ? "Stop Recording" : "Start Recording"),
            ),
          ],
        ),
      ),
    );
  }
}

class EMGPainter extends CustomPainter {
  final List<int> data;
  EMGPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0;

    if (data.length < 2) return;

    final double scaleY = size.height / 65536.0;
    final double dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length - 1; i++) {
      final y1 = size.height / 2 - data[i] * scaleY;
      final y2 = size.height / 2 - data[i + 1] * scaleY;
      final p1 = Offset(i * dx, y1);
      final p2 = Offset((i + 1) * dx, y2);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
