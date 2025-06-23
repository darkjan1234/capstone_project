import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_screen.dart';

void main() {
  runApp(MaterialApp(home: LoginScreen()));
}

class UserLoginAttemptsScreen extends StatefulWidget {
  @override
  _UserLoginAttemptsScreenState createState() => _UserLoginAttemptsScreenState();
}

class _UserLoginAttemptsScreenState extends State<UserLoginAttemptsScreen> {
  final apiService = ApiService();
  List<dynamic> attempts = [];

  @override
  void initState() {
    super.initState();
    apiService.getUserLoginAttempts().then((data) {
      setState(() {
        attempts = data;
      });
    }).catchError((e) {
      print("ERROR: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Login Attempts")),
      body: attempts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attempts.length,
              itemBuilder: (_, index) {
                final attempt = attempts[index];
                return ListTile(
                  title: Text("User: ${attempt['userName'] ?? 'Unknown'}"),
                  subtitle: Text("Result: ${attempt['result']} | ${attempt['clientIpAddress']}"),
                );
              },
            ),
    );
  }
}
