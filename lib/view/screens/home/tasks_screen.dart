import 'package:errandbuddy/view/screens/home/add_task_screen.dart';
import 'package:errandbuddy/view/widgets/custom_appbar.dart';
import 'package:errandbuddy/view/widgets/custom_fab.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Tasks'),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
      ),
    );
  }
}
