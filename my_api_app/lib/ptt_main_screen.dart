import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ptt_service.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'dart:async';

class PttMainScreen extends StatefulWidget {
  final String token;
  final String serverUrl;
  final String userId;

  const PttMainScreen({
    Key? key,
    required this.token,
    required this.serverUrl,
    required this.userId,
  }) : super(key: key);

  @override
  State<PttMainScreen> createState() => _PttMainScreenState();
}

class _PttMainScreenState extends State<PttMainScreen> {
  final PttService _pttService = PttService();
  
  bool _isConnected = false;
  bool _isInGroup = false;
  bool _isPushingToTalk = false;
  String? _currentGroup;
  List<String> _groupMembers = [];
  List<Map<String, dynamic>> _messages = [];
  Map<String, bool> _talkingUsers = {};
  
  // Predefined groups from your mockup
  final List<String> _availableGroups = [
    'Sir Toto',
    'maam Jacky', 
    'Radio 2',
    'Radio 3',
    '000401',
    '00001',
    '000200',
  ];

  StreamSubscription? _connectionSub;
  StreamSubscription? _userStatusSub;
  StreamSubscription? _audioSub;

  @override
  void initState() {
    super.initState();
    _initializePtt();
  }

  Future<void> _initializePtt() async {
    try {
      await _pttService.initialize(widget.token);
      await _pttService.connectToHub(widget.serverUrl);
      
      // Listen to connection status
      _connectionSub = _pttService.connectionStatusChanged.listen((connected) {
        setState(() {
          _isConnected = connected;
        });
      });

      // Listen to user status changes
      _userStatusSub = _pttService.userStatusChanged.listen((event) {
        _handleUserStatusChange(event);
      });

      // Listen to audio messages
      _audioSub = _pttService.audioReceived.listen((event) {
        _handleAudioReceived(event);
      });

    } catch (e) {
      _showError('Failed to initialize PTT: $e');
    }
  }

  void _handleUserStatusChange(Map<String, dynamic> event) {
    setState(() {
      switch (event['type']) {
        case 'joined':
          _messages.add({
            'type': 'system',
            'message': '${event['data']['UserId']} joined the group',
            'timestamp': DateTime.now(),
          });
          break;
        case 'left':
          _messages.add({
            'type': 'system', 
            'message': '${event['data']['UserId']} left the group',
            'timestamp': DateTime.now(),
          });
          break;
        case 'started_talking':
          _talkingUsers[event['data']['UserId']] = true;
          break;
        case 'stopped_talking':
          _talkingUsers[event['data']['UserId']] = false;
          break;
        case 'group_members':
          _groupMembers = List<String>.from(event['data']);
          break;
      }
    });
  }

  void _handleAudioReceived(Map<String, dynamic> event) {
    setState(() {
      _messages.add({
        'type': 'audio',
        'userId': event['UserId'],
        'duration': event['Duration'],
        'timestamp': DateTime.parse(event['Timestamp']),
      });
    });
    
    // Play notification sound or visual indicator
    HapticFeedback.lightImpact();
  }

  Future<void> _joinGroup(String groupName) async {
    try {
      await _pttService.joinGroup(groupName);
      setState(() {
        _isInGroup = true;
        _currentGroup = groupName;
        _messages.clear();
        _groupMembers.clear();
        _talkingUsers.clear();
      });
      
      _messages.add({
        'type': 'system',
        'message': 'You are now connected to this Group.',
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      _showError('Failed to join group: $e');
    }
  }

  Future<void> _leaveGroup() async {
    try {
      await _pttService.leaveGroup();
      setState(() {
        _isInGroup = false;
        _currentGroup = null;
        _messages.clear();
        _groupMembers.clear();
        _talkingUsers.clear();
      });
    } catch (e) {
      _showError('Failed to leave group: $e');
    }
  }

  void _startPushToTalk() {
    if (!_isInGroup || _isPushingToTalk) return;

    setState(() {
      _isPushingToTalk = true;
    });

    HapticFeedback.mediumImpact();
    _pttService.startRecording();

    // Add visual feedback
    _messages.add({
      'type': 'system',
      'message': 'You started talking...',
      'timestamp': DateTime.now(),
    });
  }

  void _stopPushToTalk() {
    if (!_isPushingToTalk) return;

    setState(() {
      _isPushingToTalk = false;
    });

    HapticFeedback.lightImpact();
    _pttService.stopRecording();

    // Add visual feedback
    setState(() {
      _messages.add({
        'type': 'system',
        'message': 'Message sent!',
        'timestamp': DateTime.now(),
      });
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4CAF50), // Green background like mockup
      body: SafeArea(
        child: _isInGroup ? _buildPttInterface() : _buildGroupSelection(),
      ),
    );
  }

  Widget _buildGroupSelection() {
    return Column(
      children: [
        // Header with logo and logout
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _logout,
                child: Text(
                  'LOG OUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Logo placeholder (you can add your actual logo here)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.radio,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminScreen(
                            token: widget.token,
                            serverUrl: widget.serverUrl,
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.settings, color: Colors.white, size: 24),
                ],
              ),
            ],
          ),
        ),
        
        // RCEU12 P01 Title
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'RCEU12 P01',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Talk Group Section
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side - Group list
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Talk Group',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: _availableGroups.length,
                            itemBuilder: (context, index) {
                              final group = _availableGroups[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 4),
                                child: ElevatedButton(
                                  onPressed: () => _joinGroup(group),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    group,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Right side - Features
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildFeatureButton('ADD CONTACT', Icons.person_add),
                      SizedBox(height: 8),
                      _buildFeatureButton('Speech to text', Icons.mic),
                      SizedBox(height: 8),
                      _buildFeatureButton('Translation', Icons.translate),
                      SizedBox(height: 8),
                      _buildFeatureButton('Recents', Icons.history),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom user info
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            widget.userId,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureButton(String text, IconData icon) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (text == 'ADD CONTACT') {
            _showAddContactDialog();
          } else {
            _showError('$text feature coming soon!');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final groupController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: groupController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && groupController.text.isNotEmpty) {
                // Add to available groups if not already there
                if (!_availableGroups.contains(groupController.text)) {
                  setState(() {
                    _availableGroups.add(groupController.text);
                  });
                }
                Navigator.pop(context);
                _showError('Contact "${nameController.text}" added to group "${groupController.text}"!');
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildPttInterface() {
    return Column(
      children: [
        // Header with back button and logo
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _leaveGroup,
                child: Text(
                  'BACK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Logo placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.radio,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(width: 50), // Balance the layout
            ],
          ),
        ),

        // RCEU12 P01 Title
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'RCEU12 P01',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Connection status message
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'You are now connected on this Group.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Messages area
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Left side - Message list
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 4),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            message['type'] == 'audio'
                              ? '🎵 ${message['userId']}'
                              : message['message'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Right side - PTT Button
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Connection status indicator
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isConnected ? Color(0xFF2E7D32) : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isConnected ? 'ONLINE' : 'OFFLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // PTT Button
                      GestureDetector(
                        onTapDown: (_) => _startPushToTalk(),
                        onTapUp: (_) => _stopPushToTalk(),
                        onTapCancel: () => _stopPushToTalk(),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isPushingToTalk ? Colors.red : Colors.grey.shade400,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'PUSH',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom user info
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            _currentGroup ?? widget.userId,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _userStatusSub?.cancel();
    _audioSub?.cancel();
    _pttService.dispose();
    super.dispose();
  }
}
