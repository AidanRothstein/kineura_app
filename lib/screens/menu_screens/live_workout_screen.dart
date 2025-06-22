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
  // Updated UUIDs to match ESP32
  final String serviceUUID = "df1a0863-f02f-49ba-bf55-3b56c6bcb398";
  final String charUUID = "8c24159c-66a0-4340-8b55-465047ce37ce";

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyChar;
  BluetoothCharacteristic? writeChar;

  List<int> emgData = [];
  List<int> syncedEmgData = []; // Store synced data separately
  List<int> newSamples = [];
  String latestValue = "-";
  int? latestTimestamp;
  int? startTimestamp;

  bool isRecording = false;
  bool isConnected = false;
  bool hadDisconnectDuringRecording = false; // Add this flag
  bool hasSyncedData = false; // Flag to track if we have synced data
  bool isSyncing = false;
  bool isSavingWorkout = false; // New flag for save process
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
      if (!isConnected && !isSavingWorkout) { // Don't reconnect during save process
        _attemptReconnection();
      }
    });
  }

  Future<void> _attemptReconnection() async {
    if (isConnected) return; // Don't attempt if already connected
    
    try {
      setState(() {
        connectionStatus = "Reconnecting...";
      });
      
      // Clean up previous connection completely
      await _cleanupConnection();
      
      // Small delay before attempting reconnection
      await Future.delayed(const Duration(seconds: 1));
      
      await _setupNotifications();
    } catch (e) {
      print("⚠️ Reconnection attempt failed: $e");
      setState(() {
        connectionStatus = "Reconnection Failed";
      });
    }
  }

  Future<void> _cleanupConnection() async {
    try {
      // Cancel all subscriptions
      await notifySubscription?.cancel();
      await connectionSubscription?.cancel();
      
      // Disable notifications
      if (notifyChar != null) {
        try {
          await notifyChar!.setNotifyValue(false);
        } catch (e) {
          print("Warning: Could not disable notifications: $e");
        }
      }
      
      // Disconnect device
      if (connectedDevice != null) {
        try {
          await connectedDevice!.disconnect();
        } catch (e) {
          print("Warning: Could not disconnect device: $e");
        }
      }
      
      // Clear references
      connectedDevice = null;
      notifyChar = null;
      writeChar = null;
      notifySubscription = null;
      connectionSubscription = null;
      
      setState(() {
        isConnected = false;
      });
      
      print("🧹 Connection cleanup complete");
    } catch (e) {
      print("⚠️ Error during cleanup: $e");
    }
  }

  Future<void> _setupNotifications() async {
    try {
      // First check if device is already connected
      List<BluetoothDevice> devices = await FlutterBluePlus.connectedSystemDevices;
      
      BluetoothDevice? targetDevice;
      
      // Look for our specific device among connected devices
      for (BluetoothDevice device in devices) {
        if (device.name.contains("Deez") || device.name.contains("EMG_Logger")) {
          targetDevice = device;
          print("✅ Found already connected device: ${device.name}");
          break;
        }
      }
      
      // If not found in connected devices, scan for it
      if (targetDevice == null) {
        setState(() {
          connectionStatus = "Scanning...";
        });
        
        targetDevice = await _scanForDevice();
      }
      
      if (targetDevice != null) {
        await _connectToDevice(targetDevice);
      } else {
        setState(() {
          isConnected = false;
          connectionStatus = "Device Not Found";
        });
      }
    } catch (e) {
      print("⚠️ Error in setupNotifications: $e");
      setState(() {
        isConnected = false;
        connectionStatus = "Connection Error";
      });
    }
  }

  Future<BluetoothDevice?> _scanForDevice() async {
    BluetoothDevice? foundDevice;
    
    try {
      // Stop any existing scans
      await FlutterBluePlus.stopScan();
      
      // Set up scan result listener
      StreamSubscription? scanSubscription;
      
      scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult result in results) {
          print("Found device: ${result.device.name} - ${result.device.id}");
          
          if (result.device.name.contains("Deez") || 
              result.device.name.contains("EMG_Logger")) {
            foundDevice = result.device;
            print("✅ Target device found: ${result.device.name}");
            FlutterBluePlus.stopScan();
            scanSubscription?.cancel();
            return;
          }
        }
      });
      
      // Start scanning
      print("🔍 Starting BLE scan...");
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [], // Scan for all devices
      );
      
      // Wait for scan to complete
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
      
      // Clean up subscription
      await scanSubscription?.cancel();
      
    } catch (e) {
      print("⚠️ Scan error: $e");
    }
    
    return foundDevice;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      connectedDevice = device;
      
      // Connect if not already connected
      if (device.connectionState != BluetoothConnectionState.connected) {
        setState(() {
          connectionStatus = "Connecting...";
        });
        
        print("🔌 Connecting to ${device.name}...");
        await device.connect(timeout: const Duration(seconds: 15));
      }
       
      // CRITICAL: Request maximum MTU size for Android
      try {
        int mtu = await device.requestMtu(247); // Maximum BLE MTU
        print("✅ MTU negotiated: $mtu bytes");
      } catch (e) {
        print("⚠️ MTU negotiation failed: $e");
      }

      // Set connection priority to high speed
      try {
        await device.requestConnectionPriority(connectionPriorityRequest: ConnectionPriority.high);
        print("✅ High speed connection priority set");
      } catch (e) {
        print("⚠️ Connection priority failed: $e");
      }

      // Set up connection state monitoring
      connectionSubscription = device.connectionState.listen((state) {
        _handleConnectionStateChange(state);
      });
      
      // Discover services and characteristics
      print("🔍 Discovering services...");
      List<BluetoothService> services = await device.discoverServices();
      
      bool foundService = false;
      for (BluetoothService service in services) {
        print("Found service: ${service.uuid}");
        
        if (service.uuid.toString() == serviceUUID) {
          foundService = true;
          print("✅ Found target service!");
          
          for (BluetoothCharacteristic c in service.characteristics) {
            print("Found characteristic: ${c.uuid}");
            
            if (c.uuid.toString() == charUUID) {
              if (c.properties.notify) {
                notifyChar = c;
                await notifyChar!.setNotifyValue(true);
                notifySubscription = notifyChar!.onValueReceived.listen(_handleNotification);
                print("✅ Notifications enabled");
              }
              if (c.properties.write) {
                writeChar = c;
                print("✅ Write characteristic found");
              }
            }
          }
          break;
        }
      }
      
      if (!foundService) {
        throw Exception("Target service not found");
      }
      
      setState(() {
        isConnected = true;
        connectionStatus = "Connected";
      });
      
      print("✅ Successfully connected to ${device.name}");
      
      // REMOVED: No automatic sync on reconnection
      // The sync will only happen when user saves the workout
      
    } catch (e) {
      print("⚠️ Connection error: $e");
      setState(() {
        isConnected = false;
        connectionStatus = "Connection Failed";
      });
      
      // Clean up on connection failure
      await _cleanupConnection();
    }
  }

  void _handleConnectionStateChange(BluetoothConnectionState state) {
    setState(() {
      isConnected = state == BluetoothConnectionState.connected;
      connectionStatus = isConnected ? "Connected" : "Disconnected";
    });
    
    if (!isConnected) {
      if (isRecording) {
        hadDisconnectDuringRecording = true;
        print("🔌 Connection lost during recording. Will need to sync on save.");
    } else {
        print("🔌 Connection lost while not recording.");
    }
    }
  }

  // Modified to be called only during save process
  Future<bool> _requestDataSync() async {
    if (!isConnected || writeChar == null) {
      print("⚠️ Cannot sync - device not connected");
      return false;
    }
    
    setState(() {
      isSyncing = true;
    });
    
    // Clear any existing synced data before new sync
    syncedEmgData.clear();
    hasSyncedData = false;
    
    try {
      await _sendBLECommand("sync_request");
      print("🔄 Sync request sent to device during save process");
      
      // Wait for sync to complete (with timeout)
      int timeoutSeconds = 30;
      int elapsedSeconds = 0;
      
      while (isSyncing && elapsedSeconds < timeoutSeconds) {
        await Future.delayed(const Duration(seconds: 1));
        elapsedSeconds++;
      }
      
      if (isSyncing) {
        print("⚠️ Sync timeout after $timeoutSeconds seconds");
        setState(() {
          isSyncing = false;
        });
        return false;
      }
      
      return hasSyncedData;
      
    } catch (e) {
      print("⚠️ Failed to send sync request: $e");
      setState(() {
        isSyncing = false;
      });
      return false;
    }
  }

  // Convert EMG data to CSV format for API upload
  String _convertEMGDataToCSV() {
    if (emgData.isEmpty) return "";
    
    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln("timestamp_ms,emg_value");
    
    // Generate timestamps assuming 1kHz sampling rate
    int startTime = startTimestamp ?? 0;
    for (int i = 0; i < emgData.length; i++) {
      int timestampMs = startTime + i; // 1ms per sample (1kHz)
      csvBuffer.writeln("$timestampMs,${emgData[i]}");
    }
    
    return csvBuffer.toString();
  }

  void _handleNotification(List<int> value) {
    if (isSyncing) {
      // Handle sync data
      if (value.length > 4) {
        String dataStr = String.fromCharCodes(value);
        if (dataStr == "sync_complete") {
          setState(() {
            isSyncing = false;
          });
          
          // Replace local data entirely with synced data
          _replaceLiveDataWithSynced();
          print("✅ Data synchronization complete - local data replaced");
          return;
        }
        
        // Parse binary EMG data from sync
        _parseBinaryEMGData(value);
        return;
      }
    }
    
    // Handle normal live data packets (only if we don't have synced data)
    if (!hasSyncedData && value.length == 20) {
      final byteData = ByteData.sublistView(Uint8List.fromList(value));
       
      
      for (int i = 0; i < 10; i++) {
        int sample = byteData.getInt16(i * 2, Endian.little);
        newSamples.add(sample);
        emgData.add(sample);
        
        // Log to temp file if recording
        if (isRecording && tempSink != null) {
          tempSink!.writeln(sample);
        }
      }
      
      // Keep only last 300 samples for display
      if (newSamples.length > 300) {
        newSamples.removeRange(0, newSamples.length - 300);
      }
      
      setState(() {
        latestValue = newSamples.last.toString();
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

  void _parseBinaryEMGData(List<int> binaryData) {
    // Parse binary data (2 bytes per EMG sample, no timestamps)
    for (int i = 0; i < binaryData.length; i += 2) {
      if (i + 1 < binaryData.length) {
        // Extract EMG value (2 bytes, little endian)
        int emgValue = (binaryData[i + 1] << 8) | binaryData[i];
        if (emgValue > 32767) emgValue -= 65536; // Convert to signed
        
        syncedEmgData.add(emgValue);
      }
    }
    
    print("📊 Parsed ${syncedEmgData.length} EMG samples from sync");
  }
  
  void _replaceLiveDataWithSynced() {
    if (syncedEmgData.isEmpty) {
      print("⚠️ No synced data to replace with");
      return;
    }
    
    print("🔄 Replacing ${emgData.length} live samples with ${syncedEmgData.length} synced samples");
    
    // Completely replace live data with synced data
    emgData.clear();
    emgData.addAll(syncedEmgData);
    
    
    
    // Mark that we now have synced data
    hasSyncedData = true;
    
    // Clear synced data buffer
    syncedEmgData.clear();
    
    setState(() {
      if (emgData.isNotEmpty) {
        latestValue = emgData.last.toString();
      }
    });
    
    print("✅ Successfully replaced live data with ${emgData.length} synced samples");
  }

  Future<void> _sendBLECommand(String command) async {
    if (writeChar != null && isConnected) {
      try {
        await writeChar!.write(command.codeUnits, withoutResponse: false);
        print("📤 Sent BLE command: $command");
      } catch (e) {
        print("⚠️ Failed to send BLE command: $e");
      }
    }
  }

  void _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      await _sendBLECommand("stop");
      setState(() => isRecording = false);
      
      _showSaveDialog();
      
    } else {
      // Start recording
      // Clear previous data
      emgData.clear();
      syncedEmgData.clear();
      hasSyncedData = false;
      hadDisconnectDuringRecording = false; // Reset disconnect flag
      
      startTimestamp = null;
      
      await _sendBLECommand("start");
      setState(() => isRecording = true);
      
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Recording started. Device will log to SD card until reconnection."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSaveDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Save Workout?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Would you like to save or discard this recording?"),
          if (hadDisconnectDuringRecording && !isConnected)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "⚠️ Device disconnected during recording. Reconnect to sync complete SD card data.",
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          if (hadDisconnectDuringRecording && isConnected)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "ℹ️ Will sync missing data from SD card before saving.",
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
          if (!hadDisconnectDuringRecording)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "✅ No disconnections detected. Will save live data directly.",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
        ],
      ),
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

  // Updated save workout with sync-then-upload workflow
  // Updated save workout with conditional sync based on disconnection history
Future<void> _saveWorkout() async {
  Navigator.of(context).pop();
  
  setState(() {
    isSavingWorkout = true;
  });
  
  try {
    // Step 1: Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_getSaveProgressText()),
          ],
        ),
      ),
    );
    
    // Step 2: Determine if sync is needed
    bool needsSync = hadDisconnectDuringRecording;
    bool syncSuccessful = false;
    
    if (needsSync) {
      print("📊 Disconnection detected during recording. Attempting sync...");
      
      if (isConnected) {
        setState(() {
          connectionStatus = "Syncing for Save...";
        });
        
        syncSuccessful = await _requestDataSync();
        
        if (syncSuccessful) {
          print("✅ Successfully synced data for save");
        } else {
          print("⚠️ Sync failed, using available live data");
        }
      } else {
        print("📱 Device not connected, cannot sync. Using available live data only.");
        
        // Show warning that some data might be missing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Device disconnected - some data may be missing from save."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      print("✅ No disconnections during recording. Using complete live data.");
    }
    
    // Step 3: Validate we have data to save
    if (emgData.isEmpty) {
      Navigator.of(context).pop(); // Close progress dialog
      setState(() {
        isSavingWorkout = false;
        connectionStatus = isConnected ? "Connected" : "Disconnected";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No EMG data to save!")),
      );
      return;
    }
    
    // Step 4: Upload the data
    await _uploadWorkoutData();
    
    Navigator.of(context).pop(); // Close progress dialog
    
  } catch (e) {
    Navigator.of(context).pop(); // Close progress dialog
    print("⚠️ Save workflow error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving workout: $e")),
    );
  } finally {
    setState(() {
      isSavingWorkout = false;
      connectionStatus = isConnected ? "Connected" : "Disconnected";
    });
  }
}

