import 'package:errandbuddy/view/screens/home/members_screen.dart';
import 'package:flutter/material.dart';
import 'tasks_screen.dart';
import 'escalations_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> screens = [
    MembersScreen(),
    TasksScreen(),
    EscalationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Color(0xFF4F7396),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Escalations',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profiles'),
        ],
      ),
    );
  }
}
