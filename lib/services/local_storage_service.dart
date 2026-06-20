import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tasksKey = 'tasks';
  static const String _notesKey = 'notes';
  static const String _appointmentsKey = 'appointments';
  static const String _filesKey = 'files';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Tasks
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await _prefs;
    final tasksJson = jsonEncode(tasks);
    await prefs.setString(_tasksKey, tasksJson);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final prefs = await _prefs;
    final tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
  }

  // Notes
  Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    final prefs = await _prefs;
    final notesJson = jsonEncode(notes);
    await prefs.setString(_notesKey, notesJson);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final prefs = await _prefs;
    final notesJson = prefs.getString(_notesKey);
    if (notesJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(notesJson));
  }

  // Appointments
  Future<void> saveAppointments(List<Map<String, dynamic>> appointments) async {
    final prefs = await _prefs;
    final appointmentsJson = jsonEncode(appointments);
    await prefs.setString(_appointmentsKey, appointmentsJson);
  }

  Future<List<Map<String, dynamic>>> getAppointments() async {
    final prefs = await _prefs;
    final appointmentsJson = prefs.getString(_appointmentsKey);
    if (appointmentsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(appointmentsJson));
  }

  // Files
  Future<void> saveFiles(List<Map<String, dynamic>> files) async {
    final prefs = await _prefs;
    final filesJson = jsonEncode(files);
    await prefs.setString(_filesKey, filesJson);
  }

  Future<List<Map<String, dynamic>>> getFiles() async {
    final prefs = await _prefs;
    final filesJson = prefs.getString(_filesKey);
    if (filesJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(filesJson));
  }
}