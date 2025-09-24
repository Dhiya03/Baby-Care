import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../utils/constants.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  const EditEntryScreen({super.key});

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late Event _originalEvent;
  late DateTime _originalDate;
  late DateTime _startDateTime;
  DateTime? _endDateTime;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments passed from previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _originalEvent = args['event'] as Event;
      _originalDate = args['originalDate'] as DateTime;

      // Initialize form data
      _startDateTime = _originalEvent.start;
      _endDateTime = _originalEvent.end;
      _notesController.text = _originalEvent.notes == AppConstants.defaultNotes
          ? ''
          : _originalEvent.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${_originalEvent.type}'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event type indicator
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing),
                  child: Row(
                    children: [
                      _buildEventIcon(),
                      const SizedBox(width: AppConstants.spacing),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _originalEvent.type,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Created: ${DateFormat('MMM d, y HH:mm').format(_originalEvent.start)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing),

              // Date and time fields
              _buildDateTimeFields(),
              const SizedBox(height: AppConstants.spacing),

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => null, // Notes are optional
              ),
              const SizedBox(height: AppConstants.spacing * 2),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _deleteEvent,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventIcon() {
    IconData iconData;
    Color iconColor;

    switch (_originalEvent.type) {
      case AppConstants.feedingType:
        iconData = Icons.baby_changing_station;
        iconColor = Theme.of(context).primaryColor;
        break;
      case AppConstants.urinationType:
        iconData = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case AppConstants.stoolType:
        iconData = Icons.circle;
        iconColor = Colors.brown;
        break;
      default:
        iconData = Icons.event;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }

  Widget _buildDateTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start date/time
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Start'),
                  subtitle: Text(
                    DateFormat('MMM d, y HH:mm').format(_startDateTime),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Edit Date'),
                    ),
                    TextButton.icon(
                      onPressed: _selectStartTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: const Text('Edit Time'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // End date/time (only for feeding)
        if (_originalEvent.isFeeding) ...[
          const SizedBox(height: AppConstants.spacing / 2),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.stop),
                    title: const Text('End'),
                    subtitle: Text(
                      _endDateTime != null
                          ? DateFormat('MMM d, y HH:mm').format(_endDateTime!)
                          : 'Not set',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _selectEndDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('Edit Date'),
                      ),
                      TextButton.icon(
                        onPressed: _selectEndTime,
                        icon: const Icon(Icons.access_time, size: 18),
                        label: const Text('Edit Time'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],

        // Duration display (for feeding)
        if (_originalEvent.isFeeding && _endDateTime != null) ...[
          const SizedBox(height: AppConstants.spacing / 2),
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Theme.of(context).primaryColor),
                  const SizedBox(width: AppConstants.spacing),
                  Text(
                    'Duration: ${_calculateDuration()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _calculateDuration() {
    if (_endDateTime == null) return '0m';

    final duration = _endDateTime!.difference(_startDateTime);
    final minutes = duration.inMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _startDateTime.hour,
          _startDateTime.minute,
        );
        // Adjust end time if it's before start time
        if (_endDateTime != null && _endDateTime!.isBefore(_startDateTime)) {
          _endDateTime = _startDateTime.add(const Duration(minutes: 20));
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
    );
    if (time != null) {
      setState(() {
        _startDateTime = DateTime(
          _startDateTime.year,
          _startDateTime.month,
          _startDateTime.day,
          time.hour,
          time.minute,
        );
        // Adjust end time if it's before start time
        if (_endDateTime != null && _endDateTime!.isBefore(_startDateTime)) {
          _endDateTime = _startDateTime.add(const Duration(minutes: 20));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (!_originalEvent.isFeeding) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _endDateTime ?? _startDateTime,
      firstDate: _startDateTime,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final newEndTime = DateTime(
        date.year,
        date.month,
        date.day,
        _endDateTime?.hour ?? _startDateTime.hour,
        _endDateTime?.minute ?? _startDateTime.minute,
      );
      if (newEndTime.isAfter(_startDateTime)) {
        setState(() {
          _endDateTime = newEndTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _selectEndTime() async {
    if (!_originalEvent.isFeeding) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDateTime ?? _startDateTime),
    );
    if (time != null) {
      final newEndTime = DateTime(
        _endDateTime?.year ?? _startDateTime.year,
        _endDateTime?.month ?? _startDateTime.month,
        _endDateTime?.day ?? _startDateTime.day,
        time.hour,
        time.minute,
      );

      if (newEndTime.isAfter(_startDateTime)) {
        setState(() {
          _endDateTime = newEndTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notes = _notesController.text.trim().isEmpty
          ? AppConstants.defaultNotes
          : _notesController.text.trim();

      final durationMinutes = _originalEvent.isFeeding && _endDateTime != null
          ? _endDateTime!.difference(_startDateTime).inMinutes
          : 0;

      final updatedEvent = _originalEvent.copyWith(
        start: _startDateTime,
        end: _endDateTime,
        durationMinutes: durationMinutes,
        notes: notes,
      );

      await ref
          .read(eventActionsProvider)
          .updateEvent(_originalDate, updatedEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text(
          'Are you sure you want to delete this ${_originalEvent.type.toLowerCase()} event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              setState(() {
                _isLoading = true;
              });

              try {
                await ref
                    .read(eventActionsProvider)
                    .deleteEvent(_originalDate, _originalEvent.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting event: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
