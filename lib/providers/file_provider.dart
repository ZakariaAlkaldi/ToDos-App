import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../services/local_storage_service.dart';

class FileProvider with ChangeNotifier {
  final List<FileItem> _files = [];
  final LocalStorageService _storageService = LocalStorageService();

  FileProvider() {
    Future.microtask(() => loadFiles());
  }

  List<FileItem> get files => _files;

  Future<void> loadFiles() async {
    final fileMaps = await _storageService.getFiles();
    _files.clear();
    _files.addAll(fileMaps.map((map) => FileItem.fromJson(map)).toList());
    notifyListeners();
  }

  Future<void> addFile(FileItem file) async {
    _files.add(file);
    final fileMaps = _files.map((f) => f.toJson()).toList();
    await _storageService.saveFiles(fileMaps);
    notifyListeners();
  }

  Future<void> updateFile(String id, FileItem updatedFile) async {
    final index = _files.indexWhere((file) => file.id == id);
    if (index != -1) {
      _files[index] = updatedFile;
      final fileMaps = _files.map((f) => f.toJson()).toList();
      await _storageService.saveFiles(fileMaps);
      notifyListeners();
    }
  }

  Future<void> deleteFile(String id) async {
    _files.removeWhere((file) => file.id == id);
    final fileMaps = _files.map((f) => f.toJson()).toList();
    await _storageService.saveFiles(fileMaps);
    notifyListeners();
  }

}