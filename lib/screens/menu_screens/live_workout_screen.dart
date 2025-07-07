// ... all your existing imports ...
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../../models/SleeveConfig.dart';
import '../../models/ModelProvider.dart';


class LiveWorkoutScreen extends StatefulWidget {
  const LiveWorkoutScreen({super.key});
  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  final String serviceUUID = "df1a0863-f02f-49ba-bf55-3b56c6bcb398";
  final String charUUID = "8c24159c-66a0-4340-8b55-465047ce37ce";

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyChar;
  BluetoothCharacteristic? writeChar;
  List<String> channelLabels = [];


  int numChannels = 1;
  List<List<int>> multiChannelEmgData = [];
  List<List<int>> multiChannelNewSamples = [];

  String latestValue = "-";
  int? latestTimestamp;
  int? startTimestamp;

  bool isRecording = false;
  bool isConnected = false;
  bool hadDisconnectDuringRecording = false;
  bool hasSyncedData = false;
  bool isSyncing = false;
  bool isSavingWorkout = false;
  String connectionStatus = "Disconnected";

  File? tempFile;
  IOSink? tempSink;

  StreamSubscription<List<int>>? notifySubscription;
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;
  Timer? reconnectTimer;

  @override
  void initState() {
    super.initState();
    _initializeBLE();
  }

  Future<void> _initializeBLE() async {
    await _setupNotifications();
    _startPeriodicConnectionCheck();
  }

