import 'dart:async';
import 'dart:convert';
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
                notifySubscription = notifyChar!.onValueReceived.listen((value) {
                  final str = utf8.decode(value);
                  final numVal = int.tryParse(str.trim());
                  if (numVal != null) {
                    setState(() {
                      emgData.add(numVal);
                      latestValue = numVal.toString();
                      if (emgData.length > 100) emgData.removeAt(0);
                    });
                  }
                });
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

    if (data.isEmpty) return;

    final double scaleY = size.height / 150.0;
    final double dx = size.width / (data.length - 1);
    for (int i = 0; i < data.length - 1; i++) {
      final p1 = Offset(i * dx, size.height - data[i] * scaleY);
      final p2 = Offset((i + 1) * dx, size.height - data[i + 1] * scaleY);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
