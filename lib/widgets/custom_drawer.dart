import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kitty_worries/screens/share_list_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/task_provider.dart';
import '../screens/home_screen.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_group.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? photoUrl;
  String userName = 'Пользователь';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await UserService.getUserData();
    setState(() {
      if (data?['photoUrl'] != null) photoUrl = data!['photoUrl'];
      if (data?['name'] != null) userName = data!['name'];
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      await UserService.uploadAvatar(file);
      await _loadUserData();
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить имя'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Введите имя'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Сохранить')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await UserService.updateUserName(result.trim());
      await _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.orange : const Color(0xFF2979FF);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl!)
                          : const NetworkImage('https://i.imgur.com/QCNbOAo.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _editName,
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor),
            _drawerItem(
              context: context,
              icon: Icons.today,
              label: 'Сегодня',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen(viewFilter: 'today')),
                );
              },
            ),
            _drawerItem(
              context: context,
              icon: Icons.calendar_view_week,
              label: 'Неделя',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen(viewFilter: 'week')),
                );
              },
            ),
            Divider(color: theme.dividerColor),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.list, size: 18, color: theme.hintColor),
                  const SizedBox(width: 8),
                  Text('Списки', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: taskProvider.customLists.length,
                itemBuilder: (context, index) {
                  final listName = taskProvider.customLists[index];
                  final group = taskProvider.customLists[index];

                  //final listTitle = group.name;
                  //final listOwnerId = group.ownerId;
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.folder, size: 20, color: theme.hintColor),
                    title: Text(listName, style: TextStyle(fontSize: 14, color: textColor)),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(
                            listName: listName,
                            //listOwnerId: listOwnerId, // ⬅️ важно передать владельца
                          ),
                        ),  
                      );
                    },
                    onLongPress: () async {
                      final action = await showModalBottomSheet<String>(
                        context: context,
                        builder: (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Поделиться'),
                              onTap: () => Navigator.pop(ctx, 'share'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Переименовать'),
                              onTap: () => Navigator.pop(ctx, 'rename'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Удалить'),
                              onTap: () => Navigator.pop(ctx, 'delete'),
                            ),
                          ],
                        ),
                      );
                      if (!mounted) return;
                      if (action == 'share') {
                        final currentUid = FirebaseAuth.instance.currentUser?.uid;

                        final listId = await Provider.of<TaskProvider>(context, listen: false)
                            .getListIdByName(listName);
                        if (listId == null) return; // ✅ проверка на null

                        final sharedWith = await Provider.of<TaskProvider>(context, listen: false)
                            .getSharedWithByListId(listId);
                        if (!context.mounted) return;

                        showModalBottomSheet(
                          context: context,
                          builder: (_) => ShareListBottomSheet(
                            listId: listId,                    // ✅ уверенно приводим к String
                            initiallyShared: sharedWith,        // ✅ обязательный параметр
                          ),
                        );
                      } else if (action == 'share') {
                        final id = await Provider.of<TaskProvider>(context, listen: false)
                            .getListIdByName(listName);
                        if (id == null) return;
                        final sharedWith = await Provider.of<TaskProvider>(context, listen: false)
                            .getSharedWithByListId(id);
                        if (!context.mounted) return;
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => ShareListBottomSheet(
                            listId: id,
                            initiallyShared: sharedWith,
                          ),
                        );
                      } else if (action == 'rename') {
                        final controller = TextEditingController(text: listName);
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Переименовать список'),
                            content: TextField(controller: controller),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                              TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Сохранить')),
                            ],
                          ),
                        );
                        
                        if (context.mounted) {
                          if (newName != null && newName.trim().isNotEmpty && newName != listName) {
                            await Provider.of<TaskProvider>(context, listen: false).renameList(listName, newName.trim());
                          }
                        }
                      }
                      if (!mounted) return;
                      if (action == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Удалить список?'),
                            content: const Text('Это также удалит все задачи в этом списке.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
                            ],
                          ),
                        );

                        if (context.mounted) {
                          if (confirm == true) {
                            await Provider.of<TaskProvider>(context, listen: false).deleteList(listName);
                          }
                        }                          
                      }
                    },
                  );
                },
              ),
            ),

            Divider(color: theme.dividerColor),
            ListTile(
              leading: Icon(Icons.add, color: iconColor),
              title: GestureDetector(
                onTap: () async {
                  final controller = TextEditingController();
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Новый список'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'Введите название'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, controller.text),
                          child: const Text('Создать'),
                        ),
                      ],
                    ),
                  );
                  if (result != null && result.trim().isNotEmpty) {
                    await taskProvider.createList(result.trim());
                  }
                },
                child: Text('Добавить', style: TextStyle(color: textColor)),
              ),
              trailing: Icon(Icons.settings, color: theme.hintColor),
            )
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.orange : const Color(0xFF2979FF);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return ListTile(
      dense: true,
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
