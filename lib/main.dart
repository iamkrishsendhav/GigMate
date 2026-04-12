import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/role_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🏷 App Name
      title: 'Delivery Plus',

      // 🎨 Theme
      theme: AppTheme.lightTheme,

      // 🌐 Responsive text scaling fix (important for web)
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      // 🧭 Initial Screen
      home: const RoleSelectionScreen(),
    );
  }
}