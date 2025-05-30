import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';

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
  
  // Local display data (reduced size for performance)
  List<int> displayEmgData = [];
  String latestValue = "-";
  int? latestTimestamp;
  bool isRecording = false;
  StreamSubscription<List<int>>? notifySubscription;
  
  // Data batching for cloud transmission
  List<EMGDataPoint> batchBuffer = [];
  Timer? batchTimer;
  String? currentSessionId;
  String? currentUserId;
  DateTime? sessionStartTime;
  
  // Batch configuration
  static const int BATCH_SIZE = 500; // 500ms worth of data at 1000Hz
  static const Duration BATCH_INTERVAL = Duration(milliseconds: 500);
  static const int MAX_RETRIES = 3;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      currentUserId = user.userId;
    } catch (e) {
      print("Error getting current user: $e");
    }
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
    final now = DateTime.now();
    
    if (value.length == 20) {
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
      
      for (int i = 0; i < 10; i++) {
        int sample = byteData.getInt16(i * 2, Endian.little);
        
        // Add to display buffer (limited size for UI performance)
        displayEmgData.add(sample);
        if (displayEmgData.length > 300) {
          displayEmgData.removeRange(0, displayEmgData.length - 300);
        }
        
        // Add to batch buffer for cloud transmission (only if recording)
        if (isRecording && currentSessionId != null) {
          batchBuffer.add(EMGDataPoint(
            timestamp: now.add(Duration(microseconds: i * 1000)), // 1ms intervals
            value: sample,
            sensorId: "emg_sensor_1", // Could be dynamic based on device
            channelId: 0, // Could be dynamic for multi-channel
          ));
        }
      }
      
      setState(() {
        latestValue = displayEmgData.last.toString();
      });
      
      // Check if batch is ready for transmission
      if (isRecording && batchBuffer.length >= BATCH_SIZE) {
        _transmitBatch();
      }
    } else if (value.length == 4) {
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
      int timestamp = byteData.getUint32(0, Endian.little);
      setState(() {
        latestTimestamp = timestamp;
      });
    }
  }

  Future<void> _transmitBatch() async {
    if (batchBuffer.isEmpty || currentSessionId == null || currentUserId == null) return;
    
    final batchToSend = List<EMGDataPoint>.from(batchBuffer);
    batchBuffer.clear();
    
    final batchData = EMGBatch(
      sessionId: currentSessionId!,
      userId: currentUserId!,
      batchStartTime: batchToSend.first.timestamp,
      batchEndTime: batchToSend.last.timestamp,
      samplingRate: 1000,
      dataPoints: batchToSend,
      batchSequence: DateTime.now().millisecondsSinceEpoch, // Simple sequence number
    );
    
    await _sendBatchWithRetry(batchData);
  }

  Future<void> _sendBatchWithRetry(EMGBatch batch, [int retryCount = 0]) async {
    try {
      const String createEMGBatch = '''
        mutation CreateEMGBatch(\$input: CreateEMGBatchInput!) {
          createEMGBatch(input: \$input) {
            sessionId
            batchSequence
            status
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: createEMGBatch,
        variables: <String, dynamic>{
          'input': batch.toJson(),
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        throw Exception('GraphQL errors: ${response.errors}');
      }
      
      print("✅ Batch transmitted successfully: ${batch.batchSequence}");
      
    } catch (e) {
      print("❌ Failed to transmit batch (attempt ${retryCount + 1}): $e");
      
      if (retryCount < MAX_RETRIES) {
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 1000 * (retryCount + 1)));
        await _sendBatchWithRetry(batch, retryCount + 1);
      } else {
        print("🚫 Max retries exceeded for batch: ${batch.batchSequence}");
        // Could implement local storage for failed batches here
      }
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
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please ensure you're logged in")),
      );
      return;
    }
    
    // Generate session ID and start time
    currentSessionId = "${currentUserId}_${DateTime.now().millisecondsSinceEpoch}";
    sessionStartTime = DateTime.now();
    
    // Start BLE recording
    await _sendBLECommand("start");
    
    // Create session metadata in DynamoDB
    await _createSession();
    
    // Start batch timer as backup
    batchTimer = Timer.periodic(BATCH_INTERVAL, (_) {
      if (batchBuffer.isNotEmpty) {
        _transmitBatch();
      }
    });
    
    setState(() {
      isRecording = true;
    });
    
    print("🎬 Recording started: Session $currentSessionId");
  }

  Future<void> _stopRecording() async {
    // Stop BLE recording
    await _sendBLECommand("stop");
    
    // Transmit any remaining data
    if (batchBuffer.isNotEmpty) {
      await _transmitBatch();
    }
    
    // Stop batch timer
    batchTimer?.cancel();
    batchTimer = null;
    
    // Update session metadata
    await _updateSession();
    
    setState(() {
      isRecording = false;
    });
    
    _showSaveDialog();
    
    print("⏹️ Recording stopped: Session $currentSessionId");
  }

  Future<void> _createSession() async {
    try {
      const String createSession = '''
        mutation CreateEMGSession(\$input: CreateEMGSessionInput!) {
          createEMGSession(input: \$input) {
            sessionId
            userId
            startTime
            status
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: createSession,
        variables: <String, dynamic>{
          'input': {
            'sessionId': currentSessionId,
            'userId': currentUserId,
            'startTime': sessionStartTime!.toIso8601String(),
            'status': 'RECORDING',
            'deviceInfo': {
              'deviceId': connectedDevice?.remoteId.str ?? 'unknown',
              'deviceName': connectedDevice?.platformName ?? 'unknown',
            }
          },
        },
      );
      
      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      print("Error creating session: $e");
    }
  }

  Future<void> _updateSession() async {
    try {
      const String updateSession = '''
        mutation UpdateEMGSession(\$input: UpdateEMGSessionInput!) {
          updateEMGSession(input: \$input) {
            sessionId
            endTime
            status
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: updateSession,
        variables: <String, dynamic>{
          'input': {
            'sessionId': currentSessionId,
            'endTime': DateTime.now().toIso8601String(),
            'status': 'COMPLETED',
          },
        },
      );
      
      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      print("Error updating session: $e");
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recording Complete"),
        content: Text("Session ${currentSessionId} has been saved to the cloud."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              currentSessionId = null;
              sessionStartTime = null;
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    notifySubscription?.cancel();
    notifyChar?.setNotifyValue(false);
    batchTimer?.cancel();
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
            if (isRecording)
              Text("Recording Session: $currentSessionId", style: const TextStyle(fontSize: 14, color: Colors.green)),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: EMGPainter(displayEmgData),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.green,
              ),
              child: Text(isRecording ? "Stop Recording" : "Start Recording"),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models
class EMGDataPoint {
  final DateTime timestamp;
  final int value;
  final String sensorId;
  final int channelId;

  EMGDataPoint({
    required this.timestamp,
    required this.value,
    required this.sensorId,
    required this.channelId,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
    'sensorId': sensorId,
    'channelId': channelId,
  };
}

class EMGBatch {
  final String sessionId;
  final String userId;
  final DateTime batchStartTime;
  final DateTime batchEndTime;
  final int samplingRate;
  final List<EMGDataPoint> dataPoints;
  final int batchSequence;

  EMGBatch({
    required this.sessionId,
    required this.userId,
    required this.batchStartTime,
    required this.batchEndTime,
    required this.samplingRate,
    required this.dataPoints,
    required this.batchSequence,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'userId': userId,
    'batchStartTime': batchStartTime.toIso8601String(),
    'batchEndTime': batchEndTime.toIso8601String(),
    'samplingRate': samplingRate,
    'dataPoints': dataPoints.map((dp) => dp.toJson()).toList(),
    'batchSequence': batchSequence,
  };
}

// Keep the existing EMGPainter class unchanged
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
