import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/vehicle_provider.dart';
import '../../core/themes/app_colors.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
                l10n.myVehicle,
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
                onPressed: () => _showNotifications(context, l10n),
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
                  _buildConnectionStatus(vehicleProvider, l10n),
                  const SizedBox(height: 24),
                  _buildWelcomeSection(l10n),
                  const SizedBox(height: 24),
                  Text(
                    l10n.vehicleHealth,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHealthGrid(vehicleProvider, l10n),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, vehicleProvider, l10n),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AppLocalizations l10n) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.allSystemsGo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.engineCond,
                  style: const TextStyle(
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

  Widget _buildConnectionStatus(VehicleProvider vehicleProvider, AppLocalizations l10n) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (vehicleProvider.status) {
      case VehicleStatus.connected:
        statusColor = AppColors.success;
        statusText = l10n.systemConnected;
        statusIcon = Icons.bluetooth_connected_rounded;
        break;
      case VehicleStatus.connecting:
        statusColor = AppColors.warning;
        statusText = l10n.searchingObd;
        statusIcon = Icons.bluetooth_searching_rounded;
        break;
      case VehicleStatus.disconnected:
        statusColor = AppColors.error;
        statusText = l10n.systemOffline;
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
              child: Text(l10n.connectNow),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthGrid(VehicleProvider vehicleProvider, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        GlassHealthCard(
          title: l10n.engineHealthStats, // Using standardized key
          value: '${vehicleProvider.engineHealth.toInt()}%',
          icon: Icons.settings_input_component_rounded,
          color: _getHealthColor(vehicleProvider.engineHealth),
          onTap: () {},
        ),
        GlassHealthCard(
          title: 'Battery', // Should be l10n.batteryVoltage but kept simple 'Battery' in UI often preferred, using l10n if available: l10n.batteryVoltage
          value: '${vehicleProvider.batteryVoltage.toStringAsFixed(1)}V',
          icon: Icons.battery_charging_full_rounded,
          color: _getBatteryColor(vehicleProvider.batteryVoltage),
          onTap: () {},
        ),
        GlassHealthCard(
          title: 'Fuel Level', // Could map to l10n if added
          value: '${vehicleProvider.fuelLevel.toInt()}%',
          icon: Icons.local_gas_station_rounded,
          color: _getFuelColor(vehicleProvider.fuelLevel),
          onTap: () {},
        ),
        GlassHealthCard(
          title: 'Mileage', // Could map to l10n
          value: '${vehicleProvider.mileage} km',
          icon: Icons.speed_rounded,
          color: AppColors.primary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, VehicleProvider vehicleProvider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.smartDiagnostics,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAnimatedActionButton(
              icon: Icons.search_rounded,
              label: l10n.fullScan,
              color: AppColors.primary,
              onTap: () {
                if (vehicleProvider.status == VehicleStatus.connected) {
                  vehicleProvider.refreshVehicleData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.refreshData)),
                  );
                } else {
                  _navigateToDeviceSelection(context);
                }
              },
            ),
            const SizedBox(width: 16),
            _buildAnimatedActionButton(
              icon: Icons.history_rounded,
              label: l10n.history,
              color: AppColors.secondary,
              onTap: () {
                 // Navigation to history handled by main tabs usually, or we can show a summary dialog
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
              },
            ),
            const SizedBox(width: 16),
            _buildAnimatedActionButton(
              icon: Icons.build_rounded,
              label: l10n.service,
              color: AppColors.accent,
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
              },
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

  void _navigateToDeviceSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceSelectionScreen()),
    );
  }

  void _showSettingsMenu(BuildContext context) {
      // Helper specific to this widget if needed or reuse shared
  }

  void _showNotifications(BuildContext context, AppLocalizations l10n) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.notifications)));
  }
}
