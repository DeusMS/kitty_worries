import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../screens/home_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tags = taskProvider.allTags;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.imgur.com/QCNbOAo.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Пользователь',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _drawerItem(
              icon: Icons.all_inbox,
              label: 'Все',
              count: taskProvider.tasks.length,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen(viewFilter: 'inbox')),
                );
              },
            ),
            _drawerItem(
              icon: Icons.today,
              label: 'Сегодня',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen(viewFilter: 'today')),
                );
              },
            ),
            _drawerItem(
              icon: Icons.calendar_view_week,
              label: 'Неделя',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen(viewFilter: 'week')),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: const [
                  Icon(Icons.label, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Метки', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.local_offer, size: 18, color: Colors.grey),
                    title: Text(tag, style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomeScreen(tagFilter: tag)),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.black87),
              title: const Text('Добавить'),
              trailing: const Icon(Icons.settings, color: Colors.grey),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    int? count,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.black54, size: 20),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: count != null
          ? Text('$count', style: const TextStyle(color: Colors.grey))
          : null,
      onTap: onTap,
    );
  }
}
