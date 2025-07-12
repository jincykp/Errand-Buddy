import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:errandbuddy/model/member_model.dart';
import 'package:errandbuddy/model/task_model.dart';
import 'package:flutter/material.dart';

class MemberProvider with ChangeNotifier {
  List<Member> _members = [];
  final CollectionReference membersCollection = FirebaseFirestore.instance
      .collection('ErrandMembers');
  final CollectionReference tasksCollection = FirebaseFirestore.instance
      .collection('ErrandTasks');

  List<Member> get members => _members;

  Future<void> fetchMembers() async {
    try {
      final snapshot = await membersCollection.get();

      // Get all tasks to calculate statistics
      final tasksSnapshot = await tasksCollection.get();
      final tasks = tasksSnapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _members = snapshot.docs.map((doc) {
        final memberData = doc.data() as Map<String, dynamic>;
        final memberName = memberData['name'] ?? '';

        // Calculate statistics for this member
        final memberTasks = tasks
            .where((task) => task.assignee == memberName)
            .toList();
        final assigned = memberTasks.length;
        final completed = memberTasks.where((task) => task.isCompleted).length;
        final overdue = memberTasks
            .where(
              (task) =>
                  !task.isCompleted && task.dueDate.isBefore(DateTime.now()),
            )
            .length;

        return Member(
          id: doc.id,
          name: memberName,
          assigned: assigned,
          overdue: overdue,
          completed: completed,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching members: $e');
      _members = [];
      notifyListeners();
    }
  }

  Future<void> updateMemberStatistics(String memberName) async {
    try {
      // Get all tasks for this member
      final tasksSnapshot = await tasksCollection
          .where('assignee', isEqualTo: memberName)
          .get();

      final tasks = tasksSnapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      final assigned = tasks.length;
      final completed = tasks.where((task) => task.isCompleted).length;
      final overdue = tasks
          .where(
            (task) =>
                !task.isCompleted && task.dueDate.isBefore(DateTime.now()),
          )
          .length;

      // Update the member document in Firestore
      final memberDoc = await membersCollection
          .where('name', isEqualTo: memberName)
          .get();

      if (memberDoc.docs.isNotEmpty) {
        await membersCollection.doc(memberDoc.docs.first.id).update({
          'assigned': assigned,
          'overdue': overdue,
          'completed': completed,
        });
      }

      // Refresh the local members list
      await fetchMembers();
    } catch (e) {
      print('Error updating member statistics: $e');
    }
  }

  Future<void> updateAllMemberStatistics() async {
    try {
      for (final member in _members) {
        await updateMemberStatistics(member.name);
      }
    } catch (e) {
      print('Error updating all member statistics: $e');
    }
  }
}
