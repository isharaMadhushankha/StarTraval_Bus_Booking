// ignore_for_file: use_build_context_synchronously, unused_import, unused_element, unnecessary_string_interpolations, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/bus_model.dart';
import '../providers/admin_bus_provider.dart';
import '../../../core/constants/app_colors.dart';

class AddBusScreen extends StatefulWidget {
  const AddBusScreen({super.key});

  @override
  State<AddBusScreen> createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busNoController = TextEditingController();
  final _routeController = TextEditingController();
  final _seatsController = TextEditingController(text: '40');
  final _priceController = TextEditingController();
  final _departureLocationController = TextEditingController();
  final _arrivalLocationController = TextEditingController();
  final _busTypeController = TextEditingController();
  final _busModelController = TextEditingController();
  final _busScheduleIdController = TextEditingController();
  final _depotNameController = TextEditingController();
  final _durationHoursController = TextEditingController();
  final _durationMinutesController = TextEditingController();

  DateTime _selectedDepartureDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedArrivalDate;
  DateTime? _selectedBookingClosingDateTime;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours h $minutes m';
  }

  Widget _buildDateTimePickerTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.brandGreen.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.brandGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E2B),
      appBar: AppBar(
        title: const Text('Add New Bus'),
        backgroundColor: AppColors.brandTealDeep,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _busNoController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Bus Number *',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
                  ),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Bus Number is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _routeController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Route *',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Route is required' : null,
              ),
              const SizedBox(height: 24),

              // Location Information Section
              _buildSectionHeader('Location Details'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _departureLocationController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Departure Location',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _arrivalLocationController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Arrival Location',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _depotNameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Depot Name',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bus Details Section
              _buildSectionHeader('Bus Details'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _busTypeController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Bus Type',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _busModelController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Bus Model',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _busScheduleIdController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Bus Schedule ID',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seats & Pricing Section
              _buildSectionHeader('Seats & Pricing'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _seatsController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Total Seats *',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val!.isEmpty ? 'Total Seats is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Price Per Seat (Rs.) *',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Price is required' : null,
              ),
              const SizedBox(height: 24),

              // Time & Duration Section
              _buildSectionHeader('Departure & Arrival'),
              const SizedBox(height: 20),
              _buildDateTimePickerTile(
                title: 'Departure Date & Time *',
                value: _selectedDepartureDate.toString().split('.')[0],
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDepartureDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _selectedDepartureDate,
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDepartureDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDateTimePickerTile(
                title: 'Arrival Date & Time',
                value: _selectedArrivalDate != null
                    ? _selectedArrivalDate.toString().split('.')[0]
                    : 'Not set',
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedArrivalDate ??
                        _selectedDepartureDate.add(const Duration(days: 1)),
                    firstDate: _selectedDepartureDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _selectedArrivalDate ?? DateTime.now(),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedArrivalDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationHoursController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Duration Hours',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationMinutesController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Duration Minutes',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brandGreen, width: 1.5),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Booking Closing Time Section
              _buildSectionHeader('Booking Details'),
              const SizedBox(height: 20),
              _buildDateTimePickerTile(
                title: 'Booking Closing Date & Time',
                value: _selectedBookingClosingDateTime != null
                    ? _selectedBookingClosingDateTime.toString().split('.')[0]
                    : 'Not set',
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedBookingClosingDateTime ??
                        _selectedDepartureDate,
                    firstDate: DateTime.now(),
                    lastDate: _selectedDepartureDate,
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _selectedBookingClosingDateTime ?? DateTime.now(),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedBookingClosingDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Duration? duration;
                      if (_durationHoursController.text.isNotEmpty ||
                          _durationMinutesController.text.isNotEmpty) {
                        final hours =
                            int.tryParse(_durationHoursController.text) ?? 0;
                        final minutes =
                            int.tryParse(_durationMinutesController.text) ?? 0;
                        duration = Duration(hours: hours, minutes: minutes);
                      }

                      final newBus = BusModel(
                        id: const Uuid().v4(),
                        busNo: _busNoController.text,
                        route: _routeController.text,
                        departureTime: _selectedDepartureDate,
                        totalSeats: int.parse(_seatsController.text),
                        pricePerSeat: double.parse(_priceController.text),
                        departureLocation:
                            _departureLocationController.text.isNotEmpty
                            ? _departureLocationController.text
                            : null,
                        arrivalLocation:
                            _arrivalLocationController.text.isNotEmpty
                            ? _arrivalLocationController.text
                            : null,
                        busType: _busTypeController.text.isNotEmpty
                            ? _busTypeController.text
                            : null,
                        busModel: _busModelController.text.isNotEmpty
                            ? _busModelController.text
                            : null,
                        busScheduleId: _busScheduleIdController.text.isNotEmpty
                            ? _busScheduleIdController.text
                            : null,
                        duration: duration,
                        arrivalTime: _selectedArrivalDate,
                        bookingClosingDateTime: _selectedBookingClosingDateTime,
                        depotName: _depotNameController.text.isNotEmpty
                            ? _depotNameController.text
                            : null,
                      );

                      context.read<AdminBusProvider>().addBus(newBus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bus added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.brandTealDeep,
                    elevation: 4,
                    shadowColor: AppColors.brandGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Generate Bus & Seats',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _busNoController.dispose();
    _routeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _departureLocationController.dispose();
    _arrivalLocationController.dispose();
    _busTypeController.dispose();
    _busModelController.dispose();
    _busScheduleIdController.dispose();
    _depotNameController.dispose();
    _durationHoursController.dispose();
    _durationMinutesController.dispose();
    super.dispose();
  }
}
