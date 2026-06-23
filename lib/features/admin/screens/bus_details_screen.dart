// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/bus_model.dart';
import '../../../core/constants/app_colors.dart';
import 'edit_bus_screen.dart';

class BusDetailsScreen extends StatelessWidget {
  final BusModel bus;

  const BusDetailsScreen({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bus Details'),
        backgroundColor: AppColors.brandTealDeep,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bus Header Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandTealDeep,
                      AppColors.brandTealDeep.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandTealDeep.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.busNo,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          color: AppColors.brandGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bus.route,
                            style: const TextStyle(
                              color: AppColors.brandGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rs. ${bus.pricePerSeat.toStringAsFixed(0)}/seat',
                        style: const TextStyle(
                          color: AppColors.brandTealDeep,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Key Info Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      Icons.event_seat_outlined,
                      'Seats',
                      bus.totalSeats.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoTile(
                      Icons.check_circle_outline,
                      'Status',
                      bus.isActive ? 'Active' : 'Inactive',
                      color: bus.isActive
                          ? AppColors.brandGreen
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Journey Section
            if (bus.departureLocation != null ||
                bus.arrivalLocation != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Journey'),
                    const SizedBox(height: 14),
                    _buildJourneyRow(
                      Icons.location_on_outlined,
                      'From',
                      bus.departureLocation ?? 'Not specified',
                    ),
                    const SizedBox(height: 12),
                    _buildJourneyRow(
                      Icons.location_on_outlined,
                      'To',
                      bus.arrivalLocation ?? 'Not specified',
                    ),
                    const SizedBox(height: 12),
                    _buildJourneyRow(
                      Icons.access_time_outlined,
                      'Departs',
                      DateFormat('MMM d, yyyy - hh:mm a')
                          .format(bus.departureTime),
                    ),
                    if (bus.arrivalTime != null)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildJourneyRow(
                            Icons.check_circle_outline,
                            'Arrives',
                            DateFormat('MMM d, yyyy - hh:mm a')
                                .format(bus.arrivalTime!),
                          ),
                        ],
                      ),
                    if (bus.duration != null)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.brandGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: AppColors.brandGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Duration: ${bus.duration!.inHours}h ${bus.duration!.inMinutes.remainder(60)}m',
                                  style: const TextStyle(
                                    color: AppColors.brandGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],

            // Bus Information Section
            if (bus.busType != null || bus.busModel != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Bus Information'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (bus.busType != null)
                          Expanded(
                            child: _buildInfoCard('Bus Type', bus.busType!),
                          ),
                        if (bus.busType != null && bus.busModel != null)
                          const SizedBox(width: 12),
                        if (bus.busModel != null)
                          Expanded(
                            child: _buildInfoCard('Model', bus.busModel!),
                          ),
                      ],
                    ),
                    if (bus.busScheduleId != null)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildJourneyRow(
                            Icons.confirmation_num_outlined,
                            'Schedule ID',
                            bus.busScheduleId!,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],

            // Depot Information
            if (bus.depotName != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Depot Information'),
                    const SizedBox(height: 14),
                    _buildJourneyRow(
                      Icons.business_outlined,
                      'Depot',
                      bus.depotName!,
                    ),
                  ],
                ),
              ),
            ],

            // Booking Details Section
            if (bus.bookingClosingDateTime != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Booking Details'),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                color: Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Booking Closes',
                                style: TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('MMM d, yyyy - hh:mm a')
                                .format(bus.bookingClosingDateTime!),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Edit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBusScreen(bus: bus),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Bus Details'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.brandTealDeep,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.brandTealDeep,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    Color color = AppColors.brandGreen,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.brandTealDeep,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandGreen.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.brandTealDeep,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.brandTealDeep,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.brandTealDeep,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
