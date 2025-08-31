import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PttApp());
}

class PttApp extends StatelessWidget {
  const PttApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PTT Voice System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
