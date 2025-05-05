import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              'Тёмная тема',
              style: theme.textTheme.bodyLarge,
            ),
            value: themeProvider.isDark,
            activeColor: theme.colorScheme.primary,
            onChanged: themeProvider.toggleTheme,
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
