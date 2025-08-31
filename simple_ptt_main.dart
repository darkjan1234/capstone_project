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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();

  void _login(String username) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PttScreen(userName: username),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'PTT Voice System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_usernameController.text.isNotEmpty) {
                    _login(_usernameController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Connect to PTT', style: TextStyle(fontSize: 18)),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Quick login buttons
            const Text('Quick Login:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _login('admin'),
                    child: const Text('Admin'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _login('john'),
                    child: const Text('John'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _login('user'),
                    child: const Text('User'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PttScreen extends StatefulWidget {
  final String userName;

  const PttScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<PttScreen> createState() => _PttScreenState();
}

class _PttScreenState extends State<PttScreen> {
  String _status = 'Disconnected';
  bool _isConnected = false;
  bool _isTransmitting = false;
  List<String> _log = [];

  // Change this IP to your computer's IP address if using physical device
  static const String serverUrl = 'https://10.0.2.2:44301'; // Android emulator
  // static const String serverUrl = 'https://192.168.1.100:44301'; // Physical device

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    try {
      setState(() {
        _status = 'Connecting to PTT server...';
      });
      _addLog('🔄 Connecting to $serverUrl');

      final response = await http.get(
        Uri.parse('$serverUrl/api/PttTest/check-database'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isConnected = true;
          _status = 'Connected to PTT Server';
        });
        _addLog('✅ Connected successfully!');
        _addLog('📊 Server data: ${data['Message'] ?? 'OK'}');
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _status = 'Connection Failed';
      });
      _addLog('❌ Connection failed: $e');
      _addLog('💡 Make sure backend server is running');
    }
  }

  Future<void> _testPtt() async {
    if (!_isConnected) {
      _addLog('❌ Not connected to server');
      return;
    }

    try {
      _addLog('🧪 Testing PTT functionality...');
      
      final response = await http.get(
        Uri.parse('$serverUrl/api/PttTest/current-user-info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addLog('✅ PTT test successful');
        _addLog('👤 User: ${data['UserName'] ?? 'Unknown'}');
      } else {
        _addLog('⚠️ PTT test returned: ${response.statusCode}');
      }
    } catch (e) {
      _addLog('❌ PTT test failed: $e');
    }
  }

  Future<void> _simulateTransmission() async {
    if (!_isConnected) {
      _addLog('❌ Cannot transmit - not connected');
      return;
    }

    setState(() {
      _isTransmitting = true;
    });

    _addLog('🎙️ ${widget.userName} started transmission');
    _addLog('📡 Sending voice data to server...');
    
    // Simulate transmission
    await Future.delayed(const Duration(seconds: 2));
    
    _addLog('✅ Voice transmission completed');
    _addLog('🔊 Other users would hear this message');

    setState(() {
      _isTransmitting = false;
    });
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
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _connectToServer,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
                border: Border.all(
                  color: _isConnected ? Colors.green : Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User: ${widget.userName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PTT Button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _isConnected ? _simulateTransmission : null,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTransmitting 
                          ? Colors.red 
                          : _isConnected 
                              ? Colors.green 
                              : Colors.grey,
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
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isTransmitting 
                              ? 'TRANSMITTING' 
                              : _isConnected 
                                  ? 'PUSH TO TALK' 
                                  : 'DISCONNECTED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _connectToServer,
                  child: const Text('Reconnect'),
                ),
                ElevatedButton(
                  onPressed: _testPtt,
                  child: const Text('Test PTT'),
                ),
              ],
            ),

            const SizedBox(height: 16),

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
