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
      home: const PttScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PttScreen extends StatefulWidget {
  const PttScreen({Key? key}) : super(key: key);

  @override
  State<PttScreen> createState() => _PttScreenState();
}

class _PttScreenState extends State<PttScreen> {
  String _status = 'Disconnected';
  bool _isConnected = false;
  bool _isTransmitting = false;
  String _userName = 'TestUser';
  List<String> _log = [];

  // Your backend server URL
  static const String serverUrl = 'https://10.0.2.2:44301'; // Android emulator
  // static const String serverUrl = 'https://localhost:44301'; // iOS simulator

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    try {
      setState(() {
        _status = 'Connecting...';
      });

      // Test connection to backend
      final response = await http.get(
        Uri.parse('$serverUrl/api/PttTest/check-database'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
          _status = 'Connected to PTT Server';
        });
        _addLog('✅ Connected to backend server');
        _addLog('📡 Server response: ${response.body}');
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _status = 'Connection Failed: $e';
      });
      _addLog('❌ Connection failed: $e');
    }
  }

  Future<void> _testPttConnection() async {
    try {
      _addLog('🔄 Testing PTT connection...');
      
      final response = await http.get(
        Uri.parse('$serverUrl/api/PttTest/current-user-info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addLog('✅ PTT API working: ${data.toString()}');
      } else {
        _addLog('⚠️ PTT API response: ${response.statusCode}');
      }
    } catch (e) {
      _addLog('❌ PTT test failed: $e');
    }
  }

  Future<void> _simulateVoiceTransmission() async {
    if (!_isConnected) {
      _addLog('❌ Not connected to server');
      return;
    }

    setState(() {
      _isTransmitting = true;
    });

    _addLog('🎙️ Simulating voice transmission...');
    
    // Simulate transmission delay
    await Future.delayed(const Duration(seconds: 2));
    
    _addLog('📡 Voice data sent to server');
    _addLog('🔊 Other users would hear this transmission');

    setState(() {
      _isTransmitting = false;
    });
  }

  void _addLog(String message) {
    setState(() {
      _log.insert(0, '${DateTime.now().toString().substring(11, 19)} $message');
      if (_log.length > 20) {
        _log.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PTT - $_userName'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
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
                  const SizedBox(height: 8),
                  Text(
                    'Server: $serverUrl',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PTT Button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTapDown: _isConnected ? (_) => _simulateVoiceTransmission() : null,
                  child: Container(
                    width: 200,
                    height: 200,
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
                          size: 60,
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

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _connectToServer,
                  child: const Text('Reconnect'),
                ),
                ElevatedButton(
                  onPressed: _testPttConnection,
                  child: const Text('Test PTT'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Activity Log
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Activity Log',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            _log[index],
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
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
