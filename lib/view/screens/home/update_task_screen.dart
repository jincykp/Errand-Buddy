import 'package:errandbuddy/providers/member_provider.dart';
import 'package:errandbuddy/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:errandbuddy/view/widgets/cutom_button.dart';
import 'package:errandbuddy/view/widgets/section_label.dart';
import 'package:errandbuddy/model/member_model.dart';
import 'package:errandbuddy/model/task_model.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late String selectedPriority;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late String selectedAssignee;
  late DateTime selectedDate;
  late bool isCompleted;
  String originalAssignee = '';

  @override
  void initState() {
    super.initState();

    // Initialize with existing task data
    _titleController = TextEditingController(text: widget.task.title);
    selectedPriority = widget.task.priority;
    selectedAssignee = widget.task.assignee;
    originalAssignee = widget.task.assignee; // Keep track of original assignee
    selectedDate = widget.task.dueDate;
    isCompleted = widget.task.isCompleted;

    // Fetch members from Firestore
    Future.microtask(
      () => Provider.of<MemberProvider>(context, listen: false).fetchMembers(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  InputDecoration customInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A80E5),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a task title')),
        );
        return;
      }

      if (selectedAssignee.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an assignee')),
        );
        return;
      }

      try {
        final updatedTask = Task(
          id: widget.task.id,
          title: _titleController.text.trim(),
          priority: selectedPriority,
          assignee: selectedAssignee,
          dueDate: selectedDate,
          isCompleted: isCompleted,
          createdAt: widget.task.createdAt,
        );

        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final memberProvider = Provider.of<MemberProvider>(
          context,
          listen: false,
        );

        // Update the task
        await taskProvider.updateTask(updatedTask);

        // Update member statistics for both original and new assignee (if changed)
        if (originalAssignee != selectedAssignee) {
          // Update original assignee's statistics
          await memberProvider.updateMemberStatistics(originalAssignee);
          // Update new assignee's statistics
          await memberProvider.updateMemberStatistics(selectedAssignee);
        } else {
          // Update only the current assignee's statistics
          await memberProvider.updateMemberStatistics(selectedAssignee);
        }

        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate task was updated
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
        }
      }
    }
  }

  Future<void> _deleteTask() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final memberProvider = Provider.of<MemberProvider>(
          context,
          listen: false,
        );

        await taskProvider.deleteTask(widget.task.id!);
        await memberProvider.updateMemberStatistics(widget.task.assignee);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final List<Member> members = memberProvider.members;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: const Text(
          "Edit Task",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _deleteTask,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Completion Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.pending,
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isCompleted ? 'Task Completed' : 'Task Pending',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      Switch(
                        value: isCompleted,
                        onChanged: (value) {
                          setState(() {
                            isCompleted = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SectionLabel(text: "Task Title"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLines: 3,
                  decoration: customInputDecoration(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const SectionLabel(text: "Priority"),
                const SizedBox(height: 8),
                Row(
                  children: ['High', 'Medium', 'Low'].asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final priority = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 4,
                          right: index == 2 ? 0 : 4,
                        ),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: selectedPriority == priority
                                  ? Colors.teal
                                  : Colors.grey[300],
                              foregroundColor: selectedPriority == priority
                                  ? Colors.white
                                  : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedPriority = priority;
                              });
                            },
                            child: Text(
                              priority,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                const SectionLabel(text: "Assignee"),
                const SizedBox(height: 8),
                members.isEmpty
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value:
                            (selectedAssignee.isNotEmpty &&
                                members.any(
                                  (member) => member.name == selectedAssignee,
                                ))
                            ? selectedAssignee
                            : null,
                        items: members.map((member) {
                          return DropdownMenuItem<String>(
                            value: member.name,
                            child: Text(member.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAssignee = value!;
                          });
                        },
                        decoration: customInputDecoration(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an assignee';
                          }
                          return null;
                        },
                      ),

                const SizedBox(height: 20),
                const SectionLabel(text: "Due Date"),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: customInputDecoration(),
                    child: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Update Task',
                        onPressed: _updateTask,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
