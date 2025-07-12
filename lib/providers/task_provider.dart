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

  Future<String?> deleteTask(String taskId) async {
    try {
      // Get the task before deleting to know which member to update
      final taskDoc = await taskCollection.doc(taskId).get();
      if (taskDoc.exists) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final assignee = taskData['assignee'];

        await taskCollection.doc(taskId).delete();
        await fetchTasks(); // Refresh the tasks list

        // Return the assignee name so it can be used to update member statistics
        return assignee;
      }
      return null;
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

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await taskCollection.doc(taskId).update({'isCompleted': isCompleted});
      await fetchTasks(); // Refresh the tasks list
    } catch (e) {
      rethrow;
    }
  }

  // Quick toggle completion method that also returns the assignee
  Future<String?> quickToggleCompletion(String taskId) async {
    try {
      final taskDoc = await taskCollection.doc(taskId).get();
      if (taskDoc.exists) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final currentStatus = taskData['isCompleted'] ?? false;
        final assignee = taskData['assignee'];

        await taskCollection.doc(taskId).update({
          'isCompleted': !currentStatus,
        });

        await fetchTasks(); // Refresh the tasks list
        return assignee;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to get tasks by assignee
  List<Task> getTasksByAssignee(String assignee) {
    return _tasks.where((task) => task.assignee == assignee).toList();
  }

  // Helper method to get completed tasks by assignee
  List<Task> getCompletedTasksByAssignee(String assignee) {
    return _tasks
        .where((task) => task.assignee == assignee && task.isCompleted)
        .toList();
  }

  // Helper method to get overdue tasks by assignee
  List<Task> getOverdueTasksByAssignee(String assignee) {
    return _tasks
        .where(
          (task) =>
              task.assignee == assignee &&
              !task.isCompleted &&
              task.dueDate.isBefore(DateTime.now()),
        )
        .toList();
  }

  // Helper method to get pending tasks by assignee
  List<Task> getPendingTasksByAssignee(String assignee) {
    return _tasks
        .where((task) => task.assignee == assignee && !task.isCompleted)
        .toList();
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }
}
