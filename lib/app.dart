import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/buses/screens/bus_list_screen.dart';
import 'features/admin/screens/admin_dashboard_screen_new_temp.dart'
    as admin_dashboard;
import 'features/admin/screens/conductor_dashboard_screen.dart';

class StartTravalApp extends StatelessWidget {
  const StartTravalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StartTraval',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routes: AppRoutes.routes,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          }
          if (auth.isAdmin) {
            return const admin_dashboard.AdminDashboardScreen();
          }
          if (auth.isConductor) {
            return const ConductorDashboardScreen();
          }
          return const BusListScreen();
        },
      ),
    );
  }
}
