import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery App")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen()),
            );
          },
          child: const Text("Start Delivery"),
        ),
      ),
    );
  }
}