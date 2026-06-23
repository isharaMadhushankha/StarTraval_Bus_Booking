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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.brandTealDeep,
                    AppColors.brandTealDeep.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.busNo,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.route, color: AppColors.brandGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bus.route,
                          style: const TextStyle(
                            color: AppColors.brandGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Rs. ${bus.pricePerSeat.toStringAsFixed(0)}/seat',
                      style: const TextStyle(
                        color: AppColors.brandTealDeep,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          Icons.event_seat,
                          'Seats',
                          bus.totalSeats.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTile(
                          bus.isActive ? Icons.check_circle : Icons.cancel,
                          'Status',
                          bus.isActive ? 'Active' : 'Inactive',
                          color: bus.isActive
                              ? AppColors.brandGreen
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Journey Section
                  if (bus.departureLocation != null ||
                      bus.arrivalLocation != null) ...[
                    _buildSectionTitle('Journey'),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      '📍 From',
                      bus.departureLocation ?? 'Not specified',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      '🎯 To',
                      bus.arrivalLocation ?? 'Not specified',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      '🕐 Departs',
                      DateFormat(
                        'MMM d, yyyy - hh:mm a',
                      ).format(bus.departureTime),
                    ),
                    if (bus.arrivalTime != null)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            '✓ Arrives',
                            DateFormat(
                              'MMM d, yyyy - hh:mm a',
                            ).format(bus.arrivalTime!),
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
                              color: AppColors.brandGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.brandGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: AppColors.brandGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Duration: ${bus.duration!.inHours}h ${bus.duration!.inMinutes.remainder(60)}m',
                                  style: const TextStyle(
                                    color: AppColors.brandGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],

                  // Bus Info Section
                  if (bus.busType != null || bus.busModel != null) ...[
                    _buildSectionTitle('Bus Information'),
                    const SizedBox(height: 12),
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
                          _buildDetailRow('🎫 Schedule ID', bus.busScheduleId!),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],

                  // Location & Depot
                  if (bus.depotName != null) ...[
                    _buildSectionTitle('Depot Information'),
                    const SizedBox(height: 12),
                    _buildDetailRow('🏢 Depot', bus.depotName!),
                    const SizedBox(height: 20),
                  ],

                  // Booking Section
                  if (bus.bookingClosingDateTime != null) ...[
                    _buildSectionTitle('Booking Details'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Closes',
                            style: TextStyle(
                              color: AppColors.slate,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM d, yyyy - hh:mm a',
                            ).format(bus.bookingClosingDateTime!),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Edit Button
                  SizedBox(
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
                ],
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
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: 11,
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
              fontSize: 16,
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
        color: AppColors.surfaceFeature.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brandTealDeep.withOpacity(0.1)),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.brandTealDeep,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
