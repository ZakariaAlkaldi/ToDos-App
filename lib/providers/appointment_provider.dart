import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/notification_service.dart';
import '../services/local_storage_service.dart';

class AppointmentProvider with ChangeNotifier {
  final List<Appointment> _appointments = [];
  final LocalStorageService _storageService = LocalStorageService();

  AppointmentProvider() {
    Future.microtask(() => loadAppointments());
  }

  List<Appointment> get appointments => _appointments;

  // List<Appointment> get upcomingAppointments {
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   return _appointments.where((appt) {
  //     final appointmentDate = DateTime(appt.date.year, appt.date.month, appt.date.day);
  //     return appointmentDate.isAfter(today) || (appointmentDate.isAtSameMomentAs(today) && appt.startTime.isAfter(now));
  //   }).toList()
  //     ..sort((a, b) => a.startTime.compareTo(b.startTime));
  // }

  Future<void> loadAppointments() async {
    final appointmentMaps = await _storageService.getAppointments();
    _appointments.clear();
    _appointments.addAll(
      appointmentMaps.map((map) => Appointment.fromJson(map)).toList(),
    );
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    final appointmentMaps = _appointments.map((a) => a.toJson()).toList();
    await _storageService.saveAppointments(appointmentMaps);
    // Schedule notification 10 minutes before the appointment
    final notificationTime = appointment.startTime.subtract(
      const Duration(minutes: 10),
    );
    if (notificationTime.isAfter(DateTime.now())) {
      NotificationService.scheduleNotification(
        appointment.id.hashCode,
        'Appointment Reminder',
        'You have an appointment: ${appointment.title}',
        notificationTime,
      );
    }
    notifyListeners();
  }

  Future<void> updateAppointment(
    String id,
    Appointment updatedAppointment,
  ) async {
    final index = _appointments.indexWhere((appt) => appt.id == id);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      final appointmentMaps = _appointments.map((a) => a.toJson()).toList();
      await _storageService.saveAppointments(appointmentMaps);
      // Cancel old notification and schedule new
      NotificationService.cancelNotification(id.hashCode);
      final notificationTime = updatedAppointment.startTime.subtract(
        const Duration(minutes: 10),
      );
      if (notificationTime.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id.hashCode,
          'Appointment Reminder',
          'You have an appointment: ${updatedAppointment.title}',
          notificationTime,
        );
      }
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((appt) => appt.id == id);
    final appointmentMaps = _appointments.map((a) => a.toJson()).toList();
    await _storageService.saveAppointments(appointmentMaps);
    NotificationService.cancelNotification(id.hashCode);
    notifyListeners();
  }
}
