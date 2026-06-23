// ignore_for_file: use_build_context_synchronously, unused_import, unnecessary_string_interpolations, unused_element

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bus'),
        backgroundColor: AppColors.brandTealDeep,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _busNoController,
                decoration: const InputDecoration(
                  labelText: 'Bus Number *',
                  hintText: 'e.g., BUS-001',
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Bus Number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route *',
                  hintText: 'e.g., Colombo - Kandy',
                ),
                validator: (val) => val!.isEmpty ? 'Route is required' : null,
              ),
              const SizedBox(height: 16),

              // Location Information Section
              _buildSectionHeader('Location Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departureLocationController,
                decoration: const InputDecoration(
                  labelText: 'Departure Location',
                  hintText: 'e.g., Colombo Central',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _arrivalLocationController,
                decoration: const InputDecoration(
                  labelText: 'Arrival Location',
                  hintText: 'e.g., Kandy Central',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _depotNameController,
                decoration: const InputDecoration(
                  labelText: 'Depot Name',
                  hintText: 'e.g., Central Depot',
                ),
              ),
              const SizedBox(height: 24),

              // Bus Details Section
              _buildSectionHeader('Bus Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _busTypeController,
                decoration: const InputDecoration(
                  labelText: 'Bus Type',
                  hintText: 'e.g., Normal, AC, Luxury',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _busModelController,
                decoration: const InputDecoration(
                  labelText: 'Bus Model',
                  hintText: 'e.g., Ashok Leyland, Tata',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _busScheduleIdController,
                decoration: const InputDecoration(
                  labelText: 'Bus Schedule ID',
                  hintText: 'e.g., BT4898-1810-GP50',
                ),
              ),
              const SizedBox(height: 24),

              // Seats & Pricing Section
              _buildSectionHeader('Seats & Pricing'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seatsController,
                decoration: const InputDecoration(
                  labelText: 'Total Seats *',
                  hintText: '40',
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val!.isEmpty ? 'Total Seats is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price Per Seat (Rs.) *',
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Price is required' : null,
              ),
              const SizedBox(height: 24),

              // Time & Duration Section
              _buildSectionHeader('Departure & Arrival'),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Departure Date & Time *'),
                subtitle: Text(
                  '${_selectedDepartureDate.toString().split('.')[0]}',
                  style: const TextStyle(color: AppColors.slate),
                ),
                trailing: const Icon(Icons.calendar_today),
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
              ListTile(
                title: const Text('Arrival Date & Time'),
                subtitle: Text(
                  _selectedArrivalDate != null
                      ? _selectedArrivalDate.toString().split('.')[0]
                      : 'Not set',
                  style: const TextStyle(color: AppColors.slate),
                ),
                trailing: const Icon(Icons.calendar_today),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Duration Hours',
                        hintText: '8',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationMinutesController,
                      decoration: const InputDecoration(
                        labelText: 'Duration Minutes',
                        hintText: '20',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Booking Closing Time Section
              _buildSectionHeader('Booking Details'),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Booking Closing Date & Time'),
                subtitle: Text(
                  _selectedBookingClosingDateTime != null
                      ? _selectedBookingClosingDateTime.toString().split('.')[0]
                      : 'Not set',
                  style: const TextStyle(color: AppColors.slate),
                ),
                trailing: const Icon(Icons.calendar_today),
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
              const SizedBox(height: 48),

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
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.brandTealDeep,
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
