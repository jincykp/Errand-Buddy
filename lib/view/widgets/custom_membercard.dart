import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final int assigned;
  final int overdue;
  final int completed;

  const MemberCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.assigned,
    required this.overdue,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 30, backgroundImage: AssetImage(imagePath)),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Assigned: $assigned',
              style: const TextStyle(color: Colors.black),
            ),
            // const SizedBox(height: 4),
            Text(
              'Overdue: $overdue',
              style: const TextStyle(color: Colors.black),
            ),
            // const SizedBox(height: 4),
            Text(
              'Completed: $completed',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
