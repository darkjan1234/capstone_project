import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(GroupPttApp());
}

class GroupPttApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group PTT System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _workingServerUrl;

  // Test different server URLs
  final List<String> _serverUrls = [
    'http://192.168.137.1:44311',
    'http://192.168.1.28:44311',
    'http://10.0.2.2:44311',
    'http://localhost:44311',
  ];

  @override
  void initState() {
    super.initState();
    _findWorkingServer();
  }

  Future<void> _findWorkingServer() async {
    for (String url in _serverUrls) {
      try {
        final response = await http.get(
          Uri.parse('$url/api/services/app/Session/GetCurrentLoginInformations'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 5));
        
        if (response.statusCode == 200 || response.statusCode == 401) {
          setState(() {
            _workingServerUrl = url;
          });
          print('✅ Found working server: $url');
          break;
        }
      } catch (e) {
        print('❌ Server $url not reachable');
      }
    }
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter both username and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_workingServerUrl == null) {
        await _findWorkingServer();
      }

      if (_workingServerUrl == null) {
        _showError('Cannot connect to server. Make sure backend is running.');
        return;
      }

      final response = await http.post(
        Uri.parse('$_workingServerUrl/api/TokenAuth/Authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userNameOrEmailAddress': _usernameController.text.trim(),
          'password': _passwordController.text,
          'rememberClient': true,
        }),
      ).timeout(Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        if (body['success'] == true && body['result'] != null) {
          final token = body['result']['accessToken'];
          final userId = body['result']['userId'];
          
          // Navigate to PTT screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GroupPttScreen(
                token: token,
                serverUrl: _workingServerUrl!,
                username: _usernameController.text.trim(),
                userId: userId,
              ),
            ),
          );
        } else {
          _showError(body['error']?['message'] ?? 'Login failed');
        }
      } else {
        final body = jsonDecode(response.body);
        _showError(body['error']?['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      _showError('Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(Icons.radio, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'Group PTT System',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              
              // Login Form
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
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
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('LOGIN TO PTT', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Test Accounts
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('🔑 Available Test Accounts:', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    _buildAccountButton('admin', '123qwe', 'Admin - All Groups', Colors.green),
                    _buildAccountButton('test123', '123qwe', 'Team Alpha Member', Colors.orange),
                    _buildAccountButton('user', '123qwe', 'Team Beta Member', Colors.orange),
                    _buildAccountButton('user1', '123qwe', 'Security Team Member', Colors.orange),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              Text(
                'Server: ${_workingServerUrl ?? "Searching..."}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountButton(String username, String password, String description, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _usernameController.text = username;
          _passwordController.text = password;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text('$username / $password ($description)'),
      ),
    );
  }
}

class GroupPttScreen extends StatefulWidget {
  final String token;
  final String serverUrl;
  final String username;
  final int userId;

  GroupPttScreen({
    required this.token,
    required this.serverUrl,
    required this.username,
    required this.userId,
  });

  @override
  _GroupPttScreenState createState() => _GroupPttScreenState();
}

class _GroupPttScreenState extends State<GroupPttScreen> {
  List<Map<String, dynamic>> _groups = [];
  Map<String, dynamic>? _selectedGroup;
  List<Map<String, dynamic>> _groupMembers = [];
  bool _isLoading = true;
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _loadUserGroups();
  }

  Future<void> _initializeAudio() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    
    await Permission.microphone.request();
    await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  Future<void> _loadUserGroups() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/services/app/PttGroup/GetMyGroups'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          setState(() {
            _groups = List<Map<String, dynamic>>.from(body['result'] ?? []);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading groups: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectGroup(Map<String, dynamic> group) async {
    setState(() {
      _selectedGroup = group;
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/services/app/PttGroup/GetGroupMembers?groupId=${group['id']}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          setState(() {
            _groupMembers = List<Map<String, dynamic>>.from(body['result'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error loading group members: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group PTT - ${widget.username}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _selectedGroup == null
              ? _buildGroupsList()
              : _buildPttInterface(),
    );
  }

  Widget _buildGroupsList() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select a PTT Group',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              final group = _groups[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.group, color: Colors.blue),
                  title: Text(group['name'] ?? 'Unknown Group'),
                  subtitle: Text(group['description'] ?? 'No description'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectGroup(group),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPttInterface() {
    return Column(
      children: [
        // Group Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Text(
                _selectedGroup!['name'] ?? 'Unknown Group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(_selectedGroup!['description'] ?? ''),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => setState(() => _selectedGroup = null),
                child: Text('← Back to Groups'),
              ),
            ],
          ),
        ),
        
        // Group Members
        Expanded(
          child: ListView.builder(
            itemCount: _groupMembers.length,
            itemBuilder: (context, index) {
              final member = _groupMembers[index];
              final isCurrentUser = member['userName'] == widget.username;
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: isCurrentUser ? Colors.blue.shade50 : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentUser ? Colors.blue : Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(member['name'] ?? member['userName'] ?? 'Unknown'),
                  subtitle: Text(isCurrentUser ? 'You' : 'Group Member'),
                  trailing: isCurrentUser 
                      ? Icon(Icons.star, color: Colors.blue)
                      : null,
                ),
              );
            },
          ),
        ),
        
        // PTT Controls
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            children: [
              Text(
                'Push to Talk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTapDown: (_) => _startRecording(),
                onTapUp: (_) => _stopRecording(),
                onTapCancel: () => _stopRecording(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: _isRecording ? Colors.red.shade300 : Colors.blue.shade300,
                        blurRadius: 20,
                        spreadRadius: _isRecording ? 10 : 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                _isRecording ? 'Recording... Release to send' : 'Hold to talk',
                style: TextStyle(
                  color: _isRecording ? Colors.red : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    if (_recorder != null && !_isRecording) {
      setState(() => _isRecording = true);
      
      try {
        await _recorder!.startRecorder(
          toFile: 'ptt_message.aac',
          codec: Codec.aacADTS,
        );
        print('🎤 Started recording');
      } catch (e) {
        print('Error starting recording: $e');
        setState(() => _isRecording = false);
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder != null && _isRecording) {
      setState(() => _isRecording = false);
      
      try {
        final path = await _recorder!.stopRecorder();
        print('🎤 Stopped recording: $path');
        
        if (path != null) {
          _recordedFilePath = path;
          _sendPttMessage(path);
        }
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _sendPttMessage(String audioPath) async {
    // Here you would implement sending the audio to the group
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PTT message sent to ${_selectedGroup!['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }
}
