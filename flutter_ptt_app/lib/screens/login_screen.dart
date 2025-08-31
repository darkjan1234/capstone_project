import 'package:flutter/material.dart';
import 'ptt_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Predefined test users
  final List<Map<String, dynamic>> _testUsers = [
    {'id': 1, 'username': 'admin', 'name': 'Admin User'},
    {'id': 2, 'username': 'john', 'name': 'John Doe'},
    {'id': 3, 'username': 'user', 'name': 'Test User'},
  ];

  void _login() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      
      // Find user in test users list
      final user = _testUsers.firstWhere(
        (u) => u['username'] == username,
        orElse: () => {'id': 999, 'username': username, 'name': username},
      );

      // Navigate to PTT screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PttScreen(
            userName: user['username'],
            userId: user['id'],
          ),
        ),
      );
    }
  }

  void _quickLogin(Map<String, dynamic> user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PttScreen(
          userName: user['username'],
          userId: user['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PTT Voice System'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Title
            const Icon(
              Icons.mic,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Push-to-Talk\nVoice System',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),

            // Login Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Connect to PTT',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Quick Login Buttons
            const Text(
              'Quick Login (Test Users)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._testUsers.map((user) => Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                onPressed: () => _quickLogin(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  '${user['name']} (${user['username']})',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )).toList(),

            const SizedBox(height: 40),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Instructions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Make sure your backend server is running\n'
                    '2. Choose a username or use quick login\n'
                    '3. Allow microphone permission when prompted\n'
                    '4. Hold the PTT button to transmit voice\n'
                    '5. Test with multiple devices/emulators',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
