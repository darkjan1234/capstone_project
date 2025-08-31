import 'package:flutter/material.dart';
import '../services/ptt_service.dart';

class PttScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const PttScreen({
    Key? key,
    required this.userName,
    required this.userId,
  }) : super(key: key);

  @override
  State<PttScreen> createState() => _PttScreenState();
}

class _PttScreenState extends State<PttScreen> {
  final PttService _pttService = PttService();
  
  bool _isConnected = false;
  bool _isTransmitting = false;
  String _status = 'Disconnected';
  List<String> _activityLog = [];
  List<String> _onlineUsers = [];
  String? _currentSpeaker;

  @override
  void initState() {
    super.initState();
    _setupPttService();
    _initializePtt();
  }

  void _setupPttService() {
    _pttService.onStatusChanged = (message) {
      setState(() {
        _status = message;
      });
      _addToLog(message);
    };

    _pttService.onUserJoined = (userName) {
      setState(() {
        if (!_onlineUsers.contains(userName)) {
          _onlineUsers.add(userName);
        }
      });
      _addToLog('👤 $userName joined');
    };

    _pttService.onUserLeft = (userName) {
      setState(() {
        _onlineUsers.remove(userName);
      });
      _addToLog('👤 $userName left');
    };

    _pttService.onTransmissionStarted = (userName) {
      setState(() {
        _currentSpeaker = userName;
      });
      _addToLog('🎙️ $userName started talking');
    };

    _pttService.onTransmissionStopped = (userName) {
      setState(() {
        _currentSpeaker = null;
      });
      _addToLog('🔇 $userName stopped talking');
    };

    _pttService.onVoiceReceived = (userName) {
      _addToLog('🔊 Received voice from $userName');
    };

    _pttService.onError = (error) {
      _addToLog('❌ Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    };
  }

  Future<void> _initializePtt() async {
    final success = await _pttService.initialize();
    if (success) {
      _connectToPtt();
    }
  }

  Future<void> _connectToPtt() async {
    final success = await _pttService.connect(widget.userId, widget.userName);
    setState(() {
      _isConnected = success;
    });
  }

  Future<void> _disconnect() async {
    await _pttService.disconnect();
    setState(() {
      _isConnected = false;
      _isTransmitting = false;
      _onlineUsers.clear();
      _currentSpeaker = null;
    });
  }

  Future<void> _startTransmission() async {
    final success = await _pttService.startTransmission();
    setState(() {
      _isTransmitting = success;
    });
  }

  Future<void> _stopTransmission() async {
    await _pttService.stopTransmission();
    setState(() {
      _isTransmitting = false;
    });
  }

  void _addToLog(String message) {
    setState(() {
      _activityLog.insert(0, '${DateTime.now().toString().substring(11, 19)} $message');
      if (_activityLog.length > 50) {
        _activityLog.removeLast();
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
            onPressed: _isConnected ? _disconnect : _connectToPtt,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                if (_currentSpeaker != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '🎙️ $_currentSpeaker is talking...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // PTT Button
          Expanded(
            flex: 2,
            child: Center(
              child: GestureDetector(
                onTapDown: _isConnected ? (_) => _startTransmission() : null,
                onTapUp: _isConnected ? (_) => _stopTransmission() : null,
                onTapCancel: _isConnected ? () => _stopTransmission() : null,
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
                          fontSize: 16,
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

          // Online Users
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🟢 Online Users (${_onlineUsers.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _onlineUsers.isEmpty
                    ? const Text('No users online')
                    : Wrap(
                        spacing: 8,
                        children: _onlineUsers.map((user) => Chip(
                          label: Text(user),
                          backgroundColor: user == _currentSpeaker 
                              ? Colors.orange.shade200 
                              : Colors.blue.shade100,
                        )).toList(),
                      ),
              ],
            ),
          ),

          // Activity Log
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
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
                      itemCount: _activityLog.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _activityLog[index],
                            style: const TextStyle(
                              fontSize: 12,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pttService.dispose();
    super.dispose();
  }
}
