// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/bus_model.dart';
import '../../seats/providers/seat_provider.dart';
import '../../seats/widgets/seat_grid.dart';
import '../../seats/widgets/seat_legend.dart';
import '../../../core/constants/app_colors.dart';

class LiveMonitorScreen extends StatefulWidget {
  final BusModel bus;

  const LiveMonitorScreen({super.key, required this.bus});

  @override
  State<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends State<LiveMonitorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<SeatProvider>().fetchAndWatchSeats(widget.bus.id)
    );
  }

  @override
  Widget build(BuildContext context) {
    final seatProvider = context.watch<SeatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F2938), // Dark navy
      appBar: AppBar(
        title: Text('Live Monitor: ${widget.bus.busNo}'),
        backgroundColor: AppColors.brandTealDeep,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF162C3A), // Dark slate info bar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline, 
                  size: 16, 
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  'Monitoring ${seatProvider.seats.length} seats in real-time',
                  style: const TextStyle(
                    fontSize: 12, 
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SeatLegend(),
          ),
          Expanded(
            child: seatProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandGreen,
                    ),
                  )
                : SeatGrid(seats: seatProvider.seats),
          ),
        ],
      ),
    );
  }
}
