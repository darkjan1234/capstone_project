import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class PttService {
  static const String serverUrl = 'https://10.0.2.2:44301'; // Android emulator
  // static const String serverUrl = 'https://localhost:44301'; // iOS simulator
  
  HubConnection? _hubConnection;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isConnected = false;
  bool _isTransmitting = false;
  String? _currentUser;
  int? _currentUserId;
  
  // Callbacks
  Function(String message)? onStatusChanged;
  Function(String userName)? onUserJoined;
  Function(String userName)? onUserLeft;
  Function(String userName)? onTransmissionStarted;
  Function(String userName)? onTransmissionStopped;
  Function(String userName)? onVoiceReceived;
  Function(String error)? onError;

  bool get isConnected => _isConnected;
  bool get isTransmitting => _isTransmitting;
  String? get currentUser => _currentUser;

  /// Initialize PTT service
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        onError?.call('Microphone permission denied');
        return false;
      }

      onStatusChanged?.call('PTT Service initialized');
      return true;
    } catch (e) {
      onError?.call('Failed to initialize PTT service: $e');
      return false;
    }
  }

  /// Connect to PTT system
  Future<bool> connect(int userId, String userName) async {
    try {
      if (_isConnected) {
        await disconnect();
      }

      onStatusChanged?.call('Connecting to PTT server...');

      // Create SignalR connection
      _hubConnection = HubConnectionBuilder()
          .withUrl('$serverUrl/signalr-ptt-voice')
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _setupEventHandlers();

      // Start connection
      await _hubConnection!.start();
      
      // Join PTT system
      await _hubConnection!.invoke('JoinPttSystem', args: [userId, userName]);

      _isConnected = true;
      _currentUser = userName;
      _currentUserId = userId;

      onStatusChanged?.call('Connected to PTT system as $userName');
      return true;

    } catch (e) {
      onError?.call('Failed to connect: $e');
      return false;
    }
  }

  /// Disconnect from PTT system
  Future<void> disconnect() async {
    try {
      if (_isTransmitting) {
        await stopTransmission();
      }

      if (_hubConnection != null) {
        await _hubConnection!.stop();
        _hubConnection = null;
      }

      _isConnected = false;
      _currentUser = null;
      _currentUserId = null;

      onStatusChanged?.call('Disconnected from PTT system');
    } catch (e) {
      onError?.call('Error disconnecting: $e');
    }
  }

  /// Start voice transmission (Push-to-Talk pressed)
  Future<bool> startTransmission() async {
    try {
      if (!_isConnected || _isTransmitting) {
        return false;
      }

      // Check microphone permission
      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        onError?.call('Microphone permission required');
        return false;
      }

      // Start transmission on server
      await _hubConnection!.invoke('StartTransmission', args: [1, _currentUser]);

      // Start recording
      await _startRecording();

      _isTransmitting = true;
      onStatusChanged?.call('Transmitting...');
      return true;

    } catch (e) {
      onError?.call('Failed to start transmission: $e');
      return false;
    }
  }

  /// Stop voice transmission (Push-to-Talk released)
  Future<void> stopTransmission() async {
    try {
      if (!_isTransmitting) return;

      // Stop recording
      await _stopRecording();

      // Stop transmission on server
      if (_isConnected) {
        await _hubConnection!.invoke('StopTransmission', args: [1, _currentUser]);
      }

      _isTransmitting = false;
      onStatusChanged?.call('Connected');

    } catch (e) {
      onError?.call('Error stopping transmission: $e');
    }
  }

  /// Start audio recording
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Start recording with specific config for real-time transmission
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
        );

        // Start streaming audio data
        _streamAudioData();
      }
    } catch (e) {
      onError?.call('Failed to start recording: $e');
    }
  }

  /// Stop audio recording
  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
    } catch (e) {
      onError?.call('Failed to stop recording: $e');
    }
  }

  /// Stream audio data to server
  void _streamAudioData() async {
    try {
      // This is a simplified approach - in production you'd want to stream chunks
      // For now, we'll record and send when transmission stops
      // Real-time streaming would require more complex implementation
    } catch (e) {
      onError?.call('Error streaming audio: $e');
    }
  }

  /// Play received audio
  Future<void> _playReceivedAudio(String audioData) async {
    try {
      // Decode base64 audio data
      final bytes = base64Decode(audioData);
      
      // Create temporary file and play
      final tempFile = File('${Directory.systemTemp.path}/received_audio.aac');
      await tempFile.writeAsBytes(bytes);
      
      await _audioPlayer.play(DeviceFileSource(tempFile.path));
      
      onVoiceReceived?.call('Audio played');
      
    } catch (e) {
      onError?.call('Failed to play audio: $e');
    }
  }

  /// Set up SignalR event handlers
  void _setupEventHandlers() {
    _hubConnection!.on('UserJoined', (arguments) {
      final data = arguments?[0] as Map<String, dynamic>?;
      if (data != null) {
        onUserJoined?.call(data['UserName'] ?? 'Unknown');
      }
    });

    _hubConnection!.on('UserLeft', (arguments) {
      final data = arguments?[0] as Map<String, dynamic>?;
      if (data != null) {
        onUserLeft?.call(data['UserName'] ?? 'Unknown');
      }
    });

    _hubConnection!.on('TransmissionStarted', (arguments) {
      final data = arguments?[0] as Map<String, dynamic>?;
      if (data != null) {
        onTransmissionStarted?.call(data['UserName'] ?? 'Unknown');
      }
    });

    _hubConnection!.on('TransmissionStopped', (arguments) {
      final data = arguments?[0] as Map<String, dynamic>?;
      if (data != null) {
        onTransmissionStopped?.call(data['UserName'] ?? 'Unknown');
      }
    });

    _hubConnection!.on('ReceiveVoice', (arguments) {
      final data = arguments?[0] as Map<String, dynamic>?;
      if (data != null) {
        final audioData = data['AudioData'] as String?;
        final userName = data['UserName'] as String?;
        
        if (audioData != null && userName != null) {
          _playReceivedAudio(audioData);
          onVoiceReceived?.call(userName);
        }
      }
    });

    _hubConnection!.on('Error', (arguments) {
      final message = arguments?[0] as String? ?? 'Unknown error';
      onError?.call(message);
    });
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}
