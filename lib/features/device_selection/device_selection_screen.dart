import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../core/themes/app_colors.dart';

class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results.where((result) {
          final name = result.device.name.toLowerCase();
          // Filter for potential OBD-II devices
          return name.contains('obd') ||
                 name.contains('elm') ||
                 name.contains('vpee') ||
                 name.contains('autel') ||
                 name.contains('bluedriver') ||
                 name.contains('obdcheck') ||
                 result.advertisementData.serviceUuids.isNotEmpty;
        }).toList();
      });
    });

    // Start scanning
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );

    // Stop scanning after 15 seconds
    _scanTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        FlutterBluePlus.stopScan();
      }
    });
  }

  void _stopScan() {
    _scanTimer?.cancel();
    FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Connecting to device...'),
            ],
          ),
        ),
      );

      // Stop scanning
      _stopScan();

      // Connect using the provider
      await vehicleProvider.connectToVehicle();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected to OBD-II device!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(); // Go back to dashboard
      }

    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select OBD-II Device'),
        actions: [
          if (_isScanning)
            TextButton.icon(
              onPressed: _stopScan,
              icon: const Icon(Icons.stop, color: Colors.white),
              label: const Text('Stop', style: TextStyle(color: Colors.white)),
            )
          else
            TextButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Scan', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Setup Instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Ensure your OBD-II adapter is plugged into your vehicle\'s OBD-II port\n'
                  '2. Turn on your vehicle (engine can be off)\n'
                  '3. Put your OBD-II adapter in pairing mode\n'
                  '4. Tap "Scan" to find available devices\n'
                  '5. Select your OBD-II device from the list',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Scan status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                  color: _isScanning ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _isScanning
                      ? 'Scanning for OBD-II devices...'
                      : 'Scan complete. ${_scanResults.length} devices found.',
                  style: TextStyle(
                    color: _isScanning ? AppColors.primary : Colors.grey[600],
                    fontWeight: _isScanning ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (_isScanning) ...[
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

          // Device list
          Expanded(
            child: _scanResults.isEmpty && !_isScanning
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      return _buildDeviceTile(result);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? _stopScan : _startScan,
        icon: Icon(_isScanning ? Icons.stop : Icons.bluetooth_searching),
        label: Text(_isScanning ? 'Stop Scan' : 'Scan Devices'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No OBD-II devices found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your OBD-II adapter is:\n'
            '• Plugged into your vehicle\n'
            '• Powered on\n'
            '• In pairing mode\n'
            '• Within Bluetooth range',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(ScanResult result) {
    final device = result.device;
    final rssi = result.rssi;
    final isConnectable = result.advertisementData.connectable;

    // Determine signal strength color
    Color signalColor;
    if (rssi >= -50) {
      signalColor = Colors.green;
    } else if (rssi >= -70) {
      signalColor = Colors.orange;
    } else {
      signalColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.bluetooth,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          device.name.isNotEmpty ? device.name : 'Unknown Device',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.remoteId.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 16,
                  color: signalColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${rssi}dBm',
                  style: TextStyle(
                    fontSize: 12,
                    color: signalColor,
                  ),
                ),
                if (isConnectable) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Connectable',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _connectToDevice(device),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Connect'),
        ),
        onTap: () => _connectToDevice(device),
      ),
    );
  }
}
