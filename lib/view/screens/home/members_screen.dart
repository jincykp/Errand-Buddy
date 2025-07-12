import 'package:errandbuddy/providers/member_provider.dart';
import 'package:errandbuddy/view/widgets/custom_appbar.dart';
import 'package:errandbuddy/view/widgets/custom_membercard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/images/p_one.jpeg',
    'assets/images/p_two.jpeg',
    'assets/images/p_three.jpeg',
    'assets/images/p_four.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Members'),
      body: FutureBuilder(
        future: Provider.of<MemberProvider>(
          context,
          listen: false,
        ).fetchMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 5, 109, 109),
              ),
            );
          }

          return Consumer<MemberProvider>(
            builder: (context, provider, child) {
              final members = provider.members;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: members.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final imagePath = imagePaths[index % imagePaths.length];

                    return MemberCard(
                      imagePath: imagePath,
                      name: member.name,
                      assigned: member.assigned, // Now showing real data
                      overdue: member.overdue, // Now showing real data
                      completed: member.completed, // Now showing real data
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
