import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/vehicle_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7 Days';
  final List<String> _periods = ['7 Days', '30 Days', '90 Days', '1 Year'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom App Bar for Analytics
        Container(
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
          color: Theme.of(context).primaryColor,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: Theme.of(context).primaryColor,
                style: const TextStyle(color: Colors.white),
                items: _periods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPeriod = newValue!;
                  });
                },
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    _buildSummaryCard(
                      'Total Distance',
                      '${vehicleProvider.mileage} km',
                      Icons.speed,
                      const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      'Avg Fuel Economy',
                      '8.5 L/100km',
                      Icons.local_gas_station,
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard(
                      'Total Trips',
                      '24',
                      Icons.directions_car,
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      'Avg Speed',
                      '65 km/h',
                      Icons.speed,
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Fuel Consumption Chart
                _buildChartCard(
                  'Fuel Consumption',
                  'Liters per 100km',
                  _buildFuelChart(),
                ),

                const SizedBox(height: 24),

                // Engine Health Trend
                _buildChartCard(
                  'Engine Health Trend',
                  'Health percentage over time',
                  _buildHealthChart(),
                ),

                const SizedBox(height: 24),

                // Battery Voltage Chart
                _buildChartCard(
                  'Battery Voltage',
                  'Voltage over time',
                  _buildBatteryChart(),
                ),

                const SizedBox(height: 24),

                // Trip History
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Trips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTripItem('Today 2:30 PM', '12.5 km', '8.2 L/100km', '45 min'),
                        _buildTripItem('Yesterday 9:15 AM', '28.7 km', '7.9 L/100km', '32 min'),
                        _buildTripItem('Yesterday 6:45 PM', '15.3 km', '9.1 L/100km', '28 min'),
                        _buildTripItem('2 days ago', '42.1 km', '8.5 L/100km', '58 min'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    ],
  );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}L');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 8.5),
              const FlSpot(1, 8.2),
              const FlSpot(2, 9.1),
              const FlSpot(3, 7.8),
              const FlSpot(4, 8.7),
              const FlSpot(5, 8.3),
              const FlSpot(6, 8.9),
            ],
            isCurved: true,
            color: const Color(0xFF10B981),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF10B981).withOpacity(0.1),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 85),
              const FlSpot(1, 87),
              const FlSpot(2, 83),
              const FlSpot(3, 89),
              const FlSpot(4, 86),
              const FlSpot(5, 88),
              const FlSpot(6, 85),
            ],
            isCurved: true,
            color: const Color(0xFF2563EB),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2563EB).withOpacity(0.1),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toStringAsFixed(1)}V');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 12.6),
              const FlSpot(1, 12.8),
              const FlSpot(2, 12.4),
              const FlSpot(3, 12.9),
              const FlSpot(4, 12.7),
              const FlSpot(5, 12.5),
              const FlSpot(6, 12.6),
            ],
            isCurved: true,
            color: const Color(0xFFF59E0B),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFF59E0B).withOpacity(0.1),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTripItem(String date, String distance, String fuelEconomy, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$distance • $fuelEconomy • $duration',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
