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
  List<int> emgData = [];
  String latestValue = "-";
  int? latestTimestamp;

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
              if (c.uuid.toString() == charUUID && c.properties.notify) {
                notifyChar = c;
                await notifyChar!.setNotifyValue(true);
                notifySubscription = notifyChar!.onValueReceived.listen(_handleNotification);
                return;
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
      // EMG data packet: 10 int16_t values
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
      for (int i = 0; i < 10; i++) {
        int sample = byteData.getInt16(i * 2, Endian.little);
        emgData.add(sample);
      }
      // Keep only most recent 300 samples (~300ms window at 1kHz)
      if (emgData.length > 300) {
        emgData.removeRange(0, emgData.length - 300);
      }

      setState(() {
        latestValue = emgData.last.toString();
      });
    } else if (value.length == 4) {
      // Timestamp packet: 1 uint32_t in ms
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
      int timestamp = byteData.getUint32(0, Endian.little);
      setState(() {
        latestTimestamp = timestamp;
      });
      print("⏱️ Timestamp received: $timestamp ms");
    } else {
      print("⚠️ Unknown packet size: ${value.length} bytes");
    }
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
            const Text(
              "Live EMG Data",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Current Value: $latestValue",
              style: const TextStyle(fontSize: 20),
            ),
            if (latestTimestamp != null)
              Text(
                "Timestamp: ${latestTimestamp!} ms",
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: EMGPainter(emgData),
                child: Container(),
              ),
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

    final double scaleY = size.height / 65536.0; // since range is now full int16
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
