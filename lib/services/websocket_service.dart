import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // Event controllers for different Socket.IO event types
  final _connectionController = StreamController<bool>.broadcast();
  final _courseEventsController = StreamController<Map<String, dynamic>>.broadcast();
  final _meetingEventsController = StreamController<Map<String, dynamic>>.broadcast();
  final _participantEventsController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatEventsController = StreamController<Map<String, dynamic>>.broadcast();
  final _mediaEventsController = StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get courseEventsStream => _courseEventsController.stream;
  Stream<Map<String, dynamic>> get meetingEventsStream => _meetingEventsController.stream;
  Stream<Map<String, dynamic>> get participantEventsStream => _participantEventsController.stream;
  Stream<Map<String, dynamic>> get chatEventsStream => _chatEventsController.stream;
  Stream<Map<String, dynamic>> get mediaEventsStream => _mediaEventsController.stream;

  bool get isConnected => _isConnected;

  // Initialize Socket.IO connection
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      return; // Already connected
    }

    try {
      _socket = IO.io(
        ApiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setTimeout(ApiConfig.socketTimeout.inMilliseconds)
            .enableReconnection()
            .setReconnectionAttempts(ApiConfig.maxRetries)
            .setReconnectionDelay(ApiConfig.retryDelay.inMilliseconds)
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      print('WebSocket connection error: $e');
      _connectionController.add(false);
    }
  }

  // Setup all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('Socket.IO connected');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('Socket.IO disconnected');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      print('Socket.IO connection error: $error');
      _isConnected = false;
      _connectionController.add(false);
    });

    // Course events
    _socket!.on(ApiConfig.courseStarted, (data) {
      _courseEventsController.add({
        'event': ApiConfig.courseStarted,
        'data': data,
      });
    });

    _socket!.on(ApiConfig.courseEnded, (data) {
      _courseEventsController.add({
        'event': ApiConfig.courseEnded,
        'data': data,
      });
    });

    _socket!.on(ApiConfig.participantJoined, (data) {
      _participantEventsController.add({
        'event': ApiConfig.participantJoined,
        'data': data,
      });
    });

    _socket!.on(ApiConfig.participantLeft, (data) {
      _participantEventsController.add({
        'event': ApiConfig.participantLeft,
        'data': data,
      });
    });

    // Meeting events
    _socket!.on(ApiConfig.meetingStarted, (data) {
      _meetingEventsController.add({
        'event': ApiConfig.meetingStarted,
        'data': data,
      });
    });

    _socket!.on(ApiConfig.meetingEnded, (data) {
      _meetingEventsController.add({
        'event': ApiConfig.meetingEnded,
        'data': data,
      });
    });

    _socket!.on(ApiConfig.receiveMessage, (data) {
      _chatEventsController.add({
        'event': ApiConfig.receiveMessage,
        'data': data,
      });
    });

    // MediaSoup events
    _socket!.on(ApiConfig.newProducer, (data) {
      _mediaEventsController.add({
        'event': ApiConfig.newProducer,
        'data': data,
      });
    });

    _socket!.on(ApiConfig.producerClosed, (data) {
      _mediaEventsController.add({
        'event': ApiConfig.producerClosed,
        'data': data,
      });
    });

    // Media control events
    _socket!.on('participant-audio-toggle', (data) {
      _participantEventsController.add({
        'event': 'participant-audio-toggle',
        'data': data,
      });
    });

    _socket!.on('participant-video-toggle', (data) {
      _participantEventsController.add({
        'event': 'participant-video-toggle',
        'data': data,
      });
    });

    _socket!.on('screen-share-started', (data) {
      _mediaEventsController.add({
        'event': 'screen-share-started',
        'data': data,
      });
    });

    _socket!.on('screen-share-stopped', (data) {
      _mediaEventsController.add({
        'event': 'screen-share-stopped',
        'data': data,
      });
    });

    // WebRTC signaling events
    _socket!.on('offer', (data) {
      _mediaEventsController.add({
        'event': 'offer',
        'data': data,
      });
    });

    _socket!.on('answer', (data) {
      _mediaEventsController.add({
        'event': 'answer',
        'data': data,
      });
    });

    _socket!.on('ice-candidate', (data) {
      _mediaEventsController.add({
        'event': 'ice-candidate',
        'data': data,
      });
    });
  }

  // Join a course room
  void joinCourse(String courseId, String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.joinCourse, {
        'courseId': courseId,
        'userId': userId,
      });
    }
  }

  // Leave a course room
  void leaveCourse(String courseId, String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.leaveCourse, {
        'courseId': courseId,
        'userId': userId,
      });
    }
  }

  // Join a meeting room
  void joinMeeting(String meetingCode, String participantId, String participantName) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.joinMeeting, {
        'meetingCode': meetingCode,
        'participantId': participantId,
        'participantName': participantName,
      });
    }
  }

  // Leave a meeting room
  void leaveMeeting(String meetingCode, String participantId) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.leaveMeeting, {
        'meetingCode': meetingCode,
        'participantId': participantId,
      });
    }
  }

  // Send a chat message
  void sendMessage(String meetingCode, String senderId, String senderName, String message) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.sendMessage, {
        'meetingCode': meetingCode,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Join WebRTC room for video calling
  void joinRoom(String roomId, String peerId) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.joinRoom, {
        'roomId': roomId,
        'peerId': peerId,
      });
    }
  }

  // Leave WebRTC room
  void leaveRoom(String roomId, String peerId) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.leaveRoom, {
        'roomId': roomId,
        'peerId': peerId,
      });
    }
  }

  // MediaSoup signaling methods
  void createTransport(String roomId, String peerId, bool producing) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.createTransport, {
        'roomId': roomId,
        'peerId': peerId,
        'producing': producing,
      });
    }
  }

  void connectTransport(String roomId, String peerId, String transportId, Map<String, dynamic> dtlsParameters) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.connectTransport, {
        'roomId': roomId,
        'peerId': peerId,
        'transportId': transportId,
        'dtlsParameters': dtlsParameters,
      });
    }
  }

  void produce(String roomId, String peerId, String transportId, String kind, Map<String, dynamic> rtpParameters) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.produce, {
        'roomId': roomId,
        'peerId': peerId,
        'transportId': transportId,
        'kind': kind,
        'rtpParameters': rtpParameters,
      });
    }
  }

  void consume(String roomId, String peerId, String producerId, Map<String, dynamic> rtpCapabilities) {
    if (_socket != null && _isConnected) {
      _socket!.emit(ApiConfig.consume, {
        'roomId': roomId,
        'peerId': peerId,
        'producerId': producerId,
        'rtpCapabilities': rtpCapabilities,
      });
    }
  }

  // Media control methods
  void emitMediaToggle(String meetingCode, String participantId, String mediaType, bool enabled) {
    if (_socket != null && _isConnected) {
      final eventName = mediaType == 'video' ? 'toggle-video' : 'toggle-audio';
      _socket!.emit(eventName, {
        'meetingCode': meetingCode,
        'participantId': participantId,
        'enabled': enabled,
      });
    }
  }

  void startScreenShare(String meetingCode, String participantId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('start-screen-share', {
        'meetingCode': meetingCode,
        'participantId': participantId,
      });
    }
  }

  void stopScreenShare(String meetingCode, String participantId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('stop-screen-share', {
        'meetingCode': meetingCode,
        'participantId': participantId,
      });
    }
  }

  // WebRTC signaling methods
  void sendOffer(String meetingCode, String fromId, String toId, Map<String, dynamic> offer) {
    if (_socket != null && _isConnected) {
      _socket!.emit('offer', {
        'meetingCode': meetingCode,
        'from': fromId,
        'to': toId,
        'offer': offer,
      });
    }
  }

  void sendAnswer(String meetingCode, String fromId, String toId, Map<String, dynamic> answer) {
    if (_socket != null && _isConnected) {
      _socket!.emit('answer', {
        'meetingCode': meetingCode,
        'from': fromId,
        'to': toId,
        'answer': answer,
      });
    }
  }

  void sendIceCandidate(String meetingCode, String fromId, String toId, Map<String, dynamic> candidate) {
    if (_socket != null && _isConnected) {
      _socket!.emit('ice-candidate', {
        'meetingCode': meetingCode,
        'from': fromId,
        'to': toId,
        'candidate': candidate,
      });
    }
  }

  // Disconnect and cleanup
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _connectionController.close();
    _courseEventsController.close();
    _meetingEventsController.close();
    _participantEventsController.close();
    _chatEventsController.close();
    _mediaEventsController.close();
  }
}