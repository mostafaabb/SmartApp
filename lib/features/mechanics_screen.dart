import 'package:flutter/material.dart';

class MechanicsScreen extends StatefulWidget {
  const MechanicsScreen({super.key});

  @override
  State<MechanicsScreen> createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> {
  String _selectedService = 'All Services';
  final List<String> _services = ['All Services', 'Oil Change', 'Tire Service', 'Brake Repair', 'Engine Repair', 'Diagnostics'];

  final List<Map<String, dynamic>> _mechanics = [
    {
      'name': 'AutoCare Plus',
      'distance': '2.3 km',
      'rating': 4.8,
      'reviews': 124,
      'specialties': ['Oil Change', 'Brake Repair', 'Diagnostics'],
      'address': '123 Main St, Downtown',
      'phone': '+1 (555) 123-4567',
      'hours': 'Mon-Fri: 8AM-6PM',
      'isOpen': true,
    },
    {
      'name': 'Speedy Auto Service',
      'distance': '3.1 km',
      'rating': 4.6,
      'reviews': 89,
      'specialties': ['Tire Service', 'Engine Repair'],
      'address': '456 Oak Ave, Midtown',
      'phone': '+1 (555) 234-5678',
      'hours': 'Mon-Sat: 7AM-7PM',
      'isOpen': true,
    },
    {
      'name': 'Elite Motors',
      'distance': '4.7 km',
      'rating': 4.9,
      'reviews': 203,
      'specialties': ['Engine Repair', 'Diagnostics', 'Brake Repair'],
      'address': '789 Pine Rd, Uptown',
      'phone': '+1 (555) 345-6789',
      'hours': 'Mon-Fri: 8AM-6PM, Sat: 8AM-4PM',
      'isOpen': false,
    },
    {
      'name': 'Quick Fix Garage',
      'distance': '5.2 km',
      'rating': 4.4,
      'reviews': 67,
      'specialties': ['Oil Change', 'Tire Service'],
      'address': '321 Elm St, Suburb',
      'phone': '+1 (555) 456-7890',
      'hours': 'Tue-Sun: 9AM-5PM',
      'isOpen': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMechanics = _selectedService == 'All Services'
        ? _mechanics
        : _mechanics.where((mechanic) =>
            mechanic['specialties'].contains(_selectedService)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Mechanics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
          tooltip: 'Back to Dashboard',
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedService,
            items: _services.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedService = newValue!;
              });
            },
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Map Placeholder (would be replaced with Google Maps)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Interactive Map',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tap to view full map',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mechanics List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMechanics.length,
              itemBuilder: (context, index) {
                final mechanic = filteredMechanics[index];
                return _buildMechanicCard(mechanic);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // In a real app, this would get current location and find nearby mechanics
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Finding mechanics near your location...')),
          );
        },
        child: const Icon(Icons.my_location),
        tooltip: 'Find nearby mechanics',
      ),
    );
  }

  Widget _buildMechanicCard(Map<String, dynamic> mechanic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name, rating, and distance
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${mechanic['rating']} (${mechanic['reviews']} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mechanic['isOpen'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mechanic['isOpen'] ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: mechanic['isOpen'] ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Distance and specialties
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  mechanic['distance'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (mechanic['specialties'] as List<String>).map((specialty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Address and contact
            Text(
              mechanic['address'],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mechanic['hours'],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // In a real app, this would make a phone call
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${mechanic['phone']}')),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // In a real app, this would open directions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Getting directions to ${mechanic['name']}')),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
