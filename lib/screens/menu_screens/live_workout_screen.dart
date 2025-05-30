import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  bool isRecording = false;

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
      setState(() {
        latestTimestamp = timestamp;
      });
      print("⏱️ Timestamp received: $timestamp ms");
    }
  }

  Future<void> _sendBLECommand(String command) async {
    if (writeChar != null) {
      await writeChar!.write(command.codeUnits, withoutResponse: false);
      print("📤 Sent BLE command: $command");
    }
  }

  void _toggleRecording() async {
    if (isRecording) {
      await _sendBLECommand("stop");
      setState(() {
        isRecording = false;
      });
      _showSaveDialog();
    } else {
      await _sendBLECommand("start");
      setState(() {
        isRecording = true;
      });
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Workout saved!")),
              );
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Workout discarded.")),
              );
            },
            child: const Text("Discard"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    notifySubscription?.cancel();
    notifyChar?.setNotifyValue(false);
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
              Text("Timestamp: ${latestTimestamp!} ms", style: const TextStyle(fontSize: 16)),
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
