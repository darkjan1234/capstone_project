import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_login_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('https://10.0.2.2:44311/api/TokenAuth/Authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userNameOrEmailAddress': usernameController.text,
        'password': passwordController.text,
        'rememberClient': true
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['result']['accessToken'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserLoginDashboard(token: token),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Check your credentials.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login RPOI System')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username or Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
