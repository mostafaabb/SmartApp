import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/vehicle_data.dart';

enum OBDConnectionState { disconnected, connecting, connected, error }

class OBDService {
  static final OBDService _instance = OBDService._internal();
  factory OBDService() => _instance;
  OBDService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _obdCharacteristic;
  StreamSubscription<List<int>>? _dataSubscription;

  final StreamController<OBDConnectionState> _connectionController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _vehicleDataController = StreamController.broadcast();

  Stream<OBDConnectionState> get connectionState => _connectionController.stream;
  Stream<Map<String, dynamic>> get vehicleDataStream => _vehicleDataController.stream;

  OBDConnectionState _currentState = OBDConnectionState.disconnected;

  // OBD-II PIDs (Parameter IDs)
  static const Map<String, String> obdPids = {
    'engine_rpm': '010C',          // Engine RPM
    'vehicle_speed': '010D',       // Vehicle Speed
    'engine_temp': '0105',         // Engine Coolant Temperature
    'throttle_position': '0111',   // Throttle Position
    'fuel_level': '012F',          // Fuel Tank Level Input
    'battery_voltage': '0142',     // Control Module Voltage
    'intake_temp': '010F',         // Intake Air Temperature
    'maf_rate': '0110',            // MAF Air Flow Rate
    'fuel_pressure': '010A',       // Fuel Pressure
    'timing_advance': '010E',      // Timing Advance
  };

  Future<bool> scanAndConnect() async {
    try {
      _updateConnectionState(OBDConnectionState.connecting);

      // Start scanning for Bluetooth devices
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      // Wait for scan results
      await Future.delayed(const Duration(seconds: 2));

      // Get scan results
      final scanResults = await FlutterBluePlus.scanResults.first;

      // Look for OBD-II devices (common names)
      final obdDevices = scanResults.where((result) {
        final name = result.device.platformName.toLowerCase();
        return name.contains('obd') ||
               name.contains('elm') ||
               name.contains('vpee') ||
               name.contains('autel') ||
               name.contains('bluedriver') ||
               name.contains('obdcheck') ||
               result.advertisementData.serviceUuids.isNotEmpty;
      }).toList();

      if (obdDevices.isEmpty) {
        throw Exception('No OBD-II devices found. Make sure your OBD-II adapter is plugged in and in pairing mode.');
      }

      // Try to connect to the first found device
      final device = obdDevices.first.device;
      await connectToDevice(device);

      return true;
    } catch (e) {
      _updateConnectionState(OBDConnectionState.error);
      print('Scan and connect failed: $e');
      return false;
    } finally {
      FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connectedDevice = device;

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 10));

      // Discover services
      final services = await device.discoverServices();

