import 'package:errandbuddy/view/widgets/custom_appbar.dart';
import 'package:errandbuddy/providers/task_provider.dart';
import 'package:errandbuddy/model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EscalationsScreen extends StatefulWidget {
  const EscalationsScreen({super.key});

  @override
  State<EscalationsScreen> createState() => _EscalationsScreenState();
}

class _EscalationsScreenState extends State<EscalationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when the screen loads
    Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).fetchTasks(),
    );
  }

  String calculateOverdueTime(DateTime dueDate) {
    final now = DateTime.now();
    final difference = now.difference(dueDate);
    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
    } else {
      return "Just now";
    }
  }

  List<Task> getOverdueTasks(List<Task> tasks) {
    return tasks
        .where(
          (task) => !task.isCompleted && task.dueDate.isBefore(DateTime.now()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Escalation Log'),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final List<Task> allTasks = taskProvider.tasks;
          final List<Task> escalatedTasks = getOverdueTasks(allTasks);

          if (taskProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 19, 134, 23),
              ),
            );
          }

          if (escalatedTasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No escalated tasks!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "All tasks are on track.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title for escalated tasks
                const Text(
                  "Escalated Tasks",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                // Escalated tasks list
                Expanded(
                  child: ListView.separated(
                    itemCount: escalatedTasks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final task = escalatedTasks[index];
                      final overdueTime = calculateOverdueTime(task.dueDate);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Overdue by $overdueTime",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Originally assigned to ${task.assignee}",
                              style: TextStyle(
                                color: Colors.blueGrey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
