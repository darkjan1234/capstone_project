import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PttService {
  static final PttService _instance = PttService._internal();
  factory PttService() => _instance;
  PttService._internal();

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  HubConnection? _hubConnection;
  String? _currentGroup;
  String? _authToken;
  bool _isRecording = false;
  bool _isConnected = false;

  // Events
  final StreamController<Map<String, dynamic>> _audioReceived = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _userStatusChanged = StreamController.broadcast();
  final StreamController<bool> _connectionStatusChanged = StreamController.broadcast();

  Stream<Map<String, dynamic>> get audioReceived => _audioReceived.stream;
  Stream<Map<String, dynamic>> get userStatusChanged => _userStatusChanged.stream;
  Stream<bool> get connectionStatusChanged => _connectionStatusChanged.stream;

  bool get isRecording => _isRecording;
  bool get isConnected => _isConnected;

  Future<void> initialize(String token) async {
    _authToken = token;
    
    // Initialize audio
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    
    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _testServerConnectivity(String serverUrl) async {
    try {
      print('🧪 Testing basic server connectivity...');
      final response = await http.get(
        Uri.parse('$serverUrl/swagger/index.html'),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ Server is reachable at $serverUrl');
      } else {
        print('⚠️ Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Server connectivity test failed: $e');
      throw Exception('Cannot reach server at $serverUrl');
    }
  }

  Future<void> connectToHub(String serverUrl) async {
    try {
      print('🔗 Attempting to connect to PTT Hub...');
      print('🔗 Server URL: $serverUrl');
      print('🔗 Full SignalR URL: $serverUrl/signalr-ptt');
      print('🔗 Auth Token: ${_authToken?.substring(0, 20)}...');

      // Test basic server connectivity first
      await _testServerConnectivity(serverUrl);

      // Create SignalR connection with authentication
      _hubConnection = HubConnectionBuilder()
          .withUrl('$serverUrl/signalr-ptt', HttpConnectionOptions(
            accessTokenFactory: () async => _authToken,
            transport: HttpTransportType.webSockets,
          ))
          .withAutomaticReconnect([0, 2000, 10000, 30000])
          .build();

      // Set up event handlers
      _hubConnection!.on('ReceiveAudio', (List<Object?>? arguments) => _onAudioReceived(arguments));
      _hubConnection!.on('UserJoined', (List<Object?>? arguments) => _onUserJoined(arguments));
      _hubConnection!.on('UserLeft', (List<Object?>? arguments) => _onUserLeft(arguments));
      _hubConnection!.on('UserStartedTalking', (List<Object?>? arguments) => _onUserStartedTalking(arguments));
      _hubConnection!.on('UserStoppedTalking', (List<Object?>? arguments) => _onUserStoppedTalking(arguments));
      _hubConnection!.on('GroupMembers', (List<Object?>? arguments) => _onGroupMembers(arguments));

      // Connection state change handlers
      _hubConnection!.onclose((error) {
        print('🔌 SignalR connection closed: $error');
        _isConnected = false;
        _connectionStatusChanged.add(false);
      });

      _hubConnection!.onreconnecting((error) {
        print('🔄 SignalR reconnecting: $error');
        _isConnected = false;
        _connectionStatusChanged.add(false);
      });

      _hubConnection!.onreconnected((connectionId) {
        print('✅ SignalR reconnected with ID: $connectionId');
        _isConnected = true;
        _connectionStatusChanged.add(true);
      });

      print('🔗 Starting SignalR connection...');
      await _hubConnection!.start();
      _isConnected = true;
      _connectionStatusChanged.add(true);

      print('✅ Connected to PTT Hub successfully!');
    } catch (e) {
      print('❌ Failed to connect to PTT Hub: $e');
      print('❌ Error type: ${e.runtimeType}');
      _isConnected = false;
      _connectionStatusChanged.add(false);
      rethrow;
    }
  }

  Future<void> joinGroup(String groupName) async {
    if (_hubConnection == null || !_isConnected) return;
    
    _currentGroup = groupName;
    await _hubConnection!.invoke('JoinGroup', args: [groupName]);
  }

  Future<void> leaveGroup() async {
    if (_hubConnection == null || !_isConnected || _currentGroup == null) return;

    await _hubConnection!.invoke('LeaveGroup', args: [_currentGroup!]);
    _currentGroup = null;
  }

  Future<void> startRecording() async {
    if (_isRecording || _currentGroup == null || !_isConnected) return;

    try {
      // Check microphone permission
      final micPermission = await Permission.microphone.status;
      if (!micPermission.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          throw Exception('Microphone permission denied');
        }
      }

      // Notify group that user started talking
      if (_hubConnection != null) {
        await _hubConnection!.invoke('StartTalking', args: [_currentGroup!]);
      }

      // Get temporary directory for recording
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/ptt_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start recording with optimized settings for voice
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000, // 16kHz is good for voice
        numChannels: 1,    // Mono
        bitRate: 128000,   // 128kbps
      );

      _isRecording = true;
      print('🎤 Started recording to: $filePath');
    } catch (e) {
      print('❌ Failed to start recording: $e');
      _isRecording = false;
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording || _currentGroup == null) return;

    try {
      final path = await _recorder!.stopRecorder();
      _isRecording = false;

      // Notify group that user stopped talking
      if (_hubConnection != null && _isConnected) {
        await _hubConnection!.invoke('StopTalking', args: [_currentGroup!]);
      }

      if (path != null && File(path).existsSync()) {
        print('🎤 Stopped recording. File size: ${File(path).lengthSync()} bytes');
        // Convert audio to base64 and send
        await _sendAudioFile(path);
      } else {
        print('⚠️ Recording stopped but no file found');
      }

      print('🎤 Recording stopped');
    } catch (e) {
      print('❌ Failed to stop recording: $e');
      _isRecording = false;
    }
  }

  Future<void> _sendAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ Audio file does not exist: $filePath');
        return;
      }

      final bytes = await file.readAsBytes();
      print('📤 Sending audio file: ${bytes.length} bytes');

      // Check if file is too large (limit to 1MB for now)
      if (bytes.length > 1024 * 1024) {
        print('⚠️ Audio file too large: ${bytes.length} bytes');
        await file.delete();
        return;
      }

      final base64Audio = base64Encode(bytes);

      // Calculate duration estimate (16kHz, 16-bit, mono = 32000 bytes per second)
      final duration = (bytes.length / 32000).round().clamp(1, 60); // 1-60 seconds

      print('📤 Sending audio: ${base64Audio.length} chars, duration: ${duration}s');

      // Send via SignalR
      if (_hubConnection != null && _isConnected) {
        await _hubConnection!.invoke('SendAudioData', args: [
          _currentGroup!,
          base64Audio,
          duration
        ]);
        print('✅ Audio sent successfully');
      } else {
        print('❌ Cannot send audio: not connected to hub');
      }

      // Clean up temporary file
      await file.delete();
    } catch (e) {
      print('❌ Failed to send audio: $e');
      // Try to clean up file even if sending failed
      try {
        await File(filePath).delete();
      } catch (deleteError) {
        print('⚠️ Failed to delete temp file: $deleteError');
      }
    }
  }

  Future<void> playAudio(String base64Audio) async {
    try {
      print('🔊 Playing received audio...');

      // Decode base64 to bytes
      final bytes = base64Decode(base64Audio);
      print('🔊 Decoded audio: ${bytes.length} bytes');

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/received_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Stop any currently playing audio
      if (_player!.isPlaying) {
        await _player!.stopPlayer();
      }

      // Play the audio
      await _player!.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          print('🔊 Audio playback finished');
          // Clean up file after playback
          file.delete().catchError((e) => print('⚠️ Failed to delete temp audio file: $e'));
        },
      );

      print('🔊 Started audio playback');
    } catch (e) {
      print('❌ Failed to play audio: $e');
    }
  }

  // Event handlers
  void _onAudioReceived(List<Object?>? arguments) {
    try {
      if (arguments != null && arguments.isNotEmpty) {
        print('🎵 Received audio data from SignalR');
        final data = arguments[0] as Map<String, dynamic>;

        // Add to stream for UI updates
        _audioReceived.add({
          'UserId': data['UserId'],
          'Duration': data['Duration'],
          'Timestamp': data['Timestamp'].toString(),
        });

        // Auto-play received audio
        if (data['AudioData'] != null) {
          print('🎵 Auto-playing received audio from ${data['UserId']}');
          playAudio(data['AudioData'].toString());
        }
      }
    } catch (e) {
      print('❌ Error handling received audio: $e');
    }
  }

  void _onUserJoined(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      _userStatusChanged.add({
        'type': 'joined',
        'data': data
      });
    }
  }

  void _onUserLeft(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      _userStatusChanged.add({
        'type': 'left',
        'data': data
      });
    }
  }

  void _onUserStartedTalking(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      _userStatusChanged.add({
        'type': 'started_talking',
        'data': data
      });
    }
  }

  void _onUserStoppedTalking(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      _userStatusChanged.add({
        'type': 'stopped_talking',
        'data': data
      });
    }
  }

  void _onGroupMembers(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as List<dynamic>;
      _userStatusChanged.add({
        'type': 'group_members',
        'data': data
      });
    }
  }

  Future<void> dispose() async {
    await _recorder?.closeRecorder();
    await _player?.closePlayer();
    await _hubConnection?.stop();
    await _audioReceived.close();
    await _userStatusChanged.close();
    await _connectionStatusChanged.close();
  }
}
