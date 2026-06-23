// ignore_for_file: use_build_context_synchronously, unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/bus_list_provider.dart';
import '../widgets/bus_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  late TextEditingController _fromController;
  late TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    Future.microtask(() => context.read<BusListProvider>().fetchBuses());
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = context.watch<BusListProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
        backgroundColor: AppColors.brandTealDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Filter Section
          Container(
            color: AppColors.surfaceFeature.withOpacity(0.5),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // From, To, and Date Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromController,
                        decoration: InputDecoration(
                          labelText: 'From',
                          hintText: 'Colombo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          busProvider.setFromLocation(value.isEmpty ? null : value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _toController,
                        decoration: InputDecoration(
                          labelText: 'To',
                          hintText: 'Kandy',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          busProvider.setToLocation(value.isEmpty ? null : value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: busProvider.selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            busProvider.setSelectedDate(date);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.slate),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20, color: AppColors.brandTealDeep),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  busProvider.selectedDate != null
                                      ? DateFormat('MMM dd').format(busProvider.selectedDate!)
                                      : 'Date',
                                  style: TextStyle(
                                    color: busProvider.selectedDate != null ? AppColors.brandTealDeep : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Clear Button Row
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _fromController.clear();
                      _toController.clear();
                      busProvider.clearFilters();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: AppColors.brandTealDeep,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bus List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => busProvider.fetchBuses(),
              child: busProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : busProvider.error != null
                  ? Center(child: Text('Error: ${busProvider.error}'))
                  : busProvider.buses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_bus,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No buses found',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: busProvider.buses.length,
                      itemBuilder: (context, index) {
                        final bus = busProvider.buses[index];
                        final hasBooked = busProvider.bookedBusIds.contains(bus.id);
                        final locationName = busProvider.bookedBusLocations[bus.id];
                        return BusCard(
                          bus: bus,
                          hasBooked: hasBooked,
                          locationName: locationName,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
