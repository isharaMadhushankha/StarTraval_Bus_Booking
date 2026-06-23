// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/booking_model.dart';
import '../../core/constants/app_colors.dart';

class BookingSuccessScreen extends StatefulWidget {
  final BusModel bus;
  final BookingModel booking;
  final List<int> selectedSeats;
  final double totalAmount;

  const BookingSuccessScreen({
    super.key,
    required this.bus,
    required this.booking,
    required this.selectedSeats,
    required this.totalAmount,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _successScale;
  late Animation<double> _fadeIn;
  late Animation<double> _pulse;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await _generatePdf();
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'StarTraval_Ticket_${widget.booking.id}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.booked,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final bookingDate = dateFormat.format(widget.booking.createdAt);
    final departureTime = dateFormat.format(widget.bus.departureTime);

    // Brand colors for PDF
    final brandDeep = PdfColor.fromHex('#001E2B');
    final brandGreen = PdfColor.fromHex('#00ED64');
    final brandTeal = PdfColor.fromHex('#00684A');
    final white = PdfColors.white;
    final lightGrey = PdfColor.fromHex('#F9FBFA');
    final grey = PdfColor.fromHex('#889397');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Banner
              pw.Container(
                color: brandDeep,
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '★ StarTraval',
                              style: pw.TextStyle(
                                fontSize: 26,
                                fontWeight: pw.FontWeight.bold,
                                color: brandGreen,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Bus Booking Ticket',
                              style: pw.TextStyle(
                                fontSize: 13,
                                color: white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: pw.BoxDecoration(
                            color: brandGreen,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.Text(
                            'CONFIRMED',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: brandDeep,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(
                      height: 1,
                      color: PdfColor.fromHex('#00ED6430'),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Booking ID: #${widget.booking.id.substring(0, 10).toUpperCase()}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColor.fromHex('#00ED6490'),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // Ticket Tear Line
              pw.Container(
                color: lightGrey,
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: white,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        height: 1,
                        child: pw.Row(
                          children: List.generate(
                            30,
                            (_) => pw.Expanded(
                              child: pw.Container(
                                margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                                height: 1,
                                color: grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: white,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              pw.Expanded(
                child: pw.Container(
                  color: lightGrey,
                  padding: const pw.EdgeInsets.all(32),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Route Section
                      pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          color: white,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                          border: pw.Border.all(
                            color: PdfColor.fromHex('#E8EDEB'),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'JOURNEY DETAILS',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: brandTeal,
                                letterSpacing: 1.5,
                              ),
                            ),
                            pw.SizedBox(height: 16),
                            pw.Row(
                              children: [
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Container(
                                      width: 10,
                                      height: 10,
                                      decoration: pw.BoxDecoration(
                                        color: brandGreen,
                                        shape: pw.BoxShape.circle,
                                      ),
                                    ),
                                    pw.Container(width: 2, height: 30, color: brandTeal),
                                    pw.Container(
                                      width: 10,
                                      height: 10,
                                      decoration: pw.BoxDecoration(
                                        color: brandDeep,
                                        shape: pw.BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(width: 12),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        widget.bus.departureLocation ?? 'Departure',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold,
                                          color: brandDeep,
                                        ),
                                      ),
                                      pw.SizedBox(height: 18),
                                      pw.Text(
                                        widget.bus.arrivalLocation ?? 'Arrival',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold,
                                          color: brandDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      departureTime,
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        color: grey,
                                      ),
                                    ),
                                    pw.SizedBox(height: 24),
                                    if (widget.bus.arrivalTime != null)
                                      pw.Text(
                                        dateFormat.format(widget.bus.arrivalTime!),
                                        style: pw.TextStyle(
                                          fontSize: 11,
                                          color: grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#E3FCF7'),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              ),
                              child: pw.Text(
                                'Route: ${widget.bus.route}',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: brandTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 16),

                      // Bus & Seat Info
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(16),
                              decoration: pw.BoxDecoration(
                                color: white,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                                border: pw.Border.all(color: PdfColor.fromHex('#E8EDEB')),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'BUS NO.',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: grey,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    widget.bus.busNo,
                                    style: pw.TextStyle(
                                      fontSize: 18,
                                      fontWeight: pw.FontWeight.bold,
                                      color: brandDeep,
                                    ),
                                  ),
                                  if (widget.bus.busType != null) ...[
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      widget.bus.busType!,
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        color: brandTeal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(16),
                              decoration: pw.BoxDecoration(
                                color: white,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                                border: pw.Border.all(color: PdfColor.fromHex('#E8EDEB')),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'SEAT(S)',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: grey,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    widget.selectedSeats.join(', '),
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold,
                                      color: brandDeep,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    '${widget.selectedSeats.length} seat(s)',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 16),

                      // Payment Summary
                      pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          color: brandDeep,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'TOTAL AMOUNT PAID',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColor.fromHex('#FFFFFF80'),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  'Rs. ${widget.totalAmount.toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: brandGreen,
                                  ),
                                ),
                              ],
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#00ED6420'),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                                border: pw.Border.all(
                                  color: PdfColor.fromHex('#00ED6450'),
                                ),
                              ),
                              child: pw.Text(
                                'PAID',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: brandGreen,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 12),

                      // Booking Date
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Booking Date:',
                            style: pw.TextStyle(fontSize: 11, color: grey),
                          ),
                          pw.Text(
                            bookingDate,
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: brandDeep,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              pw.Container(
                color: brandDeep,
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Thank you for choosing StarTraval!',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColor.fromHex('#FFFFFF70'),
                      ),
                    ),
                    pw.Text(
                      'www.startraval.com',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: brandGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.brandTealDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ──── Animated Success Icon ────
                ScaleTransition(
                  scale: _successScale,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, child) => Transform.scale(
                      scale: _pulse.value,
                      child: child,
                    ),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brandGreen.withOpacity(0.25),
                            AppColors.brandGreen.withOpacity(0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGreen.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.brandGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandGreen.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.brandTealDeep,
                            size: 44,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ──── Success Title ────
                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your booking is confirmed.\nEnjoy your journey with StarTraval!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.65),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ──── Booking Details Card ────
                FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.brandGreen.withOpacity(0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.brandGreen.withOpacity(0.18),
                                AppColors.brandGreen.withOpacity(0.06),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.confirmation_number_rounded,
                                color: AppColors.brandGreen,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Booking Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.brandGreen.withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'CONFIRMED',
                                  style: TextStyle(
                                    color: AppColors.brandGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Icons.confirmation_number_outlined,
                                label: 'Booking ID',
                                value: '#${widget.booking.id.substring(0, 10).toUpperCase()}',
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.directions_bus_rounded,
                                label: 'Bus No.',
                                value: widget.bus.busNo,
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.route_rounded,
                                label: 'Route',
                                value: widget.bus.route,
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.location_on_rounded,
                                label: 'From',
                                value: widget.bus.departureLocation ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.flag_rounded,
                                label: 'To',
                                value: widget.bus.arrivalLocation ?? 'N/A',
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.schedule_rounded,
                                label: 'Departure',
                                value: dateFormat.format(widget.bus.departureTime),
                              ),
                              if (widget.bus.arrivalTime != null) ...[
                                _buildDivider(),
                                _buildDetailRow(
                                  icon: Icons.access_time_filled_rounded,
                                  label: 'Arrival',
                                  value: dateFormat.format(widget.bus.arrivalTime!),
                                ),
                              ],
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.event_seat_rounded,
                                label: 'Seat(s)',
                                value: widget.selectedSeats.join(', '),
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.people_alt_rounded,
                                label: 'No. of Seats',
                                value: '${widget.selectedSeats.length}',
                              ),
                              _buildDivider(),
                              _buildDetailRow(
                                icon: Icons.calendar_today_rounded,
                                label: 'Booked On',
                                value: dateFormat.format(widget.booking.createdAt),
                              ),
                            ],
                          ),
                        ),

                        // Total Amount Banner
                        Container(
                          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.brandGreen.withOpacity(0.15),
                                AppColors.brandGreen.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.brandGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.payments_rounded,
                                    color: AppColors.brandGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Paid',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rs. ${widget.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.brandGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ──── Action Buttons ────
                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      // Download PDF Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingPdf ? null : _downloadPdf,
                          icon: _isGeneratingPdf
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.brandTealDeep,
                                  ),
                                )
                              : const Icon(
                                  Icons.download_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            _isGeneratingPdf ? 'Generating PDF...' : 'Download Ticket (PDF)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.brandGreen,
                            foregroundColor: AppColors.brandTealDeep,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: AppColors.brandGreen.withOpacity(0.4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Back to Home Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/bus-list');
                          },
                          icon: const Icon(
                            Icons.home_rounded,
                            size: 20,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.brandGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.08),
      height: 1,
    );
  }
}
