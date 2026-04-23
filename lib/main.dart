import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_link/screens/admin/admin_dashboard.dart';
import 'package:pro_link/screens/auth/login_screen.dart';
import 'package:pro_link/screens/intern/intern_dashboard.dart';
import 'package:pro_link/screens/mentor/mentor_dashboard.dart';
import 'package:pro_link/services/api_service.dart';
import 'package:pro_link/services/app_data_provider.dart';
import 'package:pro_link/services/auth_provider.dart';

void main() {
  runApp(const ProLinkApp());
}

class ProLinkApp extends StatelessWidget {
  const ProLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AppDataProvider(apiService: context.read<ApiService>())
                ..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Pro-Link',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          AdminDashboard.routeName: (_) => const AdminDashboard(),
          MentorDashboard.routeName: (_) => const MentorDashboard(),
          InternDashboard.routeName: (_) => const InternDashboard(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const baseColor = Color(0xFF1B263B);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      brightness: Brightness.light,
    ).copyWith(primary: baseColor, surface: Colors.white);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4F6F8),
        foregroundColor: Color(0xFF101828),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: baseColor.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 28),
        titleMedium: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }
}