String _getSaveProgressText() {
  if (isSyncing) {
    return "Syncing missing data from SD card...";
  } else if (isSavingWorkout && !hadDisconnectDuringRecording) {
    return "Uploading complete live data...";
  } else if (isSavingWorkout) {
    return "Uploading workout data...";
  }
  return "Preparing save...";
}

  
  Future<void> _uploadWorkoutData() async {
  if (startTimestamp == null || latestTimestamp == null) {
    throw Exception("Missing timestamp data");
  }

  // Create CSV data from EMG values
  String csvData = _convertEMGDataToCSV();
  
  if (csvData.isEmpty) {
    throw Exception("No EMG data to upload");
  }
  
  // Write CSV data to temporary file
  final dir = await getTemporaryDirectory();
  final csvFile = File('${dir.path}/emg_workout_${DateTime.now().millisecondsSinceEpoch}.csv');
  await csvFile.writeAsString(csvData);
  
  final user = await Amplify.Auth.getCurrentUser();
  final userId = user.userId;

  final duration = ((latestTimestamp! - startTimestamp!) / 1000).round();
  final key = 'emg/$userId/${DateTime.now().toIso8601String()}.csv';

  final operation = Amplify.Storage.uploadFile(
    localFile: AWSFile.fromPath(csvFile.path),
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
  
  // Clean up temporary file
  await csvFile.delete();
  
  print("Mutation response: ${response.data}");
  print("Mutation errors: ${response.errors}");

  // Updated success message based on data source
  String successMessage;
  if (!hadDisconnectDuringRecording) {
    successMessage = "Workout saved with complete live data!";
  } else if (hasSyncedData) {
    successMessage = "Workout saved with synced SD card data!";
  } else {
    successMessage = "Workout saved (some data may be missing due to disconnection)!";
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(successMessage)),
  );
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
      case "Connected":
        return Colors.green;
      case "Connecting...":
      case "Reconnecting...":
        return Colors.orange;
      case "Syncing Data...":
      case "Syncing for Save...":
        return Colors.blue;
      default:
        return Colors.red;
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
            // Connection Status Card
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
                    if (isSyncing || isSavingWorkout) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              "Live EMG Data", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            
            const SizedBox(height: 16),
            
            Text(
              "Current Value: $latestValue", 
              style: const TextStyle(fontSize: 20)
            ),
            
            if (latestTimestamp != null)
              Text(
                "Timestamp: ${latestTimestamp!} ms", 
                style: const TextStyle(fontSize: 16)
              ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: CustomPaint(
                painter: EMGPainter(newSamples),
                child: Container(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: isSavingWorkout ? null : _toggleRecording, // Disable during save
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                isRecording ? "Stop Recording" : "Start Recording",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            
            if (isRecording && !isConnected)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "⚠️ Recording to SD card (disconnected)",
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
              
            if (isSavingWorkout)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "💾 Saving workout...",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
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
