import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/services/obd_service.dart';
import '../models/vehicle_data.dart';

enum VehicleStatus { connected, disconnected, connecting }

class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? value;
  final DateTime timestamp;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.value,
    required this.timestamp,
  });
}

class AlertItem {
  final String title;
  final String message;
  final AlertType type;
  final DateTime timestamp;
  final bool isActive;

  AlertItem({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isActive = true,
  });
}

enum AlertType { critical, warning, info }

class VehicleProvider extends ChangeNotifier {
  final OBDService _obdService = OBDService();

  VehicleStatus _status = VehicleStatus.disconnected;
  VehicleData? _vehicleData;
  List<ActivityItem> _recentActivities = [];
  List<AlertItem> _activeAlerts = [];
  bool _isLoading = false;
  StreamSubscription? _dataSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters
  VehicleStatus get status => _status;
  VehicleData? get vehicleData => _vehicleData;
  List<ActivityItem> get recentActivities => _recentActivities;
  List<AlertItem> get activeAlerts => _activeAlerts;
  bool get isLoading => _isLoading;
  bool get hasActiveAlerts => _activeAlerts.where((alert) => alert.isActive).isNotEmpty;

  // Computed properties
  double get engineHealth => _vehicleData?.engineHealth ?? 0.0;
  double get batteryVoltage => _vehicleData?.batteryVoltage ?? 0.0;
  double get fuelLevel => _vehicleData?.fuelLevel ?? 0.0;
  int get mileage => _vehicleData?.mileage ?? 0;

  VehicleProvider() {
    _initializeService();
  }

  void _initializeService() {
    // Listen to connection state changes
    _connectionSubscription = _obdService.connectionState.listen((state) {
      switch (state) {
        case OBDConnectionState.connecting:
          _status = VehicleStatus.connecting;
          break;
        case OBDConnectionState.connected:
          _status = VehicleStatus.connected;
          _addActivity('OBD-II Connected', 'Successfully connected to vehicle', Icons.bluetooth_connected, Colors.green);
          break;
        case OBDConnectionState.disconnected:
          _status = VehicleStatus.disconnected;
          _addActivity('OBD-II Disconnected', 'Connection to vehicle lost', Icons.bluetooth_disabled, Colors.red);
          break;
        case OBDConnectionState.error:
          _status = VehicleStatus.disconnected;
          _addActivity('Connection Error', 'Failed to connect to vehicle', Icons.error, Colors.red);
          break;
      }
      notifyListeners();
    });

    // Listen to vehicle data updates
    _dataSubscription = _obdService.vehicleDataStream.listen((data) {
      _updateVehicleData(data);
    });

    // Initialize with default data
    _initializeDefaultData();
  }

  void _initializeDefaultData() {
    // Initialize with default/placeholder data
    _vehicleData = VehicleData(
      engineHealth: 0.0,
      batteryVoltage: 0.0,
      fuelLevel: 0.0,
      mileage: 0,
      engineTemp: 25.0, // Ambient temperature
      engineRPM: 0,
      vehicleSpeed: 0.0,
      lastUpdated: DateTime.now(),
    );

    // Initialize with some default activities
    _recentActivities = [
      ActivityItem(
        title: 'App Started',
        subtitle: 'Smart Vehicle Health Monitor initialized',
        icon: Icons.power,
        color: const Color(0xFF10B981),
        timestamp: DateTime.now(),
      ),
    ];

    notifyListeners();
  }

  void _updateVehicleData(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final now = DateTime.now();

    _vehicleData = VehicleData(
      engineHealth: data['engineHealth'] ?? _vehicleData?.engineHealth ?? 0.0,
      batteryVoltage: data['batteryVoltage'] ?? _vehicleData?.batteryVoltage ?? 0.0,
      fuelLevel: data['fuelLevel'] ?? _vehicleData?.fuelLevel ?? 0.0,
      mileage: data['mileage'] ?? _vehicleData?.mileage ?? 0,
      engineTemp: data['engineTemp'] ?? _vehicleData?.engineTemp ?? 25.0,
      engineRPM: data['engineRPM'] ?? _vehicleData?.engineRPM ?? 0,
      vehicleSpeed: data['vehicleSpeed'] ?? _vehicleData?.vehicleSpeed ?? 0.0,
      lastUpdated: now,
    );

    // Check for alerts based on new data
    _checkForAlerts();

    notifyListeners();
  }

