// lib/model/task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final String priority;
  final String assignee;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.priority,
    required this.assignee,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priority': priority,
      'assignee': assignee,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      priority: map['priority'] ?? '',
      assignee: map['assignee'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
