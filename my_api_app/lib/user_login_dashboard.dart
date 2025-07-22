import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ptt_screen.dart';

class UserLoginDashboard extends StatefulWidget {
  final String token;

  const UserLoginDashboard({super.key, required this.token});

  @override
  State<UserLoginDashboard> createState() => _UserLoginDashboardState();
}

class _UserLoginDashboardState extends State<UserLoginDashboard> {
  List<dynamic> loginAttempts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLoginAttempts();
  }

  Future<void> fetchLoginAttempts() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:44311/api/services/app/UserLogin/GetUserLoginAttempts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        loginAttempts = data['result']['items'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Failed to fetch login attempts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Login Attempts'),
        actions: [
          IconButton(
            icon: Icon(Icons.radio),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PttScreen(
                    token: widget.token,
                    serverUrl: 'https://10.0.2.2:44311',
                  ),
                ),
              );
            },
            tooltip: 'Open PTT',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: loginAttempts.length,
              itemBuilder: (context, index) {
                final item = loginAttempts[index];
                return ListTile(
                  title: Text("User: ${item['userName'] ?? 'Unknown'}"),
                  subtitle: Text("Result: ${item['result']}"),
                );
              },
            ),
    );
  }
}
