import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_netcore/signalr_client.dart';
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

  Future<void> connectToHub(String serverUrl) async {
    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl('$serverUrl/signalr-ptt',
              options: HttpConnectionOptions(
                accessTokenFactory: () async => _authToken ?? '',
              ))
          .build();

      // Set up event handlers
      _hubConnection!.on('ReceiveAudio', _onAudioReceived);
      _hubConnection!.on('UserJoined', _onUserJoined);
      _hubConnection!.on('UserLeft', _onUserLeft);
      _hubConnection!.on('UserStartedTalking', _onUserStartedTalking);
      _hubConnection!.on('UserStoppedTalking', _onUserStoppedTalking);
      _hubConnection!.on('GroupMembers', _onGroupMembers);

      await _hubConnection!.start();
      _isConnected = true;
      _connectionStatusChanged.add(true);
      
      print('Connected to PTT Hub');
    } catch (e) {
      print('Failed to connect to PTT Hub: $e');
      _isConnected = false;
      _connectionStatusChanged.add(false);
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
    if (_isRecording || _currentGroup == null) return;

    try {
      // Notify group that user started talking
      await _hubConnection!.invoke('StartTalking', args: [_currentGroup!]);

      // Get temporary directory for recording
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/ptt_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
      );

      _isRecording = true;
      print('Started recording');
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording || _currentGroup == null) return;

    try {
      final path = await _recorder!.stopRecorder();
      _isRecording = false;

      // Notify group that user stopped talking
      await _hubConnection!.invoke('StopTalking', args: [_currentGroup!]);

      if (path != null) {
        // Convert audio to base64 and send
        await _sendAudioFile(path);
      }

      print('Stopped recording');
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> _sendAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);
      
      // Calculate duration (simplified - you might want to use a proper audio library)
      final duration = (bytes.length / 16000).round(); // Rough estimate for 16kHz PCM

      // Send via SignalR
      await _hubConnection!.invoke('SendAudioData', args: [
        _currentGroup!,
        base64Audio,
        duration
      ]);

      // Clean up temporary file
      await file.delete();
    } catch (e) {
      print('Failed to send audio: $e');
    }
  }

  Future<void> playAudio(String base64Audio) async {
    try {
      // Decode base64 to bytes
      final bytes = base64Decode(base64Audio);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/received_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Play the audio
      await _player!.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
      );

      // Clean up after playing
      _player!.onProgress!.listen((event) {
        if (event.position >= event.duration) {
          file.delete();
        }
      });
    } catch (e) {
      print('Failed to play audio: $e');
    }
  }

  // Event handlers
  void _onAudioReceived(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      _audioReceived.add(data);
      
      // Auto-play received audio
      if (data['AudioData'] != null) {
        playAudio(data['AudioData']);
      }
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
