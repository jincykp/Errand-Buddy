// lib/providers/task_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/task_model.dart';

class TaskProvider with ChangeNotifier {
  final CollectionReference taskCollection = FirebaseFirestore.instance
      .collection('ErrandTasks');

  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> addTask(Task task) async {
    try {
      await taskCollection.add(task.toMap());
      await fetchTasks(); // Refresh the tasks list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await taskCollection
          .orderBy('createdAt', descending: true)
          .get();

      _tasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await taskCollection.doc(taskId).delete();
      await fetchTasks(); // Refresh the tasks list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await taskCollection.doc(task.id).update(task.toMap());
      await fetchTasks(); // Refresh the tasks list
    } catch (e) {
      rethrow;
    }
  }
}
