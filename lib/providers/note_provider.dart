import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];
  final LocalStorageService _storageService = LocalStorageService();

  NoteProvider() {
    Future.microtask(() => loadNotes());
  }

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    final noteMaps = await _storageService.getNotes();
    _notes.clear();
    _notes.addAll(noteMaps.map((map) => Note.fromJson(map)).toList());
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    final noteMaps = _notes.map((n) => n.toJson()).toList();
    await _storageService.saveNotes(noteMaps);
    notifyListeners();
  }

  Future<void> updateNote(String id, Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = updatedNote;
      final noteMaps = _notes.map((n) => n.toJson()).toList();
      await _storageService.saveNotes(noteMaps);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    final noteMaps = _notes.map((n) => n.toJson()).toList();
    await _storageService.saveNotes(noteMaps);
    notifyListeners();
  }
}