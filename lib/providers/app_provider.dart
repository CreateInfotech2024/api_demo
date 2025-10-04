import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/course.dart';
import '../models/meeting.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../services/webrtc_service.dart';
import '../utils/permission_helper.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();
  final WebRTCService _webrtcService = WebRTCService();

  // Connection state
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Courses
  List<Course> _courses = [];
  Course? _currentCourse;

  // Meetings
  Meeting? _currentMeeting;
  String? _currentParticipantId;

  // Chat messages
  List<ChatMessage> _chatMessages = [];

  // Media control states
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isScreenSharing = false;

  // Stream subscriptions
  StreamSubscription? _connectionSub;
  StreamSubscription? _meetingEventsSub;
  StreamSubscription? _participantEventsSub;
  StreamSubscription? _chatEventsSub;
  StreamSubscription? _mediaEventsSub;

  // Getters
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Course> get courses => _courses;
  Course? get currentCourse => _currentCourse;
  Meeting? get currentMeeting => _currentMeeting;
  String? get currentParticipantId => _currentParticipantId;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isScreenSharing => _isScreenSharing;
  MediaStream? get localStream => _webrtcService.localStream;
  Map<String, MediaStream> get remoteStreams => _webrtcService.remoteStreams;

  AppProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _setLoading(true);
    
    try {
      // Initialize WebSocket connection
      await _wsService.connect();
      
      // Setup WebSocket event listeners
      _connectionSub = _wsService.connectionStream.listen(_handleConnectionChange);
      _meetingEventsSub = _wsService.meetingEventsStream.listen(_handleMeetingEvent);
      _participantEventsSub = _wsService.participantEventsStream.listen(_handleParticipantEvent);
      _chatEventsSub = _wsService.chatEventsStream.listen(_handleChatEvent);
      _mediaEventsSub = _wsService.mediaEventsStream.listen(_handleMediaEvent);

      // Perform health check
      await healthCheck();
      
      // Load initial data
      await loadCourses();
    } catch (e) {
      _setError('Failed to initialize services: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> healthCheck() async {
    try {
      final response = await _apiService.healthCheck();
      if (!response.success) {
        _setError(response.error ?? 'Health check failed');
      }
    } catch (e) {
      _setError('Health check failed: $e');
    }
  }

  Future<void> loadCourses() async {
    _setLoading(true);
    try {
      final response = await _apiService.getLiveCourses();
      if (response.success && response.data != null) {
        _courses = response.data!;
        _clearError();
      } else {
        _setError(response.error ?? 'Failed to load courses');
      }
    } catch (e) {
      _setError('Failed to load courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createMeeting({
    required String hostName,
    required String title,
    required String description,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.createMeeting(
        hostName: hostName,
        title: title,
        description: description,
      );

      if (response.success && response.data != null) {
        _currentMeeting = response.data!;
        _currentParticipantId = response.data!.hostId;
        _chatMessages = List.from(response.data!.messages);
        
        // Initialize WebRTC media
        await _initializeWebRTC();
        
        // Join the WebSocket room
        _wsService.joinMeeting(
          response.data!.code,
          response.data!.hostId,
          response.data!.hostName,
        );
        
        _clearError();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create meeting');
        return false;
      }
    } catch (e) {
      _setError('Failed to create meeting: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinMeeting({
    required String meetingCode,
    required String participantName,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.joinMeeting(
        meetingCode: meetingCode,
        participantName: participantName,
      );

      if (response.success && response.data != null) {
        _currentMeeting = response.data!;
        
        // Find the current participant
        final participant = response.data!.participants.lastWhere(
          (p) => p.name == participantName,
          orElse: () => response.data!.participants.first,
        );
        _currentParticipantId = participant.id;
        _chatMessages = List.from(response.data!.messages);
        
        // Initialize WebRTC media
        await _initializeWebRTC();
        
        // Join the WebSocket room
        _wsService.joinMeeting(
          meetingCode,
          participant.id,
          participantName,
        );
        
        _clearError();
        return true;
      } else {
        _setError(response.error ?? 'Failed to join meeting');
        return false;
      }
    } catch (e) {
      _setError('Failed to join meeting: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> leaveMeeting() async {
    if (_currentMeeting == null || _currentParticipantId == null) return;

    try {
      // Leave WebSocket room
      _wsService.leaveMeeting(_currentMeeting!.code, _currentParticipantId!);
      
      // Call API to leave meeting
      await _apiService.leaveMeeting(
        meetingCode: _currentMeeting!.code,
        participantId: _currentParticipantId!,
      );
      
      // Cleanup WebRTC resources
      await _webrtcService.dispose();
      
      // Clear current meeting data and reset media states
      _currentMeeting = null;
      _currentParticipantId = null;
      _chatMessages = [];
      _isVideoEnabled = true;
      _isAudioEnabled = true;
      _isScreenSharing = false;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to leave meeting: $e');
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (_currentMeeting == null || _currentParticipantId == null) return;

    final participant = _currentMeeting!.participants.firstWhere(
      (p) => p.id == _currentParticipantId,
      orElse: () => Participant(
        id: _currentParticipantId!,
        name: 'Unknown',
        joinedAt: DateTime.now(),
      ),
    );

    try {
      // Send via WebSocket for real-time delivery
      _wsService.sendMessage(
        _currentMeeting!.code,
        _currentParticipantId!,
        participant.name,
        message,
      );

      // Also send via API for persistence
      await _apiService.sendChatMessage(
        meetingCode: _currentMeeting!.code,
        senderId: _currentParticipantId!,
        senderName: participant.name,
        message: message,
      );
    } catch (e) {
      _setError('Failed to send message: $e');
    }
  }

  // Initialize WebRTC for the current meeting
  Future<void> _initializeWebRTC() async {
    try {
      // Request permissions
      final hasPermissions = await PermissionHelper.requestCameraAndMicrophonePermissions();
      if (!hasPermissions) {
        _setError('Camera and microphone permissions are required');
        return;
      }

      // Initialize local media stream
      final stream = await _webrtcService.initializeLocalMedia();
      if (stream == null) {
        _setError('Failed to access camera/microphone');
        return;
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize WebRTC: $e');
    }
  }

  // Toggle video
  void toggleVideo() {
    _isVideoEnabled = !_isVideoEnabled;
    
    // Toggle video track
    _webrtcService.toggleVideo(_isVideoEnabled);
    
    // Emit WebSocket event for video toggle
    if (_currentMeeting != null && _currentParticipantId != null) {
      _wsService.emitMediaToggle(
        _currentMeeting!.code,
        _currentParticipantId!,
        'video',
        _isVideoEnabled,
      );
    }
    
    notifyListeners();
  }

  // Toggle audio
  void toggleAudio() {
    _isAudioEnabled = !_isAudioEnabled;
    
    // Toggle audio track
    _webrtcService.toggleAudio(_isAudioEnabled);
    
    // Emit WebSocket event for audio toggle
    if (_currentMeeting != null && _currentParticipantId != null) {
      _wsService.emitMediaToggle(
        _currentMeeting!.code,
        _currentParticipantId!,
        'audio',
        _isAudioEnabled,
      );
    }
    
    notifyListeners();
  }

  // Toggle screen sharing
  void toggleScreenSharing() {
    _isScreenSharing = !_isScreenSharing;
    
    // Emit WebSocket event for screen sharing
    if (_currentMeeting != null && _currentParticipantId != null) {
      if (_isScreenSharing) {
        _wsService.startScreenShare(_currentMeeting!.code, _currentParticipantId!);
      } else {
        _wsService.stopScreenShare(_currentMeeting!.code, _currentParticipantId!);
      }
    }
    
    notifyListeners();
  }

  void _handleConnectionChange(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void _handleMeetingEvent(Map<String, dynamic> event) {
    final eventType = event['event'];
    final data = event['data'];

    switch (eventType) {
      case 'meetingStarted':
        // Handle meeting started
        break;
      case 'meetingEnded':
        // Handle meeting ended
        _currentMeeting = null;
        _currentParticipantId = null;
        _chatMessages = [];
        notifyListeners();
        break;
    }
  }

  void _handleParticipantEvent(Map<String, dynamic> event) {
    if (_currentMeeting == null) return;

    final eventType = event['event'];
    final data = event['data'];

    switch (eventType) {
      case 'participant-joined':
        // Add system message about participant joining
        final participantName = data['participantName'] ?? 'Someone';
        _chatMessages.add(ChatMessage.system('$participantName joined the meeting'));
        notifyListeners();
        break;
      case 'participant-left':
        // Add system message about participant leaving
        final participantName = data['participantName'] ?? 'Someone';
        _chatMessages.add(ChatMessage.system('$participantName left the meeting'));
        notifyListeners();
        break;
      case 'participant-audio-toggle':
        // Update participant audio state
        final participantId = data['participantId'];
        final enabled = data['enabled'] ?? false;
        _updateParticipantMediaState(participantId, audio: enabled);
        break;
      case 'participant-video-toggle':
        // Update participant video state
        final participantId = data['participantId'];
        final enabled = data['enabled'] ?? false;
        _updateParticipantMediaState(participantId, video: enabled);
        break;
    }
  }

  void _updateParticipantMediaState(String participantId, {bool? audio, bool? video}) {
    if (_currentMeeting == null) return;

    final participantIndex = _currentMeeting!.participants.indexWhere((p) => p.id == participantId);
    if (participantIndex != -1) {
      final participant = _currentMeeting!.participants[participantIndex];
      final updatedParticipants = List<Participant>.from(_currentMeeting!.participants);
      updatedParticipants[participantIndex] = Participant(
        id: participant.id,
        name: participant.name,
        isHost: participant.isHost,
        hasVideo: video ?? participant.hasVideo,
        hasAudio: audio ?? participant.hasAudio,
        joinedAt: participant.joinedAt,
      );
      
      _currentMeeting = _currentMeeting!.copyWith(participants: updatedParticipants);
      notifyListeners();
    }
  }

  void _handleChatEvent(Map<String, dynamic> event) {
    final eventType = event['event'];
    final data = event['data'];

    if (eventType == 'receiveMessage') {
      final message = ChatMessage(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? 'Unknown',
        message: data['message'] ?? '',
        timestamp: DateTime.tryParse(data['timestamp']) ?? DateTime.now(),
      );

      _chatMessages.add(message);
      notifyListeners();
    }
  }

  void _handleMediaEvent(Map<String, dynamic> event) {
    final eventType = event['event'];
    final data = event['data'];

    switch (eventType) {
      case 'screen-share-started':
        final participantName = data['participantName'] ?? 'Someone';
        _chatMessages.add(ChatMessage.system('$participantName started screen sharing'));
        notifyListeners();
        break;
      case 'screen-share-stopped':
        final participantName = data['participantName'] ?? 'Someone';
        _chatMessages.add(ChatMessage.system('$participantName stopped screen sharing'));
        notifyListeners();
        break;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _meetingEventsSub?.cancel();
    _participantEventsSub?.cancel();
    _chatEventsSub?.cancel();
    _mediaEventsSub?.cancel();
    _wsService.dispose();
    _apiService.dispose();
    _webrtcService.dispose();
    super.dispose();
  }
}