import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/themes/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class MechanicsScreen extends StatefulWidget {
  const MechanicsScreen({super.key});

  @override
  State<MechanicsScreen> createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> {
  String _selectedService = 'All Services';
  // Note: For full localization, these service names would also need to be keys or mapped
  final List<String> _services = ['All Services', 'Oil Change', 'Tire Service', 'Brake Repair', 'Engine Repair', 'Diagnostics'];

  final List<Map<String, dynamic>> _mechanics = [
    {
      'name': 'AutoCare Plus',
      'distance': '2.3 km',
      'rating': 4.8,
      'reviews': 124,
      'specialties': ['Oil Change', 'Brake Repair', 'Diagnostics'],
      'address': '123 Main St, Downtown',
      'phone': '+15551234567',
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
      'phone': '+15552345678',
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
      'phone': '+15553456789',
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
      'phone': '+15554567890',
      'hours': 'Tue-Sun: 9AM-5PM',
      'isOpen': true,
    },
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $phoneNumber')),
        );
      }
    }
  }

  Future<void> _openMap(String address) async {
    // Using a generalized query for map apps
    final Uri launchUri = Uri(
      scheme: 'geo',
      path: '0,0',
      queryParameters: {'q': address},
    );
    // Fallback/alternative for Android/iOS specific schemes might be needed in production
    // For now, try generic intent or web fallback
    final Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri);
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Simple filter matching
    final filteredMechanics = _selectedService == 'All Services'
        ? _mechanics
        : _mechanics.where((mechanic) =>
            (mechanic['specialties'] as List<String>).contains(_selectedService)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  l10n.nearbyMechanics,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedService,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      items: _services.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'All Services' ? l10n.allServices : value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedService = newValue!;
                        });
                      },
                      icon: Icon(Icons.filter_list_rounded, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Map Placeholder
                  Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=40.7128,-74.0060&zoom=13&size=600x300&maptype=roadmap&key=YOUR_API_KEY'), 
                        fit: BoxFit.cover,
                        opacity: 0.8,
                      ),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: InkWell(
                            onTap: () => _openMap('Downtown'), // Placeholder map open
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Explore Map',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mechanics List
                  ...filteredMechanics.map((mechanic) => _buildMechanicCard(mechanic, l10n)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicCard(Map<String, dynamic> mechanic, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.store_mall_directory_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mechanic['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${mechanic['rating']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${mechanic['reviews']} reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Open/Closed Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: mechanic['isOpen'] ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mechanic['isOpen'] ? l10n.open : l10n.closed,
                  style: TextStyle(
                    color: mechanic['isOpen'] ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Info Row
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                mechanic['distance'],
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 12, color: AppColors.border),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Until 6 PM', 
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Address
          Text(
            mechanic['address'],
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Specialties Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (mechanic['specialties'] as List<String>).map((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _makePhoneCall(mechanic['phone']),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.call, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openMap(mechanic['address']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.directions, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
