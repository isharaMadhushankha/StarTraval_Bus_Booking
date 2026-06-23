// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../../data/models/bus_model.dart';
import '../providers/seat_provider.dart';
import '../widgets/seat_grid.dart';
import '../widgets/seat_legend.dart';
import '../../../core/constants/app_colors.dart';

class SeatSelectionScreen extends StatefulWidget {
  final BusModel bus;

  const SeatSelectionScreen({super.key, required this.bus});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late RealtimeChannel _busStatusChannel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SeatProvider>().fetchAndWatchSeats(widget.bus.id);
      _subscribeToBusStatus();
    });
  }

  void _subscribeToBusStatus() {
    _busStatusChannel = SupabaseService.client
        .channel('public:buses:id=eq.${widget.bus.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'buses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.bus.id,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.delete ||
                (payload.newRecord['is_active'] == false)) {
              _showBusDeactivatedDialog();
            }
          },
        )
        .subscribe();
  }

  void _showBusDeactivatedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Trip Cancelled'),
        content: const Text(
          'This trip has been cancelled or deactivated by the administrator.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _busStatusChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seatProvider = context.watch<SeatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F2938), // Dark navy
      appBar: AppBar(
        title: Text(widget.bus.busNo),
        backgroundColor: AppColors.brandTealDeep,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  widget.bus.route,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 8),
                const SeatLegend(),
              ],
            ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF162C3A), // Dark slate
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Selected Seats:',
                      style: TextStyle(color: Color(0xFFB0B9C1)),
                    ),
                    Text(
                      '${seatProvider.seats.where((s) => s.status == 'selecting').length} Seats',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed:
                      seatProvider.seats
                          .where((s) => s.status == 'selecting')
                          .isEmpty
                      ? null
                      : () {
                          final selectedSeats = seatProvider.seats
                              .where((s) => s.status == 'selecting')
                              .map((s) => s.seatNumber)
                              .toList();
                          final totalAmount =
                              selectedSeats.length * 500.0; // ₹500 per seat

                          Navigator.pushNamed(
                            context,
                            '/payment',
                            arguments: {
                              'bus': widget.bus,
                              'selectedSeats': selectedSeats,
                              'totalAmount': totalAmount,
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.brandTealDeep,
                  ),
                  child: const Text('Confirm & Pay'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
