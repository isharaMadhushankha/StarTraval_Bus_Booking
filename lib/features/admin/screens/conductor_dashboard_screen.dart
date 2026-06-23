// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/conductor_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class ConductorDashboardScreen extends StatelessWidget {
  const ConductorDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConductorProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6), // soft premium grey-green tint
        body: Consumer<ConductorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Container(
                color: AppColors.brandTealDeep,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandGreen),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        provider.statusMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Premium Hero Header
                _buildHeader(context, provider),
                
                // Content Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.assignedBusId == null)
                          _buildNoBusState(provider)
                        else ...[
                          // Bus Details Card
                          _buildBusDetailsCard(provider),
                          const SizedBox(height: 20),
                          
                          // Location Control & Status Card
                          _buildTrackingControlCard(context, provider),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ConductorProvider provider) {
    final initials = provider.conductorName != null && provider.conductorName!.isNotEmpty
        ? provider.conductorName!.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'C';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.brandTealDeep,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: AppColors.brandGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'STAR TRAVAL',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
                tooltip: 'Logout',
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Profile Intro Row
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandGreen, Color(0xFF00B248)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandTealDeep,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.conductorName ?? 'Conductor',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (provider.conductorPhone != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        provider.conductorPhone!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Live Status Pill in Header
              _buildLiveStatusPill(provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusPill(ConductorProvider provider) {
    final bool isLive = provider.isShareingLocation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLive ? AppColors.brandGreen.withOpacity(0.15) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive ? AppColors.brandGreen.withOpacity(0.4) : Colors.white12,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            PulseAnimation(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white38,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'LIVE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isLive ? AppColors.brandGreen : Colors.white70,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBusState(ConductorProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bus_alert_rounded,
              size: 48,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Assigned Bus',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.brandTealDeep,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.statusMessage.contains('No bus') 
                ? 'You currently have no bus assigned. Please contact the administrator to assign a bus to you.'
                : provider.statusMessage,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.slate,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBusDetailsCard(ConductorProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ASSIGNED VEHICLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.slate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Vehicle License Plate style UI
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairline, width: 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_bus_filled_rounded,
                      color: AppColors.brandTealDeep,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      provider.busNumber ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brandTealDeep,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (provider.busRoute != null) ...[
            const SizedBox(height: 20),
            const Divider(color: AppColors.hairline),
            const SizedBox(height: 16),
            const Text(
              'ASSIGNED ROUTE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.slate,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.route_rounded,
                  color: AppColors.brandTealMid,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.busRoute!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandTealDeep,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingControlCard(BuildContext context, ConductorProvider provider) {
    final bool isLive = provider.isShareingLocation;
    final bool hasError = provider.statusMessage.contains('permission') || provider.statusMessage.contains('Error') || provider.statusMessage.contains('denied');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOCATION SHARING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLive ? 'Broadcasting live GPS coordinates' : 'Tracking is currently offline',
                      style: TextStyle(
                        fontSize: 13,
                        color: isLive ? AppColors.brandGreenDark : AppColors.slate,
                        fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom Switch style
              Switch(
                value: isLive,
                onChanged: (val) {
                  provider.toggleLocationSharing();
                },
                activeColor: AppColors.brandGreen,
                activeTrackColor: AppColors.brandGreen.withOpacity(0.3),
                inactiveThumbColor: AppColors.slate,
                inactiveTrackColor: const Color(0xFFE2E8F0),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Status Notification Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasError
                  ? const Color(0xFFFEF2F2)
                  : isLive
                      ? AppColors.brandTealLight.withOpacity(0.5)
                      : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFFCA5A5)
                    : isLive
                        ? AppColors.brandGreen.withOpacity(0.3)
                        : AppColors.hairline,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasError
                      ? Icons.error_outline_rounded
                      : isLive
                          ? Icons.sensors_rounded
                          : Icons.sensors_off_rounded,
                  color: hasError
                      ? AppColors.error
                      : isLive
                          ? AppColors.brandTealMid
                          : AppColors.slate,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasError
                            ? 'Action Required'
                            : isLive
                                ? 'Transmission Status'
                                : 'Sharing Suspended',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: hasError
                              ? Colors.red.shade900
                              : isLive
                                  ? AppColors.brandTealDeep
                                  : AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasError
                              ? Colors.red.shade700
                              : isLive
                                  ? AppColors.brandTealDeep.withOpacity(0.8)
                                  : AppColors.slate,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // If permission is missing, provide a settings trigger button
          if (hasError) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.openLocationSettings(),
                icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                label: const Text('Open Location Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandTealDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          
          // Real-time Coordinate Readout
          if (isLive && provider.lastLatitude != null && provider.lastLongitude != null) ...[
            const SizedBox(height: 24),
            const Divider(color: AppColors.hairline),
            const SizedBox(height: 20),
            const Text(
              'REAL-TIME COORDINATES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.slate,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCoordinateBox(
                    'LATITUDE',
                    provider.lastLatitude!.toStringAsFixed(6),
                    Icons.north_east_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCoordinateBox(
                    'LONGITUDE',
                    provider.lastLongitude!.toStringAsFixed(6),
                    Icons.south_east_rounded,
                  ),
                ),
              ],
            ),
            if (provider.currentLocationName != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.brandGreenDark,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT ADDRESS / PLACE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.currentLocationName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandTealDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history_toggle_off_rounded,
                  color: AppColors.slate,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Auto-updates every 10 seconds',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.slate.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoordinateBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.slate),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brandTealDeep,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;

  const PulseAnimation({Key? key, required this.child}) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
