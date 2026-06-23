import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/buses/screens/bus_list_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/booking/payment_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String busList = '/bus-list';
  static const String adminDashboard = '/admin-dashboard';
  static const String payment = '/payment';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    busList: (context) => const BusListScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    payment: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      return PaymentScreen(
        bus: args?['bus'],
        selectedSeats: args?['selectedSeats'] ?? [],
        totalAmount: args?['totalAmount'] ?? 0.0,
      );
    },
  };
}
