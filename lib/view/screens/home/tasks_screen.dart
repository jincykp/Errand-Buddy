import 'package:errandbuddy/view/screens/home/add_task_screen.dart';
import 'package:errandbuddy/view/widgets/custom_appbar.dart';
import 'package:errandbuddy/view/widgets/custom_fab.dart';
import 'package:errandbuddy/providers/task_provider.dart';
import 'package:errandbuddy/model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // List of asset images that will be shown alternatively
  final List<String> taskImages = [
    'assets/images/grocery.png',
    'assets/images/laundry.png',
    'assets/images/paybills.png',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch tasks when the screen loads
    Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).fetchTasks(),
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Tasks'),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final List<Task> tasks = taskProvider.tasks;

          if (taskProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 19, 134, 23),
              ),
            );
          }

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "No tasks added yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // Get alternating image from the list
                      final imageIndex = index % taskImages.length;
                      final imagePath = taskImages[imageIndex];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Right side content (Expanded first)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Priority
                                    Text(
                                      '${task.priority} Priority',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    /// Task title
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    Text(
                                      "Due: ${formatDate(task.dueDate)}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  imagePath,
                                  width: 140,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.task_alt,
                                        color: Colors.grey.shade600,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
