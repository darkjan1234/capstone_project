import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ptt_main_screen.dart';
import 'test_users.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController(text: 'admin'); // Pre-fill for testing
  final passwordController = TextEditingController(text: '123qwe'); // Pre-fill for testing
  bool isLoading = false;
  String? workingIP; // Store the working IP address

  Future<void> testConnection() async {
    print('Testing connection to server...');

    // Test multiple possible IP addresses
    List<String> testIPs = [
      '10.0.2.2',       // Android emulator host (try first)
      '192.168.1.104',  // Your actual WiFi IP (primary)
      '192.168.137.1',  // Your WiFi hotspot IP
      '192.168.0.1',    // Common router IP
    ];

    for (String ip in testIPs) {
      try {
        print('Testing IP: $ip');
        final response = await http.get(
          Uri.parse('http://$ip:44311/swagger/index.html'),
        ).timeout(Duration(seconds: 3));
        print('SUCCESS! IP $ip responded with status: ${response.statusCode}');

        // Update the working IP
        if (response.statusCode == 200) {
          workingIP = ip;
          print('Found working server at: $ip:44311');
          return;
        }
      } catch (e) {
        print('IP $ip failed: $e');
      }
    }
    print('All IP tests failed');
  }

  Future<void> login() async {
    print('Login button pressed!'); // Debug
    print('Username: ${usernameController.text}');
    print('Password: ${passwordController.text}');

    // Test connection first
    await testConnection();

    // If no working IP found, try common defaults
    if (workingIP == null) {
      print('No working IP found, trying common defaults...');
      workingIP = '10.0.2.2'; // Android emulator default
    }

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both username and password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Use the working IP or fallback to default
      String serverIP = workingIP ?? '192.168.137.1';
      print('Attempting to connect to: http://$serverIP:44311/api/TokenAuth/Authenticate');
      final response = await http.post(
        Uri.parse('http://$serverIP:44311/api/TokenAuth/Authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userNameOrEmailAddress': usernameController.text,
          'password': passwordController.text,
          'rememberClient': true
        }),
      ).timeout(Duration(seconds: 10));

      setState(() => isLoading = false);

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['result'] != null) {
          final token = body['result']['accessToken'];
          print('Login successful! Token: ${token.substring(0, 20)}...');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PttMainScreen(
                token: token,
                serverUrl: 'http://$serverIP:44311',
                userId: usernameController.text,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Login Failed'),
              content: Text(body['error']?['message'] ?? 'Invalid credentials'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Server error: ${response.statusCode}\n${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Login error: $e');
      print('Error type: ${e.runtimeType}');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Connection Error'),
          content: Text('Failed to connect to server: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RPOI PTT System'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Icon(
              Icons.radio,
              size: 80,
              color: Colors.blue.shade700,
            ),
            SizedBox(height: 32),

            Text(
              'Push to Talk Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Select a test user or enter custom credentials',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Test Users Dropdown
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Select Test User'),
                  value: null,
                  items: TestUsers.users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['username'],
                      child: Text('${user['name']} (${user['username']})'),
                    );
                  }).toList(),
                  onChanged: (username) {
                    if (username != null) {
                      final user = TestUsers.getUserByUsername(username);
                      if (user != null) {
                        usernameController.text = user['username']!;
                        passwordController.text = user['password']!;
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username or Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),

            isLoading
                ? Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Connecting to PTT Server...'),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'LOGIN TO PTT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

            SizedBox(height: 24),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    '🔑 Available Login Accounts:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'admin / 123qwe (Admin)\n'
                    'user1 / 123qwe (User)\n'
                    'user2 / 123qwe (User)\n'
                    'radio1 / 123qwe (User)\n'
                    'radio2 / 123qwe (User)\n\n'
                    '📱 For 2 devices: Use different accounts\n'
                    '🎯 Join same group to talk!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
