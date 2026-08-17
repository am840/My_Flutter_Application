import 'package:flutter/material.dart';
import 'package:rahpeyman/modules/startup/startup_screen.dart';

void main() {
  runApp(const RahpeymanApp());
}

class RahpeymanApp extends StatelessWidget {
  const RahpeymanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartupScreen(),
    );
  }
}
