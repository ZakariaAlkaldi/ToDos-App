import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/local_storage_service.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final LocalStorageService _storageService = LocalStorageService();

  TaskProvider() {
    Future.microtask(() => loadTasks());
  }

  List<Task> get tasks => _tasks;

  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();

  Future<void> loadTasks() async {
    final taskMaps = await _storageService.getTasks();
    _tasks.clear();
    _tasks.addAll(taskMaps.map((map) => Task.fromJson(map)).toList());
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    final taskMaps = _tasks.map((t) => t.toJson()).toList();
    await _storageService.saveTasks(taskMaps);
    notifyListeners();
  }

  Future<void> updateTask(String id, Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      final taskMaps = _tasks.map((t) => t.toJson()).toList();
      await _storageService.saveTasks(taskMaps);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    final taskMaps = _tasks.map((t) => t.toJson()).toList();
    await _storageService.saveTasks(taskMaps);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      final taskMaps = _tasks.map((t) => t.toJson()).toList();
      await _storageService.saveTasks(taskMaps);
      notifyListeners();
    }
  }
}