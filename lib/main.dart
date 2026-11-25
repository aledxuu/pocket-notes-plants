import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'services/theme_service.dart';
import 'pages/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database once before starting the app.
  await DatabaseHelper.instance.database;

  // Retrieve the saved theme before the first frame.
  final savedTheme = await ThemeService.loadTheme();

  runApp(PocketNotesApp(initialThemeMode: savedTheme));
}

class PocketNotesApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const PocketNotesApp({super.key, required this.initialThemeMode});

  @override
  State<PocketNotesApp> createState() => _PocketNotesAppState();
}

class _PocketNotesAppState extends State<PocketNotesApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  // Change and save the theme.
  Future<void> _changeTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });

    await ThemeService.saveTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pocket Notes',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        themeMode: _themeMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}