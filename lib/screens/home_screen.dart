import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/task_list.dart';
import 'calendar_screen.dart';
import '../widgets/add_task_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  final String? tagFilter;

  const HomeScreen({super.key, this.tagFilter});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildTaskScreen(),
      const CalendarScreen(),
    ];
  }

  Widget _buildTaskScreen() {
    return Container(
      color: const Color(0xFFF5F5F7),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: TaskList(
              selectedDate: DateTime.now(),
              tagFilter: widget.tagFilter,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kitty Worries',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const CustomDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Задачи'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Календарь'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTaskBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}