// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_bus_provider.dart';
import 'add_bus_screen.dart';
import 'live_monitor_screen.dart';
import 'live_bus_tracking_map.dart';
import 'bus_details_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminBusProvider>().fetchAllBuses());
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminBusProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F4),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.brandTealDeep,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.brandGreen),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Filter Section ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandTealDeep, AppColors.brandTealMid],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33001E2B),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FilterField(
                        controller: _fromController,
                        label: 'From',
                        hint: 'Colombo',
                        prefixIcon: Icons.trip_origin_rounded,
                        iconColor: AppColors.brandGreen,
                        onChanged: (v) =>
                            context.read<AdminBusProvider>().setSearchFrom(v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FilterField(
                        controller: _toController,
                        label: 'To',
                        hint: 'Kandy',
                        prefixIcon: Icons.location_on_rounded,
                        iconColor: AppColors.error,
                        onChanged: (v) =>
                            context.read<AdminBusProvider>().setSearchTo(v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Date Picker
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                adminProvider.searchDate ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.brandTealDeep,
                                  onPrimary: AppColors.brandGreen,
                                  onSurface: AppColors.brandTealDeep,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) {
                            context.read<AdminBusProvider>().setSearchDate(date);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  size: 18,
                                  color: AppColors.brandTealDeep),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  adminProvider.searchDate != null
                                      ? '${adminProvider.searchDate!.day}/${adminProvider.searchDate!.month}/${adminProvider.searchDate!.year}'
                                      : 'Date',
                                  style: TextStyle(
                                    color: adminProvider.searchDate != null
                                        ? AppColors.brandTealDeep
                                        : Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight:
                                        adminProvider.searchDate != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _fromController.clear();
                      _toController.clear();
                      context.read<AdminBusProvider>().clearFilters();
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 20),
                    label: const Text(
                      'Clear Filters',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: AppColors.brandTealDeep,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bus List ──────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.brandGreen,
              backgroundColor: AppColors.brandTealDeep,
              onRefresh: () => adminProvider.fetchAllBuses(),
              child: adminProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandGreen,
                        strokeWidth: 3,
                      ),
                    )
                  : adminProvider.buses.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 18, 16, 100),
                          itemCount: adminProvider.buses.length,
                          itemBuilder: (context, index) {
                            final bus = adminProvider.buses[index];
                            return _BusCard(
                              bus: bus,
                              onToggle: (val) async {
                                try {
                                  await adminProvider.toggleBusStatus(
                                      bus.id, val);
                                  if (mounted) setState(() {});
                                } catch (e) {
                                  debugPrint('Error toggling status: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error updating bus: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              onMap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        LiveBusTrackingMap(bus: bus)),
                              ),
                              onSeats: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        LiveMonitorScreen(bus: bus)),
                              ),
                              onClear: () => _showClearSeatsDialog(
                                  context, bus.id, bus.busNo),
                              onDelete: () =>
                                  _showDeleteDialog(context, bus.id),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        BusDetailsScreen(bus: bus)),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBusScreen()),
        ),
        label: const Text(
          'Add Bus',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.brandTealDeep,
        elevation: 6,
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showDeleteDialog(BuildContext context, String busId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Trip?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently remove the bus and all associated seats.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('No')),
          TextButton(
            onPressed: () {
              context.read<AdminBusProvider>().deleteBus(busId);
              Navigator.pop(ctx);
            },
            child: const Text('Yes, Cancel Trip',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearSeatsDialog(
      BuildContext context, String busId, String busNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear All Seats?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'This will archive all current bookings for bus $busNo and reset all seats to available for the next trip.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showVerifyDialog(context, busId, busNo);
            },
            child: const Text('Continue',
                style: TextStyle(color: AppColors.brandGreen)),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(
      BuildContext context, String busId, String busNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirm Clear Seats',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you absolutely sure you want to clear all seats for bus $busNo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('No, Go Back')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context
                    .read<AdminBusProvider>()
                    .clearSeatsForBus(busId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Seats cleared successfully for bus $busNo'),
                      backgroundColor: AppColors.brandGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing seats: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Yes, Clear Seats',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── _FilterField ────────────────────────────────────────────────────────────
class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Color iconColor;
  final ValueChanged<String> onChanged;

  const _FilterField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.iconColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          color: AppColors.brandTealDeep,
          fontWeight: FontWeight.w500,
          fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: AppColors.brandTealDeep.withOpacity(0.7), fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(prefixIcon, color: iconColor, size: 18),
      ),
      onChanged: onChanged,
    );
  }
}

// ── _EmptyState ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.surfaceFeature, AppColors.brandTealLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGreen.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.directions_bus_rounded,
                size: 50, color: AppColors.brandTealMid),
          ),
          const SizedBox(height: 20),
          const Text(
            'No buses found',
            style: TextStyle(
              color: AppColors.brandTealDeep,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── _BusCard ─────────────────────────────────────────────────────────────────
class _BusCard extends StatelessWidget {
  final dynamic bus;
  final ValueChanged<bool> onToggle;
  final VoidCallback onMap;
  final VoidCallback onSeats;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _BusCard({
    required this.bus,
    required this.onToggle,
    required this.onMap,
    required this.onSeats,
    required this.onClear,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse route parts
    final routeParts = (bus.route as String).split('→');
    final fromCity =
        routeParts.isNotEmpty ? routeParts[0].trim() : bus.route as String;
    final toCity = routeParts.length > 1 ? routeParts[1].trim() : '';
    final dep = bus.departureTime as DateTime;
    final depTime =
        '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandTealDeep.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: AppColors.brandGreen.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gradient Top Strip ────────────────────────────────────
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bus.isActive as bool
                        ? [AppColors.brandGreen, AppColors.brandTealMid]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Row ─────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bus number badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.brandTealDeep,
                                Color(0xFF00344A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.brandTealDeep.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_bus_rounded,
                                  color: AppColors.brandGreen, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                bus.busNo as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: bus.isActive as bool
                                ? AppColors.brandGreen.withOpacity(0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: bus.isActive as bool
                                  ? AppColors.brandGreen
                                  : Colors.grey.shade400,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bus.isActive as bool
                                      ? AppColors.brandGreen
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                bus.isActive as bool ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: bus.isActive as bool
                                      ? AppColors.brandTealMid
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Route Container ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceFeature,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.brandGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // From
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FROM',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                fromCity,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandTealDeep,
                                ),
                              ),
                            ],
                          ),

                          // Arrow section
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1.5,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0x2200684A),
                                              AppColors.brandGreen,
                                              Color(0x2200684A),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_rounded,
                                        color: AppColors.brandGreen,
                                        size: 18),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 11,
                                        color: AppColors.brandTealMid),
                                    const SizedBox(width: 3),
                                    Text(
                                      depTime,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.brandTealMid,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // To
                          if (toCity.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'TO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  toCity,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandTealDeep,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Divider ────────────────────────────────────────
                    Divider(
                        color: AppColors.hairline.withOpacity(0.8),
                        height: 1),

                    const SizedBox(height: 10),

                    // ── Action Row ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Toggle Switch
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.88,
                              child: Switch(
                                value: bus.isActive as bool,
                                activeColor: AppColors.brandGreen,
                                activeTrackColor:
                                    AppColors.brandGreen.withOpacity(0.3),
                                inactiveThumbColor: Colors.grey[400],
                                inactiveTrackColor: Colors.grey[200],
                                onChanged: onToggle,
                              ),
                            ),
                            Text(
                              bus.isActive as bool ? 'ON' : 'OFF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: bus.isActive as bool
                                    ? AppColors.brandTealMid
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),

                        // Icon Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CardIconButton(
                              icon: Icons.location_on_rounded,
                              label: 'Track',
                              color: AppColors.brandTealDeep,
                              bgColor:
                                  AppColors.brandTealDeep.withOpacity(0.08),
                              onTap: onMap,
                            ),
                            const SizedBox(width: 8),
                            _CardIconButton(
                              icon: Icons.event_seat_rounded,
                              label: 'Seats',
                              color: AppColors.brandTealMid,
                              bgColor:
                                  AppColors.brandTealMid.withOpacity(0.1),
                              onTap: onSeats,
                            ),
                            const SizedBox(width: 8),
                            _CardIconButton(
                              icon: Icons.cleaning_services_rounded,
                              label: 'Clear',
                              color: AppColors.brandGreen,
                              bgColor:
                                  AppColors.brandGreen.withOpacity(0.12),
                              onTap: onClear,
                            ),
                            const SizedBox(width: 8),
                            _CardIconButton(
                              icon: Icons.delete_outline_rounded,
                              label: 'Delete',
                              color: AppColors.error,
                              bgColor: AppColors.error.withOpacity(0.1),
                              onTap: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _CardIconButton ──────────────────────────────────────────────────────────
class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CardIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
      ),
    );
  }
}
