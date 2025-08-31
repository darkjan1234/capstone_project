import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PttApp());
}

class PttApp extends StatelessWidget {
  const PttApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PTT Voice System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthService {
  // Change these URLs to match your backend
  static const String baseUrl = 'https://10.0.2.2:44301'; // Android emulator
  // static const String baseUrl = 'https://localhost:44301'; // iOS simulator
  // static const String baseUrl = 'https://192.168.1.100:44301'; // Physical device
  
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      print('🔄 Attempting login for: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/TokenAuth/Authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userNameOrEmailAddress': username,
          'password': password,
          'rememberClient': true,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📡 Login response status: ${response.statusCode}');
      print('📡 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['result'] != null) {
          final result = data['result'];
          
          return {
            'success': true,
            'accessToken': result['accessToken'],
            'userId': result['userId'],
            'userName': username,
            'name': result['name'] ?? username,
            'regionCode': result['regionCode'],
            'pttRole': result['pttRole'],
          };
        } else {
          return {
            'success': false,
            'error': data['error']?['message'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'error': 'Connection failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/PttTest/check-database'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Backend server is running',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
      };
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String _connectionStatus = 'Checking connection...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    final result = await AuthService.testConnection();
    setState(() {
      _isConnected = result['success'];
      _connectionStatus = result['success'] 
          ? '✅ Connected to backend server'
          : '❌ ${result['error']}';
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isConnected) {
      _showError('Not connected to server. Please check your backend.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null && result['success'] == true) {
      // Login successful - navigate to PTT screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PttScreen(
            userName: result['userName'],
            userId: result['userId'],
            accessToken: result['accessToken'],
            userRole: result['pttRole'] ?? 'FieldUser',
            regionCode: result['regionCode'] ?? 'REGION1',
          ),
        ),
      );
    } else {
      _showError(result?['error'] ?? 'Login failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PTT Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'PTT Voice System',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _connectionStatus,
                style: TextStyle(
                  fontSize: 14,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username or Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your username',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              
              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isConnected ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login to PTT', style: TextStyle(fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Test credentials info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Test Credentials:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• admin / 123qwe (Super Admin)'),
                    const Text('• john / 123qwe (Field User)'),
                    const Text('• user / 123qwe (Field User)'),
                    const SizedBox(height: 8),
                    const Text(
                      'Or use any account created in admin panel:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      'http://localhost:4200/app/admin/users',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Reconnect button
              TextButton(
                onPressed: _testConnection,
                child: const Text('Test Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class PttScreen extends StatefulWidget {
  final String userName;
  final int userId;
  final String accessToken;
  final String userRole;
  final String regionCode;

  const PttScreen({
    Key? key,
    required this.userName,
    required this.userId,
    required this.accessToken,
    required this.userRole,
    required this.regionCode,
  }) : super(key: key);

  @override
  State<PttScreen> createState() => _PttScreenState();
}

class _PttScreenState extends State<PttScreen> {
  String _status = 'Connected';
  bool _isTransmitting = false;
  List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _addLog('✅ Logged in as ${widget.userName}');
    _addLog('👤 Role: ${widget.userRole}');
    _addLog('🌍 Region: ${widget.regionCode}');
    _addLog('🔑 User ID: ${widget.userId}');
  }

  Future<void> _simulateTransmission() async {
    setState(() {
      _isTransmitting = true;
      _status = 'Transmitting...';
    });

    _addLog('🎙️ ${widget.userName} started transmission');
    _addLog('📡 Sending voice data to server...');
    
    // Simulate transmission
    await Future.delayed(const Duration(seconds: 2));
    
    _addLog('✅ Voice transmission completed');
    _addLog('🔊 Other users in ${widget.regionCode} would hear this');

    setState(() {
      _isTransmitting = false;
      _status = 'Connected';
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _log.insert(0, '[$timestamp] $message');
      if (_log.length > 15) {
        _log.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PTT - ${widget.userName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('User: ${widget.userName}'),
                  Text('Role: ${widget.userRole}'),
                  Text('Region: ${widget.regionCode}'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PTT Button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _simulateTransmission,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTransmitting ? Colors.red : Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isTransmitting ? Icons.mic : Icons.mic_none,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isTransmitting ? 'TRANSMITTING' : 'PUSH TO TALK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Activity Log
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Activity Log',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _log[index],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
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