      // Find OBD-II service and characteristic
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          // Look for characteristics that can read/write (common for OBD-II)
          if (characteristic.properties.read && characteristic.properties.write) {
            _obdCharacteristic = characteristic;
            break;
          }
        }
        if (_obdCharacteristic != null) break;
      }

      if (_obdCharacteristic == null) {
        throw Exception('OBD-II characteristic not found. Device may not be OBD-II compatible.');
      }

      // Set up data listener
      _setupDataListener();

      _updateConnectionState(OBDConnectionState.connected);

      // Start monitoring vehicle data
      startVehicleMonitoring();

    } catch (e) {
      _updateConnectionState(OBDConnectionState.error);
      print('Device connection failed: $e');
      rethrow;
    }
  }

  void _setupDataListener() {
    _dataSubscription?.cancel();
    _dataSubscription = _obdCharacteristic?.lastValueStream.listen((data) {
      try {
        final response = utf8.decode(data);
        final parsedData = _parseOBDResponse(response);
        if (parsedData.isNotEmpty) {
          _vehicleDataController.add(parsedData);
        }
      } catch (e) {
        print('Error parsing OBD data: $e');
      }
    });
  }

  Future<Map<String, dynamic>> requestOBDData(String pid) async {
    if (_obdCharacteristic == null || _currentState != OBDConnectionState.connected) {
      return {};
    }

    try {
      // Send OBD command
      final command = '$pid\r';
      await _obdCharacteristic!.write(utf8.encode(command));

      // Wait for response
      await Future.delayed(const Duration(milliseconds: 200));

      return {}; // Response will be handled by the stream listener
    } catch (e) {
      print('Error requesting OBD data for PID $pid: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> readAllParameters() async {
    final Map<String, dynamic> allData = {};

    try {
      // Read basic parameters
      final engineRPM = await _readEngineRPM();
      final vehicleSpeed = await _readVehicleSpeed();
      final engineTemp = await _readEngineTemp();
      final fuelLevel = await _readFuelLevel();
      final batteryVoltage = await _readBatteryVoltage();

      allData.addAll({
        'engineRPM': engineRPM,
        'vehicleSpeed': vehicleSpeed,
        'engineTemp': engineTemp,
        'fuelLevel': fuelLevel,
        'batteryVoltage': batteryVoltage,
        'timestamp': DateTime.now(),
      });

      // Calculate derived values
      final engineHealth = _calculateEngineHealth(engineTemp, engineRPM);
      final mileage = await _readMileage();

      allData.addAll({
        'engineHealth': engineHealth,
        'mileage': mileage,
      });

    } catch (e) {
      print('Error reading all parameters: $e');
    }

    return allData;
  }

  Future<int> _readEngineRPM() async {
    try {
      await requestOBDData(obdPids['engine_rpm']!);
      // In a real implementation, you'd wait for the response
      // For now, return a mock value that changes
      return 800 + (DateTime.now().millisecondsSinceEpoch % 1000);
    } catch (e) {
      return 0;
    }
  }

  Future<double> _readVehicleSpeed() async {
    try {
      await requestOBDData(obdPids['vehicle_speed']!);
      // Mock implementation
      return (DateTime.now().millisecondsSinceEpoch % 100).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _readEngineTemp() async {
    try {
      await requestOBDData(obdPids['engine_temp']!);
      // Mock implementation - normal operating temp is ~85-95°C
      return 85.0 + (DateTime.now().millisecondsSinceEpoch % 15);
    } catch (e) {
      return 25.0; // Ambient temperature if no data
    }
  }

  Future<double> _readFuelLevel() async {
    try {
      await requestOBDData(obdPids['fuel_level']!);
      // Mock implementation - fuel level changes slowly
      return 65.0 - (DateTime.now().millisecondsSinceEpoch % 10);
    } catch (e) {
      return 50.0;
    }
  }

  Future<double> _readBatteryVoltage() async {
    try {
      await requestOBDData(obdPids['battery_voltage']!);
      // Mock implementation - normal voltage is 12.5-14.5V
      return 12.5 + ((DateTime.now().millisecondsSinceEpoch % 200) / 100);
    } catch (e) {
      return 12.6;
    }
  }

  Future<int> _readMileage() async {
    // This would typically come from ECU memory
    // Mock implementation
    return 45230 + (DateTime.now().millisecondsSinceEpoch ~/ 100000);
  }

  double _calculateEngineHealth(double temp, int rpm) {
    // Simple health calculation based on temperature and RPM
    if (temp < 60 || temp > 110) return 60.0; // Overheating or cold
    if (rpm > 4000) return 70.0; // High RPM
    return 85.0; // Normal operation
  }

  Map<String, dynamic> _parseOBDResponse(String response) {
    final Map<String, dynamic> parsed = {};

    try {
      // Remove carriage returns and newlines
      final cleanResponse = response.trim();

      if (cleanResponse.length < 6) return parsed;

      // Basic OBD-II response format: XX XX XX XX...
      // First byte is mode + 0x40, second is PID

      final parts = cleanResponse.split(' ');
      if (parts.length < 2) return parsed;

      final mode = parts[0];
      final pid = parts[1];

      // Parse based on PID
      switch (pid.toUpperCase()) {
        case '0C': // Engine RPM
          if (parts.length >= 4) {
            final rpm = ((int.parse(parts[2], radix: 16) * 256) + int.parse(parts[3], radix: 16)) / 4.0;
            parsed['engineRPM'] = rpm.round();
          }
          break;

        case '0D': // Vehicle Speed
          if (parts.length >= 3) {
            parsed['vehicleSpeed'] = int.parse(parts[2], radix: 16).toDouble();
          }
          break;

        case '05': // Engine Coolant Temp
          if (parts.length >= 3) {
            parsed['engineTemp'] = int.parse(parts[2], radix: 16) - 40.0;
          }
          break;

        case '2F': // Fuel Level
          if (parts.length >= 3) {
            parsed['fuelLevel'] = (int.parse(parts[2], radix: 16) * 100) / 255;
          }
          break;

        case '42': // Control Module Voltage
          if (parts.length >= 4) {
            final voltage = ((int.parse(parts[2], radix: 16) * 256) + int.parse(parts[3], radix: 16)) / 1000.0;
            parsed['batteryVoltage'] = voltage;
          }
          break;
      }
    } catch (e) {
      print('Error parsing OBD response: $e');
    }

    return parsed;
  }

  void startVehicleMonitoring() {
    // Start periodic data collection
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_currentState == OBDConnectionState.connected) {
        final data = await readAllParameters();
        if (data.isNotEmpty) {
          _vehicleDataController.add(data);
        }
      }
    });
  }

  Future<void> disconnect() async {
    _dataSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _obdCharacteristic = null;
    _updateConnectionState(OBDConnectionState.disconnected);
  }

  void _updateConnectionState(OBDConnectionState state) {
    _currentState = state;
    _connectionController.add(state);
  }

  void dispose() {
    _dataSubscription?.cancel();
    _connectionController.close();
    _vehicleDataController.close();
    disconnect();
  }
}
