import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'l10n/generated/app_localizations.dart'; // Import generated localizations
import 'core/themes/app_theme.dart';
import 'providers/vehicle_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart'; // Import ThemeProvider
import 'features/splash/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions for Bluetooth and location
  await _requestPermissions();

  runApp(const SmartVehicleApp());
}

Future<void> _requestPermissions() async {
  // Request Bluetooth permissions
  final bluetoothStatus = await Permission.bluetooth.request();
  final bluetoothScanStatus = await Permission.bluetoothScan.request();
  final bluetoothConnectStatus = await Permission.bluetoothConnect.request();

  // Request location permissions (required for Bluetooth scanning)
  final locationStatus = await Permission.location.request();

  print('Permissions status:');
  print('Bluetooth: $bluetoothStatus');
  print('Bluetooth Scan: $bluetoothScanStatus');
  print('Bluetooth Connect: $bluetoothConnectStatus');
  print('Location: $locationStatus');
}

class SmartVehicleApp extends StatelessWidget {
  const SmartVehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Vehicle Health Monitor',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, // Use dynamic theme mode
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate, // Add generated delegate
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('es'), // Spanish
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/dashboard': (context) => const DashboardScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle named routes that need parameters
              if (settings.name == '/dashboard') {
                final args = settings.arguments as Map<String, dynamic>?;
                final initialIndex = args?['initialIndex'] as int? ?? 0;
                return MaterialPageRoute(
                  builder: (context) => DashboardScreen(initialIndex: initialIndex),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
