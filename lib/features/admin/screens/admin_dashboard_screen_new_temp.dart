// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/models/bus_model.dart';
import '../providers/admin_bus_provider.dart';
import 'add_bus_screen.dart';
import 'live_monitor_screen.dart';
import 'live_bus_tracking_map.dart';
import 'bus_details_screen.dart';
import 'assign_conductor_dialog.dart';
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
  int _currentIndex = 0;
  List<Map<String, dynamic>> _conductors = [];
  bool _isLoadingConductors = false;

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

  Future<void> _fetchConductors() async {
    setState(() => _isLoadingConductors = true);
    try {
      final response = await Supabase.instance.client
          .from('conductors')
          .select('id, name, phone, assigned_bus_id')
          .order('name');
      setState(() {
        _conductors = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching conductors: $e');
    } finally {
      setState(() => _isLoadingConductors = false);
    }
  }

  Future<void> _deleteConductor(String conductorId) async {
    try {
      setState(() => _isLoadingConductors = true);
      await Supabase.instance.client
          .from('conductors')
          .delete()
          .eq('id', conductorId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conductor removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchConductors();
    } catch (e) {
      debugPrint('Error deleting conductor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoadingConductors = false);
    }
  }

  void _confirmDeleteConductor(String conductorId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Conductor?'),
        content: Text('Are you sure you want to remove $name? This will also unassign them from any bus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteConductor(conductorId);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddConductorDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F2B38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              title: const Text(
                'Add New Conductor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.brandGreen),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.brandGreen),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.brandGreen),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.brandGreen),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white60,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          setDialogState(() => isSaving = true);
                          try {
                            final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
                            final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

                            final tempClient = SupabaseClient(
                              supabaseUrl,
                              supabaseAnonKey,
                              authOptions: const AuthClientOptions(
                                authFlowType: AuthFlowType.implicit,
                              ),
                            );
                            
                            final authResponse = await tempClient.auth.signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              data: {'role': 'conductor'},
                            );

                            final userId = authResponse.user?.id;
                            if (userId == null) {
                              throw Exception('Failed to sign up user');
                            }

                            await Supabase.instance.client.from('conductors').insert({
                              'id': userId,
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Conductor added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                              _fetchConductors();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString().replaceAll('Exception:', '')}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => isSaving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.brandTealDeep,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandTealDeep),
                          ),
                        )
                      : const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBusesTab(AdminBusProvider adminProvider) {
    return Column(
      children: [
        // ── Search Filter Section ────────────────────────────────────────
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
                    child: TextField(
                      controller: _fromController,
                      style: const TextStyle(
                        color: AppColors.brandTealDeep,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: 'From',
                        labelStyle: TextStyle(
                          color: AppColors.brandTealDeep.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        hintText: 'Colombo',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.trip_origin_rounded,
                          color: AppColors.brandGreen,
                          size: 18,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<AdminBusProvider>().setSearchFrom(
                          value.isEmpty ? '' : value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _toController,
                      style: const TextStyle(
                        color: AppColors.brandTealDeep,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: 'To',
                        labelStyle: TextStyle(
                          color: AppColors.brandTealDeep.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        hintText: 'Kandy',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.error,
                          size: 18,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<AdminBusProvider>().setSearchTo(
                          value.isEmpty ? '' : value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
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
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: AppColors.brandTealDeep,
                            ),
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
                                  fontWeight: adminProvider.searchDate != null
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
        // Bus List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => adminProvider.fetchAllBuses(),
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminProvider.buses.isEmpty
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
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                    itemCount: adminProvider.buses.length,
                    itemBuilder: (context, index) {
                      final bus = adminProvider.buses[index];
                      // Parse route into from/to parts
                      final routeParts = bus.route.split('→');
                      final fromCity = routeParts.isNotEmpty ? routeParts[0].trim() : bus.route;
                      final toCity = routeParts.length > 1 ? routeParts[1].trim() : '';
                      final dep = bus.departureTime;
                      final depTime = '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusDetailsScreen(bus: bus),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandGreen.withOpacity(0.20),
                                blurRadius: 20,
                                spreadRadius: -2,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.40),
                                blurRadius: 28,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Gradient Top Strip ──────────────────
                                Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: bus.isActive
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
                                      // ── Header Row ──────────────────────
                                      Row(
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
                                                  color: AppColors.brandTealDeep.withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.directions_bus_rounded,
                                                  color: AppColors.brandGreen,
                                                  size: 15,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  bus.busNo,
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
                                              color: bus.isActive
                                                  ? AppColors.brandGreen.withOpacity(0.12)
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: bus.isActive
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
                                                    color: bus.isActive
                                                        ? AppColors.brandGreen
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  bus.isActive ? 'Active' : 'Inactive',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: bus.isActive
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

                                      // ── Route Container ─────────────────
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
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 1.5,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                AppColors.brandTealMid.withOpacity(0.2),
                                                                AppColors.brandGreen,
                                                                AppColors.brandTealMid.withOpacity(0.2),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.arrow_forward_rounded,
                                                        color: AppColors.brandGreen,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time_rounded,
                                                        size: 11,
                                                        color: AppColors.brandTealMid,
                                                      ),
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
                                      Divider(
                                        color: AppColors.hairline.withOpacity(0.8),
                                        height: 1,
                                      ),
                                      const SizedBox(height: 10),

                                      // ── Action Row ──────────────────────
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Toggle with ON/OFF label
                                          Row(
                                            children: [
                                              Transform.scale(
                                                scale: 0.88,
                                                child: Switch(
                                                  value: bus.isActive,
                                                  activeColor: AppColors.brandGreen,
                                                  activeTrackColor: AppColors.brandGreen.withOpacity(0.3),
                                                  inactiveThumbColor: Colors.grey[400],
                                                  inactiveTrackColor: Colors.grey[200],
                                                  onChanged: (val) async {
                                                    debugPrint('Switch changed to $val for bus ${bus.id}');
                                                    try {
                                                      await adminProvider.toggleBusStatus(bus.id, val);
                                                      if (mounted) setState(() {});
                                                    } catch (e) {
                                                      debugPrint('Error toggling status: $e');
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Error updating bus: $e'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              Text(
                                                bus.isActive ? 'ON' : 'OFF',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: bus.isActive
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
                                              _iconBtn(
                                                icon: Icons.location_on_rounded,
                                                color: AppColors.brandTealDeep,
                                                bgColor: AppColors.brandTealDeep.withOpacity(0.08),
                                                tooltip: 'Track Bus',
                                                onTap: () {
                                                  debugPrint('Map button tapped for bus ${bus.id}');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => LiveBusTrackingMap(bus: bus),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 7),
                                              _iconBtn(
                                                icon: Icons.event_seat_rounded,
                                                color: AppColors.brandTealMid,
                                                bgColor: AppColors.brandTealMid.withOpacity(0.1),
                                                tooltip: 'View Seats',
                                                onTap: () {
                                                  debugPrint('Seats button tapped for bus ${bus.id}');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => LiveMonitorScreen(bus: bus),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 7),
                                              _iconBtn(
                                                icon: Icons.cleaning_services_rounded,
                                                color: AppColors.brandGreen,
                                                bgColor: AppColors.brandGreen.withOpacity(0.12),
                                                tooltip: 'Clear Seats',
                                                onTap: () {
                                                  debugPrint('Clear seats button tapped for bus ${bus.id}');
                                                  _showClearSeatsDialog(context, bus.id, bus.busNo);
                                                },
                                              ),
                                              const SizedBox(width: 7),
                                              _iconBtn(
                                                icon: Icons.person_add_rounded,
                                                color: Colors.purple.shade600,
                                                bgColor: Colors.purple.withOpacity(0.1),
                                                tooltip: 'Assign Conductor',
                                                onTap: () {
                                                  debugPrint('Assign conductor button tapped for bus ${bus.id}');
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (_) => AssignConductorDialog(
                                                      busId: bus.id,
                                                      onAssigned: () => adminProvider.fetchAllBuses(),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 7),
                                              _iconBtn(
                                                icon: Icons.delete_outline_rounded,
                                                color: AppColors.error,
                                                bgColor: AppColors.error.withOpacity(0.1),
                                                tooltip: 'Delete Bus',
                                                onTap: () {
                                                  debugPrint('Delete button tapped for bus ${bus.id}');
                                                  _showDeleteDialog(context, bus.id);
                                                },
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
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildConductorsTab(AdminBusProvider adminProvider) {
    if (_isLoadingConductors) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conductors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No conductors registered',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Conductor" to register a new one',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchConductors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conductors.length,
        itemBuilder: (context, index) {
          final conductor = _conductors[index];
          final assignedBusId = conductor['assigned_bus_id'];
          String busNo = 'Not Assigned';
          if (assignedBusId != null) {
            final bus = adminProvider.buses.cast<BusModel?>().firstWhere(
              (b) => b?.id == assignedBusId,
              orElse: () => null,
            );
            busNo = bus?.busNo ?? 'Assigned';
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2B38),
                  Color(0xFF051722),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(
                conductor['name'] ?? 'Unknown Name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 6),
                        Text(
                          conductor['phone'] ?? 'N/A',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.directions_bus_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: assignedBusId != null
                                ? AppColors.brandGreen.withOpacity(0.12)
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: assignedBusId != null
                                  ? AppColors.brandGreen.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Text(
                            busNo,
                            style: TextStyle(
                              color: assignedBusId != null
                                  ? AppColors.brandGreen
                                  : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmDeleteConductor(conductor['id'], conductor['name']),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Reusable icon button helper ─────────────────────────────────────────
  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminBusProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF001E2B),
      appBar: AppBar(
        backgroundColor: AppColors.brandTealDeep,
        elevation: 0,
        title: Text(
          _currentIndex == 0 ? 'Admin Dashboard' : 'Manage Conductors',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.brandGreen),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildBusesTab(adminProvider),
          _buildConductorsTab(adminProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF0F2B38),
        elevation: 12,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            _fetchConductors();
          } else {
            context.read<AdminBusProvider>().fetchAllBuses();
          }
        },
        selectedItemColor: AppColors.brandGreen,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_rounded),
            label: 'Buses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Conductors',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBusScreen()),
                );
              },
              label: const Text(
                'Add Bus',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add_rounded),
              backgroundColor: AppColors.brandGreen,
              foregroundColor: AppColors.brandTealDeep,
              elevation: 6,
            )
          : FloatingActionButton.extended(
              onPressed: () => _showAddConductorDialog(context),
              label: const Text(
                'Add Conductor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.person_add_rounded),
              backgroundColor: AppColors.brandGreen,
              foregroundColor: AppColors.brandTealDeep,
              elevation: 6,
            ),
    );
  }

  void _showDeleteDialog(BuildContext context, String busId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip?'),
        content: const Text(
          'This will permanently remove the bus and all associated seats.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminBusProvider>().deleteBus(busId);
              Navigator.pop(context);
            },
            child: const Text(
              'Yes, Cancel Trip',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearSeatsDialog(BuildContext context, String busId, String busNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Seats?'),
        content: Text(
          'This will archive all current bookings for bus $busNo and reset all seats to available status for the next trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showVerifyDialog(context, busId, busNo);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: AppColors.brandGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context, String busId, String busNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear Seats'),
        content: Text(
          'Are you absolutely sure you want to clear all seats for bus $busNo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Go Back'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<AdminBusProvider>().clearSeatsForBus(busId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Seats cleared successfully for bus $busNo',
                      ),
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
            child: const Text(
              'Yes, Clear Seats',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
