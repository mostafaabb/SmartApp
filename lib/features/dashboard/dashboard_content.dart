import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../widgets/health_card.dart';
import '../../widgets/alert_banner.dart';
import '../device_selection/device_selection_screen.dart';
import '../../widgets/glass_health_card.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Vehicle',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                onPressed: () => _showSettingsMenu(context),
                icon: const Icon(Icons.settings_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionStatus(vehicleProvider),
                  const SizedBox(height: 24),
                  _buildWelcomeSection(),
                  const SizedBox(height: 24),
                  const Text(
                    'Vehicle Health',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHealthGrid(vehicleProvider),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 100), // Spacing for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Systems Go',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your engine is in peak condition',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(VehicleProvider vehicleProvider) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (vehicleProvider.status) {
      case VehicleStatus.connected:
        statusColor = AppColors.success;
        statusText = 'System Connected';
        statusIcon = Icons.bluetooth_connected_rounded;
        break;
      case VehicleStatus.connecting:
        statusColor = AppColors.warning;
        statusText = 'Searching for OBD-II...';
        statusIcon = Icons.bluetooth_searching_rounded;
        break;
      case VehicleStatus.disconnected:
        statusColor = AppColors.error;
        statusText = 'System Offline';
        statusIcon = Icons.bluetooth_disabled_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (vehicleProvider.status == VehicleStatus.disconnected)
            TextButton(
              onPressed: () => _navigateToDeviceSelection(context),
              child: const Text('Connect Now'),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthGrid(VehicleProvider vehicleProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        GlassHealthCard(
          title: 'Engine Health',
          value: '${vehicleProvider.engineHealth.toInt()}%',
          icon: Icons.settings_input_component_rounded,
          color: _getHealthColor(vehicleProvider.engineHealth),
          onTap: () => _navigateToDetail('Engine'),
        ),
        GlassHealthCard(
          title: 'Battery',
          value: '${vehicleProvider.batteryVoltage.toStringAsFixed(1)}V',
          icon: Icons.battery_charging_full_rounded,
          color: _getBatteryColor(vehicleProvider.batteryVoltage),
          onTap: () => _navigateToDetail('Battery'),
        ),
        GlassHealthCard(
          title: 'Fuel Level',
          value: '${vehicleProvider.fuelLevel.toInt()}%',
          icon: Icons.local_gas_station_rounded,
          color: _getFuelColor(vehicleProvider.fuelLevel),
          onTap: () => _navigateToDetail('Fuel'),
        ),
        GlassHealthCard(
          title: 'Mileage',
          value: '${vehicleProvider.mileage} km',
          icon: Icons.speed_rounded,
          color: AppColors.primary,
          onTap: () => _navigateToDetail('Mileage'),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Diagnostics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAnimatedActionButton(
              icon: Icons.search_rounded,
              label: 'Full Scan',
              color: AppColors.primary,
              onTap: () {},
            ),
            const SizedBox(width: 16),
            _buildAnimatedActionButton(
              icon: Icons.history_rounded,
              label: 'History',
              color: AppColors.secondary,
              onTap: () {},
            ),
            const SizedBox(width: 16),
            _buildAnimatedActionButton(
              icon: Icons.build_rounded,
              label: 'Service',
              color: AppColors.accent,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  Color _getHealthColor(double health) {
    if (health >= 85) return AppColors.success;
    if (health >= 70) return AppColors.warning;
    return AppColors.error;
  }

  Color _getBatteryColor(double voltage) {
    if (voltage >= 12.6) return AppColors.success;
    if (voltage >= 12.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _getFuelColor(double level) {
    if (level >= 30) return AppColors.success;
    if (level >= 15) return AppColors.warning;
    return AppColors.error;
  }

  void _navigateToDetail(String type) {}

  void _navigateToDeviceSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceSelectionScreen()),
    );
  }

  void _showSettingsMenu(BuildContext context) {}

  void _showNotifications(BuildContext context) {}
}
