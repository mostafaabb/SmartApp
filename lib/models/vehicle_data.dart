class VehicleData {
  final double engineHealth;
  final double batteryVoltage;
  final double fuelLevel;
  final int mileage;
  final double engineTemp;
  final int engineRPM;
  final double vehicleSpeed;
  final DateTime lastUpdated;

  VehicleData({
    required this.engineHealth,
    required this.batteryVoltage,
    required this.fuelLevel,
    required this.mileage,
    required this.engineTemp,
    required this.engineRPM,
    required this.vehicleSpeed,
    required this.lastUpdated,
  });

  VehicleData copyWith({
    double? engineHealth,
    double? batteryVoltage,
    double? fuelLevel,
    int? mileage,
    double? engineTemp,
    int? engineRPM,
    double? vehicleSpeed,
    DateTime? lastUpdated,
  }) {
    return VehicleData(
      engineHealth: engineHealth ?? this.engineHealth,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      mileage: mileage ?? this.mileage,
      engineTemp: engineTemp ?? this.engineTemp,
      engineRPM: engineRPM ?? this.engineRPM,
      vehicleSpeed: vehicleSpeed ?? this.vehicleSpeed,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'engineHealth': engineHealth,
      'batteryVoltage': batteryVoltage,
      'fuelLevel': fuelLevel,
      'mileage': mileage,
      'engineTemp': engineTemp,
      'engineRPM': engineRPM,
      'vehicleSpeed': vehicleSpeed,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      engineHealth: json['engineHealth']?.toDouble() ?? 0.0,
      batteryVoltage: json['batteryVoltage']?.toDouble() ?? 0.0,
      fuelLevel: json['fuelLevel']?.toDouble() ?? 0.0,
      mileage: json['mileage'] ?? 0,
      engineTemp: json['engineTemp']?.toDouble() ?? 0.0,
      engineRPM: json['engineRPM'] ?? 0,
      vehicleSpeed: json['vehicleSpeed']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'VehicleData(engineHealth: $engineHealth, batteryVoltage: $batteryVoltage, fuelLevel: $fuelLevel, mileage: $mileage, engineTemp: $engineTemp, engineRPM: $engineRPM, vehicleSpeed: $vehicleSpeed, lastUpdated: $lastUpdated)';
  }
}
