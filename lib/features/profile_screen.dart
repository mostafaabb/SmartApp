import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedUnit = 'Metric';

  // Profile data
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.person,
      'title': 'Personal Information',
      'subtitle': 'Update your profile details',
      'action': 'profile',
    },
    {
      'icon': Icons.directions_car,
      'title': 'Vehicle Information',
      'subtitle': 'Manage your vehicle details',
      'action': 'vehicle',
    },
    {
      'icon': Icons.notifications,
      'title': 'Notifications',
      'subtitle': 'Manage alert preferences',
      'action': 'notifications',
    },
    {
      'icon': Icons.security,
      'title': 'Privacy & Security',
      'subtitle': 'Privacy settings and data',
      'action': 'privacy',
    },
    {
      'icon': Icons.help,
      'title': 'Help & Support',
      'subtitle': 'FAQs and customer support',
      'action': 'help',
    },
    {
      'icon': Icons.info,
      'title': 'About',
      'subtitle': 'App version and information',
      'action': 'about',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
          tooltip: 'Back to Dashboard',
        ),
        actions: [
          IconButton(
            onPressed: () => _showSettingsMenu(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(),

            const SizedBox(height: 32),

            // Menu Items
            _buildMenuItems(),

            const SizedBox(height: 32),

            // Settings Section
            _buildSettingsSection(),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Premium Member',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _editProfile(),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard('Total Trips', '24', Icons.directions_car),
        const SizedBox(width: 16),
        _buildStatCard('Total Distance', '1,247 km', Icons.speed),
        const SizedBox(width: 16),
        _buildStatCard('Member Since', 'Jan 2024', Icons.calendar_today),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Card(
      child: Column(
        children: _menuItems.map((item) {
          final isLast = item == _menuItems.last;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'],
                    color: const Color(0xFF2563EB),
                  ),
                ),
                title: Text(item['title']),
                subtitle: Text(item['subtitle']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _handleMenuTap(item['action']),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Toggle
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive alerts about your vehicle'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: const Color(0xFF2563EB),
            ),

            const Divider(),

            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark themes'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme switching coming soon!')),
                );
              },
              activeColor: const Color(0xFF2563EB),
            ),

            const Divider(),

            // Units Selection
            ListTile(
              title: const Text('Units'),
              subtitle: Text('Current: $_selectedUnit'),
              trailing: DropdownButton<String>(
                value: _selectedUnit,
                items: ['Metric', 'Imperial'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnit = newValue!;
                  });
                },
                underline: const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data refreshed!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Reconnect Device'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reconnecting to OBD-II device...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Issue reported. Thank you!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuTap(String action) {
    switch (action) {
      case 'profile':
        _showEditProfileDialog(context);
        break;
      case 'vehicle':
        _showVehicleInfoDialog(context);
        break;
      case 'notifications':
        _showNotificationSettings(context);
        break;
      case 'privacy':
        _showPrivacySettings(context);
        break;
      case 'help':
        _showHelpDialog(context);
        break;
      case 'about':
        _showAboutDialog(context);
        break;
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text;
                _userEmail = emailController.text;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showVehicleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Make: Toyota', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Model: Camry'),
            Text('Year: 2020'),
            SizedBox(height: 16),
            Text('VIN: 1HGBH41JXMN109186'),
            Text('License Plate: ABC-123'),
            SizedBox(height: 16),
            Text('Engine: 2.5L 4-Cylinder'),
            Text('Transmission: Automatic'),
            Text('Fuel Type: Gasoline'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, this would navigate to edit vehicle screen
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit vehicle info - Coming soon!')),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Engine Alerts'),
              subtitle: const Text('Notify when engine issues detected'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Engine alerts ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Maintenance Reminders'),
              subtitle: const Text('Oil change and service reminders'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Maintenance reminders ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Fuel Alerts'),
              subtitle: const Text('Low fuel and fuel efficiency tips'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fuel alerts ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Trip Summaries'),
              subtitle: const Text('End-of-trip performance reports'),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Trip summaries ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Data Usage'),
              subtitle: const Text('How we use your vehicle data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                _showDataUsageDialog(context);
              },
            ),
            ListTile(
              title: const Text('Location Permissions'),
              subtitle: const Text('Control location access'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location permissions - Coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Bluetooth Permissions'),
              subtitle: const Text('OBD-II device connectivity'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bluetooth permissions - Coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Download your trip history'),
              trailing: const Icon(Icons.download),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data export started...')),
                );
              },
            ),
            ListTile(
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your data'),
              trailing: const Icon(Icons.delete, color: Colors.red),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We collect and use your vehicle data to provide these services:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Real-time diagnostics and alerts'),
              Text('• Trip tracking and fuel efficiency analysis'),
              Text('• Maintenance reminders and scheduling'),
              Text('• Nearby mechanics recommendations'),
              Text('• Performance analytics and reporting'),
              SizedBox(height: 16),
              Text(
                'Your data is encrypted and stored securely. We never share personal vehicle information with third parties.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your trip data, vehicle information, and settings will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion initiated...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('How to connect OBD-II device'),
              subtitle: Text('Step-by-step connection guide'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              title: Text('Troubleshooting'),
              subtitle: Text('Common issues and solutions'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              title: Text('Contact Support'),
              subtitle: Text('Get help from our team'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            Divider(),
            ListTile(
              title: Text('FAQs'),
              subtitle: Text('Frequently asked questions'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Smart Vehicle Monitor'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A comprehensive vehicle health monitoring app with real-time diagnostics and OBD-II connectivity.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Real-time vehicle monitoring'),
            Text('• OBD-II diagnostics'),
            Text('• Trip analytics'),
            Text('• Nearby mechanics finder'),
            Text('• Maintenance reminders'),
            SizedBox(height: 16),
            Text('© 2024 Smart Vehicle Monitor'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile - Coming soon!')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
