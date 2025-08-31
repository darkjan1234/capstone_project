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
      title: 'RPOI PTT System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthService {
  static String? _workingServerUrl;
  
  static Future<String?> findWorkingServer() async {
    final testIPs = [
      '10.0.2.2:44301',      // Android emulator
      '192.168.1.104:44301', // Common local IP
      '192.168.137.1:44311', // Your working IP
      'localhost:44301',      // iOS simulator
    ];

    print('Testing connection to servers...');
    
    for (String ip in testIPs) {
      try {
        print('Testing IP: ${ip.split(':')[0]}');
        
        final response = await http.get(
          Uri.parse('http://$ip/api/PttTest/check-database'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          print('SUCCESS! IP ${ip.split(':')[0]} responded with status: ${response.statusCode}');
          _workingServerUrl = 'http://$ip';
          print('Found working server at: $ip');
          return _workingServerUrl;
        }
      } catch (e) {
        print('IP ${ip.split(':')[0]} failed: $e');
      }
    }
    
    return null;
  }
  
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      print('Login button pressed!');
      print('Username: $username');
      print('Password: $password');
      
      // Find working server if not already found
      if (_workingServerUrl == null) {
        print('Testing connection to server...');
        await findWorkingServer();
      }
      
      if (_workingServerUrl == null) {
        return {
          'success': false,
          'error': 'Cannot connect to any server. Make sure backend is running.',
        };
      }

      print('Attempting to connect to: $_workingServerUrl/api/TokenAuth/Authenticate');
      
      final response = await http.post(
        Uri.parse('$_workingServerUrl/api/TokenAuth/Authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userNameOrEmailAddress': username.trim(),
          'password': password,
          'rememberClient': true,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

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
            'regionCode': result['regionCode'] ?? 'REGION1',
            'pttRole': result['pttRole'] ?? 'FieldUser',
          };
        } else {
          // Authentication failed
          String errorMessage = 'Login failed';
          if (data['error'] != null && data['error']['message'] != null) {
            errorMessage = data['error']['message'];
          }
          
          return {
            'success': false,
            'error': errorMessage,
            'details': 'Server response: ${response.body}',
          };
        }
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Invalid username or password';
        
        if (data['error'] != null && data['error']['message'] != null) {
          errorMessage = data['error']['message'];
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'suggestion': 'Check your username and password, or try: admin / 123qwe',
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Connection failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final serverUrl = await findWorkingServer();
      
      if (serverUrl != null) {
        return {
          'success': true,
          'message': 'Connected to server: $serverUrl',
        };
      } else {
        return {
          'success': false,
          'error': 'Cannot connect to any server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection test failed: $e',
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
          ? '✅ ${result['message']}'
          : '❌ ${result['error']}';
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

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
      // Login successful
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
      // Login failed
      String errorMessage = result?['error'] ?? 'Login failed';
      String suggestion = result?['suggestion'] ?? '';
      
      _showError(errorMessage, suggestion);
    }
  }

  void _showError(String message, [String suggestion = '']) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server error: 401'),
            const SizedBox(height: 8),
            Text(message),
            if (suggestion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                suggestion,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _quickLogin(String username, String password) {
    _usernameController.text = username;
    _passwordController.text = password;
    _login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPOI PTT System'),
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
              const Icon(Icons.radio, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'RPOI PTT System',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _connectionStatus,
                style: TextStyle(
                  fontSize: 12,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter username';
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
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
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
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LOGIN TO PTT', style: TextStyle(fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Available accounts info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔑 Available Login Accounts:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    // Quick login buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _quickLogin('admin', '123qwe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('admin / 123qwe (Admin)', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _quickLogin('user1', '123qwe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('user1 / 123qwe (User)', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ],
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
    _addLog('✅ Logged in successfully!');
    _addLog('👤 User: ${widget.userName}');
    _addLog('🎭 Role: ${widget.userRole}');
    _addLog('🌍 Region: ${widget.regionCode}');
    _addLog('🆔 ID: ${widget.userId}');
  }

  Future<void> _simulateTransmission() async {
    setState(() {
      _isTransmitting = true;
      _status = 'Transmitting...';
    });

    _addLog('🎙️ ${widget.userName} started transmission');
    _addLog('📡 Sending voice data...');
    
    await Future.delayed(const Duration(seconds: 2));
    
    _addLog('✅ Transmission completed');
    _addLog('🔊 Voice sent to ${widget.regionCode} users');

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
      if (_log.length > 10) {
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
            // User Info
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
                  Text(_status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${widget.userName} (${widget.userRole})'),
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
              height: 120,
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
                  const Text('📋 Activity Log', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (context, index) {
                        return Text(_log[index], style: const TextStyle(fontSize: 9));
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
