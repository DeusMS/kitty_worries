import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/task_list.dart';
import '../screens/calendar_screen.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? tagFilter;
  final String? viewFilter; // 'today', 'week', 'inbox'

  const HomeScreen({super.key, this.tagFilter, this.viewFilter});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      _initialized = true;
    }
  }

  List<Task> _getFilteredTasks(TaskProvider provider) {
    if (widget.tagFilter != null) {
      return provider.tasksWithTag(widget.tagFilter!);
    }
    switch (widget.viewFilter) {
      case 'today':
        return provider.tasksForToday();
      case 'week':
        return provider.tasksForNext7Days();
      default:
        return provider.tasks;
    }
  }

  Widget _buildTaskScreen(List<Task> tasks) {
    return Container(
      color: const Color(0xFFF5F5F7),
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
          child: TaskList(tasks: tasks),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = _getFilteredTasks(taskProvider);

    final screens = [
      _buildTaskScreen(tasks),
      const CalendarScreen(),
      const SettingsScreen(),
    ];

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
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Задачи'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Календарь'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddTaskBottomSheet(),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
