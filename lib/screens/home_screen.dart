import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/task_list.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? tagFilter;
  final String? viewFilter;
  final String? listName;
  final String? listOwnerId;

  const HomeScreen({
    super.key,
    this.tagFilter,
    this.viewFilter,
    this.listName,
    this.listOwnerId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MyPage extends StatelessWidget {
  final String? listName;
  final String? customTitle;

  const MyPage({super.key, this.listName, this.customTitle});

  String _getTitle() {
    return listName ?? 'Без имени';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          customTitle ?? listName ?? _getTitle(),
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
    );
  } 
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      if (widget.listOwnerId != null && widget.listName != null) {
        provider.loadTasksFromUserForList(widget.listName!, widget.listOwnerId!);
      } else {
        provider.loadTasks();
      }
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
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'notify',
                  mini: true,
                  onPressed: () async {
                    await AwesomeNotifications().createNotification(
                      content: NotificationContent(
                        id: 0,
                        channelKey: 'reminder_channel',
                        title: '🔥 Уведомление работает',
                        body: 'Это должно появиться немедленно',
                        notificationLayout: NotificationLayout.Default,
                      ),
                    );
                    if (kDebugMode) {
                      debugPrint('🔔 Показываем уведомление прямо сейчас');
                    }
                  },
                  child: const Icon(Icons.notifications),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'add',
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
                ),
              ],
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
