// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/bus_model.dart';
import '../providers/admin_bus_provider.dart';
import '../../../core/constants/app_colors.dart';

class EditBusScreen extends StatefulWidget {
  final BusModel bus;

  const EditBusScreen({super.key, required this.bus});

  @override
  State<EditBusScreen> createState() => _EditBusScreenState();
}

class _EditBusScreenState extends State<EditBusScreen> {
  late final _formKey = GlobalKey<FormState>();
  late final TextEditingController _busNoController;
  late final TextEditingController _routeController;
  late final TextEditingController _seatsController;
  late final TextEditingController _priceController;
  late final TextEditingController _departureLocationController;
  late final TextEditingController _arrivalLocationController;
  late final TextEditingController _busTypeController;
  late final TextEditingController _busModelController;
  late final TextEditingController _busScheduleIdController;
  late final TextEditingController _depotNameController;
  late final TextEditingController _durationHoursController;
  late final TextEditingController _durationMinutesController;

  late DateTime _selectedDepartureDate;
  DateTime? _selectedArrivalDate;
  DateTime? _selectedBookingClosingDateTime;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _busNoController = TextEditingController(text: widget.bus.busNo);
    _routeController = TextEditingController(text: widget.bus.route);
    _seatsController = TextEditingController(
      text: widget.bus.totalSeats.toString(),
    );
    _priceController = TextEditingController(
      text: widget.bus.pricePerSeat.toString(),
    );
    _departureLocationController = TextEditingController(
      text: widget.bus.departureLocation,
    );
    _arrivalLocationController = TextEditingController(
      text: widget.bus.arrivalLocation,
    );
    _busTypeController = TextEditingController(text: widget.bus.busType);
    _busModelController = TextEditingController(text: widget.bus.busModel);
    _busScheduleIdController = TextEditingController(
      text: widget.bus.busScheduleId,
    );
    _depotNameController = TextEditingController(text: widget.bus.depotName);

    _selectedDepartureDate = widget.bus.departureTime;
    _selectedArrivalDate = widget.bus.arrivalTime;
    _selectedBookingClosingDateTime = widget.bus.bookingClosingDateTime;
    _isActive = widget.bus.isActive;

    if (widget.bus.duration != null) {
      _durationHoursController = TextEditingController(
        text: widget.bus.duration!.inHours.toString(),
      );
      _durationMinutesController = TextEditingController(
        text: widget.bus.duration!.inMinutes.remainder(60).toString(),
      );
    } else {
      _durationHoursController = TextEditingController();
      _durationMinutesController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Bus Details'),
        backgroundColor: AppColors.brandTealDeep,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.edit_document,
                    color: AppColors.brandGreen,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Update Bus Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bus: ${widget.bus.busNo}',
                    style: const TextStyle(
                      color: AppColors.brandGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            _busNoController,
                            'Bus Number *',
                            'e.g., BUS-001',
                            Icons.directions_bus,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      _routeController,
                      'Route *',
                      'e.g., Colombo - Kandy',
                      Icons.route,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Location Information Section
                    _buildSectionHeader('Location Details'),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      _departureLocationController,
                      'Departure Location',
                      'e.g., Colombo Central',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 12),
                    _buildModernTextField(
                      _arrivalLocationController,
                      'Arrival Location',
                      'e.g., Kandy Central',
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildModernTextField(
                      _depotNameController,
                      'Depot Name',
                      'e.g., Central Depot',
                      Icons.home_work,
                    ),
                    const SizedBox(height: 24),

                    // Bus Details Section
                    _buildSectionHeader('Bus Details'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            _busTypeController,
                            'Bus Type',
                            'e.g., AC',
                            Icons.info_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernTextField(
                            _busModelController,
                            'Bus Model',
                            'e.g., Tata',
                            Icons.engineering,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModernTextField(
                      _busScheduleIdController,
                      'Bus Schedule ID',
                      'e.g., BT4898-1810-GP50',
                      Icons.schedule,
                    ),
                    const SizedBox(height: 24),

                    // Seats & Pricing Section
                    _buildSectionHeader('Seats & Pricing'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            _seatsController,
                            'Total Seats *',
                            '40',
                            Icons.event_seat,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernTextField(
                            _priceController,
                            'Price (Rs.) *',
                            '1500',
                            Icons.currency_rupee,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Departure & Arrival Section
                    _buildSectionHeader('Schedule'),
                    const SizedBox(height: 16),
                    _buildDateTimeTile(
                      'Departure',
                      _selectedDepartureDate,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDepartureDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(_selectedDepartureDate),
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
                    const SizedBox(height: 12),
                    _buildDateTimeTile(
                      'Arrival',
                      _selectedArrivalDate,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedArrivalDate ??
                              _selectedDepartureDate.add(const Duration(days: 1)),
                          firstDate: _selectedDepartureDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            _durationHoursController,
                            'Hours',
                            '8',
                            Icons.schedule,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernTextField(
                            _durationMinutesController,
                            'Minutes',
                            '30',
                            Icons.schedule,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Booking Details Section
                    _buildSectionHeader('Booking Details'),
                    const SizedBox(height: 16),
                    _buildDateTimeTile(
                      'Booking Closes',
                      _selectedBookingClosingDateTime,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedBookingClosingDateTime ??
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
                    const SizedBox(height: 24),

                    // Status Section
                    _buildSectionHeader('Status'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.hairline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bus Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandTealDeep,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isActive ? 'Active & Running' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isActive
                                      ? AppColors.brandGreen
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                            activeColor: AppColors.brandGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Duration? duration;
                            if (_durationHoursController.text.isNotEmpty ||
                                _durationMinutesController.text.isNotEmpty) {
                              final hours =
                                  int.tryParse(_durationHoursController.text) ??
                                      0;
                              final minutes =
                                  int.tryParse(
                                      _durationMinutesController.text) ??
                                      0;
                              duration =
                                  Duration(hours: hours, minutes: minutes);
                            }

                            final updatedBus = BusModel(
                              id: widget.bus.id,
                              busNo: _busNoController.text,
                              route: _routeController.text,
                              departureTime: _selectedDepartureDate,
                              totalSeats: int.parse(_seatsController.text),
                              pricePerSeat: double.parse(_priceController.text),
                              isActive: _isActive,
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
                              busScheduleId:
                                  _busScheduleIdController.text.isNotEmpty
                                      ? _busScheduleIdController.text
                                      : null,
                              duration: duration,
                              arrivalTime: _selectedArrivalDate,
                              bookingClosingDateTime:
                                  _selectedBookingClosingDateTime,
                              depotName: _depotNameController.text.isNotEmpty
                                  ? _depotNameController.text
                                  : null,
                            );

                            context.read<AdminBusProvider>().updateBus(
                              updatedBus,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bus updated successfully!'),
                              ),
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.brandGreen,
                          foregroundColor: AppColors.brandTealDeep,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.brandTealDeep, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.brandTealDeep,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: AppColors.surfaceFeature.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDateTimeTile(
    String title,
    DateTime? dateTime,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.surfaceFeature.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.brandTealDeep,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateTime != null
                        ? DateFormat('MMM d, yyyy - hh:mm a').format(dateTime)
                        : 'Not set',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.brandTealDeep,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.slate,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.brandTealDeep,
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
