import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/task_list.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? tagFilter;
  final String? viewFilter; // 'today', 'week'
  final String? listName;   // <-- Добавлено

  const HomeScreen({
    super.key,
    this.tagFilter,
    this.viewFilter,
    this.listName,
  });

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
      final provider = Provider.of<TaskProvider>(context, listen: false);
      provider.loadTasks();
      provider.loadCustomLists();
      _initialized = true;
    }
  }

  List<Task> _getFilteredTasks(TaskProvider provider) {
    if (widget.tagFilter != null) {
      return provider.tasksWithTag(widget.tagFilter!);
    }
    if (widget.viewFilter == 'today') {
      return provider.tasksForToday();
    }
    if (widget.viewFilter == 'week') {
      return provider.tasksForNext7Days();
    }
    if (widget.listName != null) {
      return provider.tasksInList(widget.listName!);
    }
    return provider.tasksInList('Входящие');
  }

  Widget _buildTaskScreen(List<Task> tasks) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final containerColor = isDark ? Colors.grey[850] : Colors.white;

    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
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
        title: Text(
          widget.listName ?? _getTitle(),
          style: const TextStyle(
            fontSize: 18,
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
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTaskBottomSheet(
                    listName: widget.listName ?? 'Входящие',
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getTitle() {
    switch (widget.viewFilter) {
      case 'today':
        return 'Сегодня';
      case 'week':
        return 'Неделя';
      default:
        return 'Входящие';
    }
  }
}