  void _startPeriodicConnectionCheck() {
    reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isConnected && !isSavingWorkout) {
        _attemptReconnection();
      }
    });
  }

  Future<void> _attemptReconnection() async {
    if (isConnected) return;
    try {
      setState(() => connectionStatus = "Reconnecting...");
      await _cleanupConnection();
      await Future.delayed(const Duration(seconds: 1));
      await _setupNotifications();
    } catch (e) {
      setState(() => connectionStatus = "Reconnection Failed");
    }
  }

  Future<void> _cleanupConnection() async {
    await notifySubscription?.cancel();
    await connectionSubscription?.cancel();
    if (notifyChar != null) {
      try {
        await notifyChar!.setNotifyValue(false);
      } catch (_) {}
    }
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (_) {}
    }
    connectedDevice = null;
    notifyChar = null;
    writeChar = null;
    notifySubscription = null;
    connectionSubscription = null;
    setState(() => isConnected = false);
  }

  Future<void> _setupNotifications() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedSystemDevices;
    BluetoothDevice? targetDevice;
    for (BluetoothDevice device in devices) {
      if (device.name.contains("Deez") || device.name.contains("EMG_Logger")) {
        targetDevice = device;
        break;
      }
    }
    targetDevice ??= await _scanForDevice();
    if (targetDevice != null) {
      await _connectToDevice(targetDevice);
    } else {
      setState(() {
        isConnected = false;
        connectionStatus = "Device Not Found";
      });
    }
  }

  Future<BluetoothDevice?> _scanForDevice() async {
    BluetoothDevice? foundDevice;
    StreamSubscription? scanSubscription;
    scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name.contains("Deez") || result.device.name.contains("EMG_Logger")) {
          foundDevice = result.device;
          FlutterBluePlus.stopScan();
          scanSubscription?.cancel();
          return;
        }
      }
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    await scanSubscription?.cancel();
    return foundDevice;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
  connectedDevice = device;
  if (device.connectionState != BluetoothConnectionState.connected) {
    await device.connect(timeout: const Duration(seconds: 15));
  }
  try {
    await device.requestMtu(247);
  } catch (_) {}
  try {
    await device.requestConnectionPriority(connectionPriorityRequest: ConnectionPriority.high);
  } catch (_) {}

  connectionSubscription = device.connectionState.listen(_handleConnectionStateChange);

  // ↓ Query and apply SleeveConfig if device name contains 'Deez'
  if (device.name.contains("Deez")) {
    try {
      final configs = await Amplify.DataStore.query(SleeveConfig.classType,
        where: SleeveConfig.DEVICENAMECONTAINS.eq("Deez"));
      if (configs.isNotEmpty) {
        channelLabels = configs.first.channelLabels;
        numChannels = channelLabels.length;
        debugPrint("Applied SleeveConfig for Deez: $channelLabels");
      }
    } catch (e) {
      debugPrint("Failed to fetch SleeveConfig: $e");
    }
  }

  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    if (service.uuid.toString() == serviceUUID) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString() == charUUID) {
          if (c.properties.notify) {
            notifyChar = c;
            await c.setNotifyValue(true);
            notifySubscription = c.onValueReceived.listen(_handleNotification);
          }
          if (c.properties.write) {
            writeChar = c;
          }
        }
      }
      break;
    }
  }

  setState(() {
    isConnected = true;
    connectionStatus = "Connected";
  });
}


  void _handleConnectionStateChange(BluetoothConnectionState state) {
    setState(() {
      isConnected = state == BluetoothConnectionState.connected;
      connectionStatus = isConnected ? "Connected" : "Disconnected";
    });
    if (!isConnected && isRecording) hadDisconnectDuringRecording = true;
  }

  void _handleNotification(List<int> value) {
  try {
    final decoded = String.fromCharCodes(value);
    if (decoded.startsWith("meta,numChannels=")) {
      numChannels = int.parse(decoded.split("=")[1]);
      debugPrint("Set numChannels = $numChannels");
      return;
    }
  } catch (_) {}

  // Handle 4-byte timestamp packet
  if (value.length == 4) {
    final byteData = ByteData.sublistView(Uint8List.fromList(value));
    latestTimestamp = byteData.getUint32(0, Endian.little);
    if (isRecording && startTimestamp == null) {
      startTimestamp = latestTimestamp;
    }
    return;
  }

  // If we haven't received a timestamp yet, drop this data
  if (latestTimestamp == null) return;

  // Handle EMG sample packet
  int bytesPerSample = numChannels * 2;
  if (value.length % bytesPerSample != 0) return;

  final byteData = ByteData.sublistView(Uint8List.fromList(value));
  int numSamples = value.length ~/ bytesPerSample;

  for (int i = 0; i < numSamples; i++) {
    List<int> row = [latestTimestamp! + i];
    for (int ch = 0; ch < numChannels; ch++) {
      int offset = i * bytesPerSample + ch * 2;
      row.add(byteData.getInt16(offset, Endian.little));
    }
    multiChannelEmgData.add(row);
    multiChannelNewSamples.add(row);
  }

  while (multiChannelNewSamples.length > 300) {
    multiChannelNewSamples.removeAt(0);
  }

  setState(() => latestValue = multiChannelNewSamples.last[1].toString());

  // After assigning timestamps to this packet, bump latestTimestamp
  latestTimestamp = latestTimestamp! + numSamples;
}



  void _toggleRecording() async {
    if (isRecording) {
      await _sendBLECommand("stop");
      setState(() => isRecording = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Save Workout?"),
          content: const Text("Do you want to save this workout or discard it?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveWorkout();
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  multiChannelEmgData.clear();
                  multiChannelNewSamples.clear();
                  latestValue = "-";
                  latestTimestamp = null;
                  startTimestamp = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Workout discarded.")),
                );
              },
              child: const Text("Discard"),
            ),
          ],
        ),
      );
    } else {
      multiChannelEmgData.clear();
      multiChannelNewSamples.clear();
      startTimestamp = null;
      await _sendBLECommand("start");
      setState(() => isRecording = true);
    }
  }

  Future<void> _sendBLECommand(String command) async {
    if (writeChar != null && isConnected) {
      try {
        await writeChar!.write(command.codeUnits, withoutResponse: false);
      } catch (_) {}
    }
  }

  Future<void> _saveWorkout() async {
    setState(() => isSavingWorkout = true);
    try {
      if (startTimestamp == null || latestTimestamp == null) throw Exception("Missing timestamps");
      final csvData = _convertEMGDataToCSV();
      final dir = await getTemporaryDirectory();
      final csvFile = File('${dir.path}/emg_${DateTime.now().millisecondsSinceEpoch}.csv');
      await csvFile.writeAsString(csvData);
      final user = await Amplify.Auth.getCurrentUser();
      final userId = user.userId;
      final key = 'emg/$userId/${DateTime.now().toIso8601String()}.csv';
      final operation = Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(csvFile.path),
        key: key,
        options: StorageUploadFileOptions(accessLevel: StorageAccessLevel.protected),
      );
      await operation.result;
      await csvFile.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout uploaded. Lambda will process session.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSavingWorkout = false);
    }
  }

  String _convertEMGDataToCSV() {
  if (multiChannelEmgData.isEmpty) return "";

  StringBuffer buffer = StringBuffer();

  // Write headers
  buffer.write("timestamp_ms");
  if (channelLabels.isNotEmpty && channelLabels.length == numChannels) {
    for (final label in channelLabels) {
      buffer.write(",$label");
    }
  } else {
    for (int i = 0; i < numChannels; i++) {
      buffer.write(",emg_ch${i + 1}");
    }
  }
  buffer.writeln();

  // Write data
  for (var row in multiChannelEmgData) {
    buffer.writeln(row.join(","));
  }

  return buffer.toString();
}


  @override
  void dispose() {
    reconnectTimer?.cancel();
    notifySubscription?.cancel();
    connectionSubscription?.cancel();
    notifyChar?.setNotifyValue(false);
    connectedDevice?.disconnect();
    tempSink?.close();
    super.dispose();
  }

  Color _getConnectionStatusColor() {
    switch (connectionStatus) {
      case "Connected": return Colors.green;
      case "Connecting...":
      case "Reconnecting...": return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Workout'),
        backgroundColor: _getConnectionStatusColor(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: _getConnectionStatusColor().withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: _getConnectionStatusColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Status: $connectionStatus",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getConnectionStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Live EMG Data", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Current Value: $latestValue", style: const TextStyle(fontSize: 20)),
            if (latestTimestamp != null)
              Text("Timestamp: ${latestTimestamp!} ms", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: EMGPainter(multiChannelNewSamples, numChannels),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSavingWorkout ? null : _toggleRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                isRecording ? "Stop Recording" : "Start Recording",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EMGPainter extends CustomPainter {
  final List<List<int>> data;
  final int numChannels;
  EMGPainter(this.data, this.numChannels);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2 || numChannels == 0) return;
    final channelHeight = size.height / numChannels;
    final dx = size.width / (data.length - 1);
    for (int ch = 0; ch < numChannels; ch++) {
      final paint = Paint()
        ..color = Colors.primaries[ch % Colors.primaries.length]
        ..strokeWidth = 1.5;
      for (int i = 0; i < data.length - 1; i++) {
        final y1 = channelHeight * (ch + 0.5) - data[i][ch + 1] * (channelHeight / 65536.0);
        final y2 = channelHeight * (ch + 0.5) - data[i + 1][ch + 1] * (channelHeight / 65536.0);
        canvas.drawLine(Offset(i * dx, y1), Offset((i + 1) * dx, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
