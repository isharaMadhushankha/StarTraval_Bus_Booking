// ignore_for_file: use_super_parameters, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/bus_model.dart';
import '../providers/admin_bus_provider.dart';

class AssignConductorDialog extends StatefulWidget {
  final String busId;
  final VoidCallback onAssigned;

  const AssignConductorDialog({
    Key? key,
    required this.busId,
    required this.onAssigned,
  }) : super(key: key);

  @override
  State<AssignConductorDialog> createState() => _AssignConductorDialogState();
}

class _AssignConductorDialogState extends State<AssignConductorDialog> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conductors = [];
  bool _isLoadingConductors = true;
  String? _selectedConductorId;
  String? _currentConductorId; // conductor already on this bus
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadConductors();
  }

  Future<void> _loadConductors() async {
    try {
      final response = await supabase
          .from('conductors')
          .select('id, name, phone, assigned_bus_id')
          .order('name');
      final list = List<Map<String, dynamic>>.from(response);

      String? initialConductorId;
      for (final c in list) {
        if (c['assigned_bus_id'] == widget.busId) {
          initialConductorId = c['id'];
          break;
        }
      }

      setState(() {
        _conductors = list;
        _selectedConductorId = initialConductorId;
        _currentConductorId = initialConductorId;
        _isLoadingConductors = false;
      });
    } catch (e) {
      debugPrint('Error loading conductors: $e');
      setState(() {
        _isLoadingConductors = false;
      });
    }
  }

  Future<void> _unassignConductor() async {
    if (_currentConductorId == null) return;
    try {
      setState(() => _isAssigning = true);

      await supabase
          .from('conductors')
          .update({'assigned_bus_id': null})
          .eq('id', _currentConductorId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conductor removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        widget.onAssigned();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  Future<void> _assignConductor() async {
    if (_selectedConductorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a conductor')),
      );
      return;
    }

    try {
      setState(() => _isAssigning = true);

      // 1. Unassign any conductor currently assigned to this bus
      await supabase
          .from('conductors')
          .update({'assigned_bus_id': null})
          .eq('assigned_bus_id', widget.busId);

      // 2. Assign the selected conductor (if they were on another bus, this automatically moves them to this bus)
      await supabase
          .from('conductors')
          .update({'assigned_bus_id': widget.busId})
          .eq('id', _selectedConductorId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conductor assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        widget.onAssigned();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Assign Conductor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a conductor to assign to this bus',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(height: 0, color: Colors.grey.shade200),
              // Conductors List
              Expanded(
                child: _isLoadingConductors
                    ? const Center(child: CircularProgressIndicator())
                    : _conductors.isEmpty
                        ? Center(
                            child: Text(
                              'No conductors available',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _conductors.length,
                            itemBuilder: (context, index) {
                              final conductor = _conductors[index];
                              final conductorId = conductor['id'];
                              final isSelected = _selectedConductorId == conductorId;
                              final assignedBusId = conductor['assigned_bus_id'];
                              final isAssignedToThis = assignedBusId == widget.busId;
                              final isAssignedToOther = assignedBusId != null && !isAssignedToThis;

                              // Retrieve other bus number if assigned to other bus
                              String? otherBusNo;
                              if (isAssignedToOther) {
                                try {
                                  final adminProvider = context.read<AdminBusProvider>();
                                  final otherBus = adminProvider.buses.cast<BusModel?>().firstWhere(
                                    (b) => b?.id == assignedBusId,
                                    orElse: () => null,
                                  );
                                  otherBusNo = otherBus?.busNo;
                                } catch (_) {}
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green.shade600
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  color: isSelected
                                      ? Colors.green.shade50.withOpacity(0.3)
                                      : Colors.white,
                                ),
                                child: RadioListTile<String>(
                                  value: conductorId,
                                  groupValue: _selectedConductorId,
                                  activeColor: Colors.green.shade600,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedConductorId = value;
                                    });
                                  },
                                  title: Text(
                                    conductor['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Phone: ${conductor['phone'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (isAssignedToThis)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Currently assigned to this bus',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                      else if (isAssignedToOther)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              otherBusNo != null
                                                  ? 'Assigned to $otherBusNo (Reassigning will move them here)'
                                                  : 'Already assigned (Reassigning will move them here)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              // Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isAssigning
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    if (_currentConductorId != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAssigning ? null : _unassignConductor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isAssigning
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Remove'),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isAssigning ? null : _assignConductor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isAssigning
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Assign'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
