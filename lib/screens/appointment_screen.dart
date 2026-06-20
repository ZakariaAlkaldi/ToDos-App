import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: ListView.builder(
        itemCount: appointmentProvider.appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointmentProvider.appointments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(appointment.title),
              subtitle: Text(
                '${appointment.description}\n${DateFormat('yyyy-MM-dd').format(appointment.date)} ${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showAppointmentDialog(context, appointmentProvider, appointment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, appointmentProvider, appointment),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAppointmentDialog(context, appointmentProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAppointmentDialog(BuildContext context, AppointmentProvider appointmentProvider, [Appointment? appointment]) async {
    final isEditing = appointment != null;
    final titleController = TextEditingController(text: appointment?.title ?? '');
    final descriptionController = TextEditingController(text: appointment?.description ?? '');

    DateTime selectedDate = appointment?.date ?? DateTime.now();
    TimeOfDay startTime = appointment != null ? TimeOfDay.fromDateTime(appointment.startTime) : TimeOfDay.now();
    TimeOfDay endTime = appointment != null ? TimeOfDay.fromDateTime(appointment.endTime) : TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Appointment' : 'Add Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Start: ${startTime.format(context)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (picked != null) {
                          setState(() => startTime = picked);
                        }
                      },
                      child: const Text('Select Start Time'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('End: ${endTime.format(context)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (picked != null) {
                          setState(() => endTime = picked);
                        }
                      },
                      child: const Text('Select End Time'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }
                final startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
                final endDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);
                if (startDateTime.isAfter(endDateTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Start time must be before end time')),
                  );
                  return;
                }
                if (isEditing) {
                  await appointmentProvider.updateAppointment(appointment.id, Appointment(
                    id: appointment.id,
                    title: title,
                    description: description,
                    date: selectedDate,
                    startTime: startDateTime,
                    endTime: endDateTime,
                    createdAt: appointment.createdAt,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment updated successfully')),
                  );
                } else {
                  final newAppointment = Appointment(
                    id: DateTime.now().toString(),
                    title: title,
                    description: description,
                    date: selectedDate,
                    startTime: startDateTime,
                    endTime: endDateTime,
                    createdAt: DateTime.now(),
                  );
                  await appointmentProvider.addAppointment(newAppointment);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment added successfully')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppointmentProvider appointmentProvider, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete "${appointment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await appointmentProvider.deleteAppointment(appointment.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}