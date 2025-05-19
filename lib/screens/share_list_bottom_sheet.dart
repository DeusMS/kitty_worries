import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/list_service.dart';
import '../models/user.dart';

class ShareListBottomSheet extends StatefulWidget {
  final String listId;
  final List<String> initiallyShared;

  const ShareListBottomSheet({
    super.key,
    required this.listId,
    required this.initiallyShared,
  });

  @override
  State<ShareListBottomSheet> createState() => _ShareListBottomSheetState();
}

class _ShareListBottomSheetState extends State<ShareListBottomSheet> {
  List<AppUser> users = [];
  Set<String> selectedUids = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedUids = widget.initiallyShared.toSet();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final allUsers = await UserService.getAllUsers();
    setState(() {
      users = allUsers;
      isLoading = false;
    });
  }

  void _onToggle(String uid) {
    setState(() {
      if (selectedUids.contains(uid)) {
        selectedUids.remove(uid);
      } else {
        selectedUids.add(uid);
      }
    });
  }

  Future<void> _save() async {
    await ListService.updateSharedWith(widget.listId, selectedUids.toList());
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text('Выберите пользователей', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...users.map((user) {
                final isSelected = selectedUids.contains(user.uid);
                return CheckboxListTile(
                  title: Text(user.displayName ?? user.email),
                  value: isSelected,
                  onChanged: (_) => _onToggle(user.uid),
                );
              }),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить'),
              ),
              const SizedBox(height: 16),
            ],
          );
  }
}