  void _checkForAlerts() {
    if (_vehicleData == null) return;

    // Check engine temperature
    if (_vehicleData!.engineTemp > 105) {
      _addAlert('Engine Overheating', 'Engine temperature is too high: ${_vehicleData!.engineTemp.toStringAsFixed(1)}°C', AlertType.critical);
    } else if (_vehicleData!.engineTemp > 100) {
      _addAlert('High Engine Temperature', 'Engine temperature is elevated: ${_vehicleData!.engineTemp.toStringAsFixed(1)}°C', AlertType.warning);
    }

    // Check battery voltage
    if (_vehicleData!.batteryVoltage < 12.0) {
      _addAlert('Low Battery Voltage', 'Battery voltage is low: ${_vehicleData!.batteryVoltage.toStringAsFixed(1)}V', AlertType.warning);
    }

    // Check fuel level
    if (_vehicleData!.fuelLevel < 15) {
      _addAlert('Low Fuel Level', 'Fuel level is critically low: ${_vehicleData!.fuelLevel.toStringAsFixed(0)}%', AlertType.warning);
    }

    // Check engine RPM (if too high continuously)
    if (_vehicleData!.engineRPM > 4500) {
      _addAlert('High Engine RPM', 'Engine RPM is very high: ${_vehicleData!.engineRPM} RPM', AlertType.warning);
    }
  }

  Future<void> connectToVehicle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _obdService.scanAndConnect();

      if (success) {
        _addActivity('Connection Successful', 'Connected to OBD-II device', Icons.bluetooth_connected, Colors.green);
      } else {
        _addActivity('Connection Failed', 'Could not find or connect to OBD-II device', Icons.bluetooth_disabled, Colors.red);
      }
    } catch (e) {
      _status = VehicleStatus.disconnected;
      _addActivity('Connection Error', 'Error: ${e.toString()}', Icons.error, Colors.red);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> disconnectFromVehicle() async {
    try {
      await _obdService.disconnect();
      _addActivity('Disconnected', 'OBD-II connection closed', Icons.bluetooth_disabled, Colors.blue);
    } catch (e) {
      _addActivity('Disconnect Error', 'Error closing connection: ${e.toString()}', Icons.error, Colors.red);
    }
    notifyListeners();
  }

  Future<void> refreshVehicleData() async {
    if (_status != VehicleStatus.connected) {
      _addActivity('Refresh Failed', 'Not connected to vehicle', Icons.refresh, Colors.orange);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _obdService.readAllParameters();
      if (data.isNotEmpty) {
        _updateVehicleData(data);
        _addActivity('Data Refreshed', 'Vehicle data updated successfully', Icons.refresh, Colors.green);
      } else {
        _addActivity('Refresh Warning', 'No data received from vehicle', Icons.warning, Colors.orange);
      }
    } catch (e) {
      _addActivity('Refresh Error', 'Failed to refresh data: ${e.toString()}', Icons.error, Colors.red);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addActivity(String title, String subtitle, IconData icon, Color color, {String? value}) {
    final activity = ActivityItem(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      value: value,
      timestamp: DateTime.now(),
    );

    addActivity(activity);
  }

  void addActivity(ActivityItem activity) {
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 10) {
      _recentActivities.removeLast();
    }
    notifyListeners();
  }

  void _addAlert(String title, String message, AlertType type) {
    // Check if similar alert already exists
    final existingAlert = _activeAlerts.firstWhere(
      (alert) => alert.title == title && alert.isActive,
      orElse: () => AlertItem(title: '', message: '', type: AlertType.info, timestamp: DateTime.now()),
    );

    if (existingAlert.title.isEmpty) {
      final alert = AlertItem(
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
      );
      addAlert(alert);
    }
  }

  void addAlert(AlertItem alert) {
    _activeAlerts.insert(0, alert);
    notifyListeners();
  }

  void dismissAlert(int index) {
    if (index >= 0 && index < _activeAlerts.length) {
      _activeAlerts[index] = AlertItem(
        title: _activeAlerts[index].title,
        message: _activeAlerts[index].message,
        type: _activeAlerts[index].type,
        timestamp: _activeAlerts[index].timestamp,
        isActive: false,
      );
      notifyListeners();
    }
  }

  void clearAllAlerts() {
    _activeAlerts = _activeAlerts.map((alert) => AlertItem(
      title: alert.title,
      message: alert.message,
      type: alert.type,
      timestamp: alert.timestamp,
      isActive: false,
    )).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    _obdService.dispose();
    super.dispose();
  }
}
