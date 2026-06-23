import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/buses/providers/bus_list_provider.dart';
import 'features/seats/providers/seat_provider.dart';
import 'features/admin/providers/admin_bus_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle missing .env in production if necessary
    debugPrint('Error loading .env file: $e');
  }

  await SupabaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusListProvider()),
        ChangeNotifierProvider(create: (_) => SeatProvider()),
        ChangeNotifierProvider(create: (_) => AdminBusProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const StartTravalApp(),
    ),
  );
}





