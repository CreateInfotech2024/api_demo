import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:api_demo/config/mobile_optimizations.dart';
import 'dart:async';
import 'dart:developer' as developer;

class ChatMessage {
  final String id;
  final String sender;
  final String message;
  final String timestamp;
  final String? meetingCode;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.meetingCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
      'meetingCode': meetingCode,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      meetingCode: json['meetingCode'],
    );
  }
}

class ParticipantEvent {
  final String participantId;
  final String participantName;
  final bool? isHost;
  final String? joinedAt;
  final String? leftAt;
  final String? meetingCode;

  ParticipantEvent({
    required this.participantId,
    required this.participantName,
    this.isHost,
    this.joinedAt,
    this.leftAt,
    this.meetingCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'isHost': isHost,
      'joinedAt': joinedAt,
      'leftAt': leftAt,
      'meetingCode': meetingCode,
    };
  }

  factory ParticipantEvent.fromJson(Map<String, dynamic> json) {
    return ParticipantEvent(
      participantId: json['participantId'] ?? '',
      participantName: json['participantName'] ?? '',
      isHost: json['isHost'],
      joinedAt: json['joinedAt'],
      leftAt: json['leftAt'],
      meetingCode: json['meetingCode'],
    );
  }
}

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  Future<void> connect() async {
    if (_socket?.connected == true) {
      developer.log('✅ Socket already connected');
      return;
    }

    // Use environment variable or default to backend port
    const String backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'https://krishnabarasiya.space',
    );

    developer.log('🔄 Attempting to connect to: $backendUrl');

    // Use mobile-optimized socket configuration
    final socketConfig = MobileOptimizations.getSocketConfiguration();
    
    _socket = IO.io(backendUrl, socketConfig);

    // Use a Completer to wait for connection
    final completer = Completer<void>();
    bool hasCompleted = false;

    _socket?.on('connect', (_) {
      developer.log('✅ Connected to Socket.IO server at $backendUrl');
      _isConnected = true;
      if (!hasCompleted) {
        hasCompleted = true;
        completer.complete();
      }
    });

    _socket?.on('disconnect', (reason) {
      developer.log('❌ Disconnected from Socket.IO server. Reason: $reason');
      _isConnected = false;
    });

    _socket?.on('connect_error', (error) {
      developer.log('❌ Socket connection error: $error');
      _isConnected = false;
      if (!hasCompleted) {
        hasCompleted = true;
        completer.completeError('Connection failed: $error');
      }
    });

    _socket?.on('reconnect', (attemptNumber) {
      developer.log('✅ Socket reconnected after $attemptNumber attempts');
      _isConnected = true;
    });

    _socket?.on('reconnect_attempt', (attemptNumber) {
      developer.log('🔄 Socket reconnection attempt #$attemptNumber');
    });

    _socket?.on('reconnect_failed', (_) {
      developer.log('❌ Socket failed to reconnect after all attempts');
      _isConnected = false;
    });

    try {
      // Wait for connection or timeout
      await completer.future.timeout(
        Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Socket connection timeout'),
      );
      developer.log('✅ Socket connection established successfully');
    } catch (e) {
      developer.log('❌ Failed to establish socket connection: $e');
      
      // For offline scenarios, we'll continue without socket connection
      // The app should still work for local peer-to-peer connections
      developer.log('⚠️ Continuing in offline mode - some features may be limited');
      rethrow;
    }
  }

    _socket?.on('connect_error', (error) {
      print('❌ Socket.IO connection error: $error');
      _isConnected = false;
      if (!hasCompleted) {
        hasCompleted = true;
        completer.completeError('Connection failed: $error');
      }
    });

    // Wait for connection to complete or timeout
    try {
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw 'Connection timeout';
        },
      );
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket?.disconnect();
      _socket = null;
      _isConnected = false;
    }
  }

  // Join a meeting room for real-time updates
  void joinMeetingRoom(
      String meetingCode,
      String participantName, String s, bool bool, {
        String? participantId,
        bool? isHost,
      }) {
    String generateUniqueId() {
      return "${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecondsSinceEpoch}";
    }

    if (_socket != null) {
      _socket?.emit('join-meeting', {
        'meetingCode': meetingCode,
        'participantId': participantId ?? generateUniqueId(),
        'participantName': participantName,
        'isHost': isHost ?? false,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Leave a meeting room
  void leaveMeetingRoom(String meetingCode, String participantName) {
    if (_socket != null) {
      _socket?.emit('leave-meeting', {
        'meetingCode': meetingCode,
        'participantName': participantName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Send a chat message
  void sendChatMessage(String meetingCode, String sender, String message) {
    if (_socket != null) {
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sender,
        message: message,
        timestamp: DateTime.now().toIso8601String(),
        meetingCode: meetingCode,
      );

      _socket?.emit('chat-message', chatMessage.toJson());
    }
  }

  // Listen for chat messages
  void onChatMessage(Function(ChatMessage) callback) {
    if (_socket != null) {
      _socket?.on('chat-message', (data) {
        final message = ChatMessage.fromJson(data);
        callback(message);
      });
    }
  }

  // Listen for participant joined events
  void onParticipantJoined(Function(ParticipantEvent) callback) {
    if (_socket != null) {
      _socket?.on('participant-joined', (data) {
        final event = ParticipantEvent.fromJson(data);
        callback(event);
      });
    }
  }

  // Listen for participant left events
  void onParticipantLeft(Function(ParticipantEvent) callback) {
    if (_socket != null) {
      _socket?.on('participant-left', (data) {
        final event = ParticipantEvent.fromJson(data);
        callback(event);
      });
    }
  }

  // Listen for error events
  void onError(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('error', callback);
    }
  }

  // Remove all listeners for a specific event
  void removeListener(String event) {
    if (_socket != null) {
      _socket?.off(event);
    }
  }

  // Remove all listeners
  void removeAllListeners() {
    if (_socket != null) {
      _socket?.clearListeners();
    }
  }

  bool getConnectionStatus() {
    return _isConnected;
  }

  IO.Socket? getSocket() {
    return _socket;
  }

  // WebRTC signaling methods
  void sendOffer(Map<String, dynamic> offer, {String? to}) {
    if (_socket != null) {
      _socket?.emit('offer', {'offer': offer, 'to': to});
    }
  }

  void sendAnswer(Map<String, dynamic> answer, {String? to}) {
    if (_socket != null) {
      _socket?.emit('answer', {'answer': answer, 'to': to});
    }
  }

  void sendIceCandidate(Map<String, dynamic> candidate, {String? to}) {
    if (_socket != null) {
      _socket?.emit('ice-candidate', {'candidate': candidate, 'to': to});
    }
  }

  // Media control events
  void toggleAudio(bool enabled) {
    if (_socket != null) {
      _socket?.emit('toggle-audio', {'enabled': enabled});
    }
  }

  void toggleVideo(bool enabled) {
    if (_socket != null) {
      _socket?.emit('toggle-video', {'enabled': enabled});
    }
  }

  // Screen sharing events
  void startScreenShare() {
    if (_socket != null) {
      _socket?.emit('start-screen-share', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void stopScreenShare() {
    if (_socket != null) {
      _socket?.emit('stop-screen-share', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void sendScreenShareOffer(Map<String, dynamic> offer) {
    if (_socket != null) {
      _socket?.emit('screen-share-offer', {'offer': offer});
    }
  }

  void sendScreenShareAnswer(Map<String, dynamic> answer) {
    if (_socket != null) {
      _socket?.emit('screen-share-answer', {'answer': answer});
    }
  }

  void sendScreenShareIceCandidate(Map<String, dynamic> candidate) {
    if (_socket != null) {
      _socket?.emit('screen-share-ice-candidate', {'candidate': candidate});
    }
  }

  // Event listeners for WebRTC signaling
  void onOffer(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('offer', callback);
    }
  }

  void onAnswer(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('answer', callback);
    }
  }

  void onIceCandidate(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('ice-candidate', callback);
    }
  }

  void onParticipantAudioToggle(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('participant-audio-toggle', callback);
    }
  }

  void onParticipantVideoToggle(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('participant-video-toggle', callback);
    }
  }

  void onScreenShareStarted(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('screen-share-started', callback);
    }
  }

  void onScreenShareStopped(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('screen-share-stopped', callback);
    }
  }

  void onScreenShareOffer(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('screen-share-offer', callback);
    }
  }

  void onScreenShareAnswer(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('screen-share-answer', callback);
    }
  }

  void onScreenShareIceCandidate(Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on('screen-share-ice-candidate', callback);
    }
  }
}

// Export a singleton instance
final socketService = SocketService();