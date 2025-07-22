import 'package:flutter/material.dart';
import 'ptt_service.dart';
import 'dart:async';

class PttScreen extends StatefulWidget {
  final String token;
  final String serverUrl;

  const PttScreen({
    Key? key,
    required this.token,
    required this.serverUrl,
  }) : super(key: key);

  @override
  State<PttScreen> createState() => _PttScreenState();
}

class _PttScreenState extends State<PttScreen> {
  final PttService _pttService = PttService();
  final TextEditingController _groupController = TextEditingController();
  
  bool _isConnected = false;
  bool _isInGroup = false;
  String? _currentGroup;
  List<Map<String, dynamic>> _groupMembers = [];
  List<Map<String, dynamic>> _messages = [];
  Map<String, bool> _talkingUsers = {};

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
            'message': event['data']['Message'],
            'timestamp': DateTime.now(),
          });
          break;
        case 'left':
          _messages.add({
            'type': 'system',
            'message': event['data']['Message'],
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
          _groupMembers = List<Map<String, dynamic>>.from(event['data']);
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
  }

  Future<void> _joinGroup() async {
    if (_groupController.text.isEmpty) return;

    try {
      await _pttService.joinGroup(_groupController.text);
      setState(() {
        _isInGroup = true;
        _currentGroup = _groupController.text;
        _messages.clear();
        _groupMembers.clear();
        _talkingUsers.clear();
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PTT - ${_currentGroup ?? 'Not Connected'}'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        actions: [
          if (_isInGroup)
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _leaveGroup,
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
            child: Text(
              _isConnected ? 'Connected to PTT Server' : 'Disconnected',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Group Join Section
          if (!_isInGroup) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _groupController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isConnected ? _joinGroup : null,
                    child: Text('Join Group'),
                  ),
                ],
              ),
            ),
          ],

          // Group Members
          if (_isInGroup && _groupMembers.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Group Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    children: _groupMembers.map((member) {
                      final isTalking = _talkingUsers[member['UserId']] ?? false;
                      return Chip(
                        label: Text(member['UserId']),
                        backgroundColor: isTalking ? Colors.green.shade200 : null,
                        avatar: isTalking ? Icon(Icons.mic, size: 16) : null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Messages
          if (_isInGroup) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ListTile(
                    leading: Icon(
                      message['type'] == 'audio' ? Icons.volume_up : Icons.info,
                      color: message['type'] == 'audio' ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      message['type'] == 'audio' 
                        ? 'Audio from ${message['userId']}'
                        : message['message'],
                    ),
                    subtitle: Text(
                      message['type'] == 'audio'
                        ? 'Duration: ${message['duration']}s'
                        : '',
                    ),
                    trailing: Text(
                      '${message['timestamp'].hour}:${message['timestamp'].minute.toString().padLeft(2, '0')}',
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),

      // PTT Button
      floatingActionButton: _isInGroup
          ? GestureDetector(
              onTapDown: (_) => _pttService.startRecording(),
              onTapUp: (_) => _pttService.stopRecording(),
              onTapCancel: () => _pttService.stopRecording(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pttService.isRecording ? Colors.red : Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _userStatusSub?.cancel();
    _audioSub?.cancel();
    _pttService.dispose();
    _groupController.dispose();
    super.dispose();
  }
}
