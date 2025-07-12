import 'package:errandbuddy/providers/member_provider.dart';
import 'package:errandbuddy/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:errandbuddy/view/widgets/cutom_button.dart';
import 'package:errandbuddy/view/widgets/section_label.dart';
import 'package:errandbuddy/model/member_model.dart';
import 'package:errandbuddy/model/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String selectedPriority = 'High';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  String selectedAssignee = '';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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

  Future<void> _saveTask() async {
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

      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
        );
        return;
      }

      try {
        final task = Task(
          title: _titleController.text.trim(),
          priority: selectedPriority,
          assignee: selectedAssignee,
          dueDate: selectedDate!,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        await Provider.of<TaskProvider>(context, listen: false).addTask(task);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding task: $e')));
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
          "Add Task",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                      selectedDate != null
                          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                          : "Select date",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(text: 'Add Task', onPressed: _saveTask),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
