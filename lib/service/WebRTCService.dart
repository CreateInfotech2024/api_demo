import 'dart:developer' as developer;
import 'package:api_demo/service/socketService.dart';
import 'package:api_demo/config/mobile_optimizations.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaStates {
  final bool audio;
  final bool video;
  final bool screenSharing;

  MediaStates({
    required this.audio,
    required this.video,
    required this.screenSharing,
  });
}

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal() {
    _setupSocketListeners();
  }

  final Map<String, RTCPeerConnection> _peerConnections = {};
  MediaStream? _localStream;
  MediaStream? _screenStream;
  final Map<String, Function(MediaStream)> _mediaStreamCallbacks = {};
  final Map<String, MediaStream> _remoteStreams = {};
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;

  // Getters
  MediaStream? get localStream => _localStream;
  Map<String, MediaStream> get remoteStreams => Map.from(_remoteStreams);
  MediaStates get mediaStates => MediaStates(
    audio: _isAudioEnabled,
    video: _isVideoEnabled,
    screenSharing: _isScreenSharing,
  );
  // Set callback for remote streams
  void onRemoteStream(Function(MediaStream) callback) {
    _mediaStreamCallbacks['remoteStream'] = callback;
    developer.log('✅ Remote stream callback registered');
  }
  
  // Get connection state for a participant
  RTCPeerConnectionState? getConnectionState(String participantId) {
    return _peerConnections[participantId]?.connectionState;
  }
  
  // Check if participant has active remote stream
  bool hasRemoteStream(String participantId) {
    final stream = _remoteStreams[participantId];
    if (stream == null) return false;
    
    // Check if stream has active tracks
    final videoTracks = stream.getVideoTracks();
    final audioTracks = stream.getAudioTracks();
    
    return videoTracks.any((track) => track.enabled) || audioTracks.any((track) => track.enabled);
  }

  void _setupSocketListeners() {
    final socket = SocketService();
    socket.onOffer(_handleOffer);
    socket.onAnswer(_handleAnswer);
    socket.onIceCandidate(_handleIceCandidate);
    socket.onScreenShareOffer(_handleScreenShareOffer);
    socket.onScreenShareAnswer(_handleScreenShareAnswer);
    socket.onScreenShareIceCandidate(_handleScreenShareIceCandidate);
  }

  // Initialize local media (camera and microphone) with mobile optimizations
  Future<MediaStream?> initializeLocalMedia() async {
    try {
      // Use mobile-optimized media constraints
      final mediaConstraints = MobileOptimizations.getMobileOptimizedMediaConstraints();
      
      developer.log('🎥 Initializing media with ${MobileOptimizations.isMobile ? "mobile" : "desktop"} constraints');

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      developer.log('✅ Local media initialized successfully');
      return _localStream;
    } catch (error) {
      developer.log('❌ Failed to initialize local media: $error');
      
      // Fallback with basic constraints for better mobile compatibility
      try {
        final Map<String, dynamic> fallbackConstraints = {
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': {'ideal': MobileOptimizations.isMobile ? 480 : 640},
            'height': {'ideal': MobileOptimizations.isMobile ? 360 : 480},
          }
        };
        
        _localStream = await navigator.mediaDevices.getUserMedia(fallbackConstraints);
        developer.log('✅ Local media initialized with fallback constraints');
        return _localStream;
      } catch (fallbackError) {
        developer.log('❌ Fallback media initialization also failed: $fallbackError');
        
        // Provide mobile-specific error message
        final mobileError = MobileOptimizations.getMobileErrorMessage(fallbackError.toString());
        throw Exception(mobileError);
      }
    }
  }

  // Create peer connection for a participant
  Future<RTCPeerConnection> _createPeerConnection(String participantId) async {
    // Use mobile-optimized WebRTC configuration
    final configuration = MobileOptimizations.getWebRTCConfiguration();
    
    developer.log('🔗 Creating peer connection for $participantId with ${MobileOptimizations.isMobile ? "mobile" : "desktop"} config');

    final RTCPeerConnection peerConnection = await createPeerConnection(configuration);

    // Handle incoming stream with better error handling
    peerConnection.onTrack = (RTCTrackEvent event) {
      developer.log('📺 Received remote stream from $participantId');
      try {
        if (event.streams.isNotEmpty) {
          final stream = event.streams[0];
          _remoteStreams[participantId] = stream;
          developer.log('✅ Added remote stream for $participantId with ${stream.getTracks().length} tracks');
          
          // Verify stream has both audio and video tracks
          final audioTracks = stream.getAudioTracks();
          final videoTracks = stream.getVideoTracks();
          developer.log('  - Audio tracks: ${audioTracks.length}');
          developer.log('  - Video tracks: ${videoTracks.length}');
          
          // Notify all callbacks about the new remote stream
          final callback = _mediaStreamCallbacks['remoteStream'];
          if (callback != null) {
            callback(stream);
          }
        } else {
          developer.log('⚠️ Received track event with no streams from $participantId');
        }
      } catch (error) {
        developer.log('❌ Error handling remote stream from $participantId: $error');
      }
    };

    // Handle connection state changes for debugging
    peerConnection.onConnectionState = (RTCPeerConnectionState state) {
      developer.log('🔗 Connection state for $participantId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        developer.log('✅ Successfully connected to $participantId');
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        developer.log('❌ Connection failed to $participantId');
      }
    };

    // Handle ICE candidates
    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      SocketService().sendIceCandidate(candidate.toMap(), to: participantId);
    };

    // Add local stream to peer connection
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        peerConnection.addTrack(track, _localStream!);
      });
    }

    _peerConnections[participantId] = peerConnection;
    return peerConnection;
  }

  // Handle incoming offer
  Future<void> _handleOffer(dynamic data) async {
    try {
      final String from = data['from'] ?? '';
      final Map<String, dynamic> offerMap = Map<String, dynamic>.from(data['offer']);

      final RTCPeerConnection peerConnection = await _createPeerConnection(from);

      await peerConnection.setRemoteDescription(
        RTCSessionDescription(offerMap['sdp'], offerMap['type']),
      );

      final RTCSessionDescription answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);

      SocketService().sendAnswer(answer.toMap(), to: from);
    } catch (error) {
      developer.log('❌ Error handling offer: $error');
    }
  }

  // Handle incoming answer
  Future<void> _handleAnswer(dynamic data) async {
    try {
      final String from = data['from'] ?? '';
      final Map<String, dynamic> answerMap = Map<String, dynamic>.from(data['answer']);
      final RTCPeerConnection? peerConnection = _peerConnections[from];

      if (peerConnection != null) {
        await peerConnection.setRemoteDescription(
          RTCSessionDescription(answerMap['sdp'], answerMap['type']),
        );
      }
    } catch (error) {
      developer.log('❌ Error handling answer: $error');
    }
  }

  // Handle incoming ICE candidate
  Future<void> _handleIceCandidate(dynamic data) async {
    try {
      final String from = data['from'] ?? '';
      final Map<String, dynamic> candidateMap = Map<String, dynamic>.from(data['candidate']);
      final RTCPeerConnection? peerConnection = _peerConnections[from];

      if (peerConnection != null) {
        await peerConnection.addCandidate(RTCIceCandidate(
          candidateMap['candidate'],
          candidateMap['sdpMid'],
          candidateMap['sdpMLineIndex'],
        ));
      }
    } catch (error) {
      developer.log('❌ Error handling ICE candidate: $error');
    }
  }

  // Create offer for a new participant
  Future<void> createOffer(String participantId) async {
    try {
      final RTCPeerConnection peerConnection = await _createPeerConnection(participantId);
      final RTCSessionDescription offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      SocketService().sendOffer(offer.toMap(), to: participantId);
    } catch (error) {
      developer.log('❌ Error creating offer: $error');
    }
  }

  // Toggle audio
  bool toggleAudio() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = !track.enabled;
      }
      _isAudioEnabled = !_isAudioEnabled;
      SocketService().toggleAudio(_isAudioEnabled);
      return _isAudioEnabled;
    }
    return false;
  }

  // Toggle video
  bool toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      for (var track in videoTracks) {
        track.enabled = !track.enabled;
      }
      _isVideoEnabled = !_isVideoEnabled;
      SocketService().toggleVideo(_isVideoEnabled);
      return _isVideoEnabled;
    }
    return false;
  }

  // Start screen sharing (enhanced for mobile and web compatibility)
  Future<MediaStream?> startScreenShare() async {
    try {
      developer.log('🖥️ Starting screen sharing...');
      
      // Use mobile-optimized screen sharing constraints
      final constraintOptions = MobileOptimizations.getScreenSharingConstraints();

      MediaStream? screenStream;
      String? usedConstraints;
      
      // Try each constraint option until one works
      for (int i = 0; i < constraintOptions.length; i++) {
        try {
          developer.log('🔄 Trying screen share constraint option ${i + 1}...');
          screenStream = await navigator.mediaDevices.getDisplayMedia(constraintOptions[i]);
          usedConstraints = 'Option ${i + 1} (${MobileOptimizations.isMobile ? "mobile" : "desktop"})';
          developer.log('✅ Screen sharing started with $usedConstraints');
          break;
        } catch (e) {
          developer.log('⚠️ Screen share constraint option ${i + 1} failed: $e');
          if (i == constraintOptions.length - 1) {
            throw e; // Re-throw if all options failed
          }
        }
      }

      if (screenStream == null) {
        throw Exception('Failed to get screen stream with all constraint options');
      }

      _screenStream = screenStream;
      _isScreenSharing = true;
      
      // Notify other participants about screen sharing
      SocketService().startScreenShare();

      // Replace video track in all peer connections for SFU
      final videoTrack = _screenStream!.getVideoTracks().first;
      int replacedConnections = 0;
      
      for (var entry in _peerConnections.entries) {
        final participantId = entry.key;
        final peerConnection = entry.value;
        
        try {
          final senders = await peerConnection.getSenders();
          final videoSender = senders.firstWhere(
            (sender) => sender.track?.kind == 'video',
            orElse: () => throw StateError('No video sender found'),
          );
          await videoSender.replaceTrack(videoTrack);
          replacedConnections++;
          developer.log('✅ Replaced video track for participant: $participantId');
        } catch (e) {
          developer.log('⚠️ Failed to replace track for $participantId: $e');
        }
      }

      developer.log('📡 Screen sharing track replaced in $replacedConnections peer connections');

      // Listen for screen share end (when user stops sharing from browser)
      videoTrack.onEnded = () {
        developer.log('🛑 Screen sharing ended by user');
        stopScreenShare();
      };

      return _screenStream;
    } catch (error) {
      developer.log('❌ Failed to start screen sharing: $error');
      _isScreenSharing = false;
      
      // Use mobile-specific error message
      final mobileError = MobileOptimizations.getMobileErrorMessage(error.toString());
      throw Exception(mobileError);
    }
  }

  // Helper method to detect mobile devices (enhanced)
  bool _isMobileDevice() {
    return MobileOptimizations.isMobile;
  }

  // Stop screen sharing (enhanced cleanup)
  Future<void> stopScreenShare() async {
    try {
      developer.log('🛑 Stopping screen sharing...');
      
      if (_screenStream != null) {
        // Stop all tracks in the screen stream
        _screenStream!.getTracks().forEach((track) {
          track.stop();
          developer.log('🔇 Stopped track: ${track.kind}');
        });
        
        // Dispose the stream
        await _screenStream!.dispose();
        _screenStream = null;
      }
      
      _isScreenSharing = false;
      
      // Notify other participants
      SocketService().stopScreenShare();

      // Replace back to camera stream in all peer connections
      if (_localStream != null) {
        final videoTracks = _localStream!.getVideoTracks();
        if (videoTracks.isNotEmpty) {
          final cameraVideoTrack = videoTracks.first;
          int replacedConnections = 0;
          
          for (var entry in _peerConnections.entries) {
            final participantId = entry.key;
            final peerConnection = entry.value;
            
            try {
              final senders = await peerConnection.getSenders();
              final videoSender = senders.firstWhere(
                (sender) => sender.track?.kind == 'video',
                orElse: () => throw StateError('No video sender found'),
              );
              await videoSender.replaceTrack(cameraVideoTrack);
              replacedConnections++;
              developer.log('✅ Restored camera track for participant: $participantId');
            } catch (e) {
              developer.log('⚠️ Failed to restore camera track for $participantId: $e');
            }
          }
          
          developer.log('📹 Camera track restored in $replacedConnections peer connections');
        } else {
          developer.log('⚠️ No camera video track available to restore');
        }
      } else {
        developer.log('⚠️ No local stream available to restore camera');
      }
      
      developer.log('✅ Screen sharing stopped successfully');
    } catch (error) {
      developer.log('❌ Error stopping screen sharing: $error');
      // Ensure state is reset even if there's an error
      _isScreenSharing = false;
      if (_screenStream != null) {
        _screenStream!.getTracks().forEach((track) => track.stop());
        _screenStream = null;
      }
    }
  }

  // Screen sharing signaling handlers
  Future<void> _handleScreenShareOffer(dynamic data) async {
    // Handle screen share offers from other participants
    developer.log('📺 Received screen share offer: $data');
  }

  Future<void> _handleScreenShareAnswer(dynamic data) async {
    // Handle screen share answers
    developer.log('📺 Received screen share answer: $data');
  }

  Future<void> _handleScreenShareIceCandidate(dynamic data) async {
    // Handle screen share ICE candidates
    developer.log('📺 Received screen share ICE candidate: $data');
  }



  // Create offer for a specific participant
  Future<void> createOffer(String participantId) async {
    try {
      final RTCPeerConnection peerConnection = await _createPeerConnection(participantId);

      final RTCSessionDescription offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      SocketService().sendOffer(offer.toMap(), to: participantId);
      developer.log('📤 Sent offer to $participantId');
    } catch (error) {
      developer.log('❌ Error creating offer for $participantId: $error');
    }
  }

  // Get remote stream for a specific participant
  MediaStream? getRemoteStream(String participantId) {
    return _remoteStreams[participantId];
  }

  // Debug method to check connection status
  // Enhanced connection monitoring for debugging and reliability
  void logConnectionStatus() {
    developer.log('📊 === WebRTC Connection Status ===');
    developer.log('  Local stream: ${_localStream != null ? "Active" : "None"}');
    developer.log('  Screen stream: ${_screenStream != null ? "Active" : "None"}');
    developer.log('  Audio enabled: $_isAudioEnabled');
    developer.log('  Video enabled: $_isVideoEnabled');
    developer.log('  Screen sharing: $_isScreenSharing');
    developer.log('  Peer connections: ${_peerConnections.length}');
    developer.log('  Remote streams: ${_remoteStreams.length}');
    
    for (var entry in _peerConnections.entries) {
      final participantId = entry.key;
      final connection = entry.value;
      final state = connection.connectionState;
      final iceState = connection.iceConnectionState;
      developer.log('  - $participantId: Connection=$state, ICE=$iceState');
    }
    developer.log('=======================================');
  }

  // Get detailed connection statistics for troubleshooting
  Future<Map<String, dynamic>> getConnectionStats() async {
    final stats = <String, dynamic>{
      'localStream': _localStream != null,
      'screenStream': _screenStream != null,
      'isAudioEnabled': _isAudioEnabled,
      'isVideoEnabled': _isVideoEnabled,
      'isScreenSharing': _isScreenSharing,
      'peerConnections': <String, dynamic>{},
      'remoteStreams': _remoteStreams.keys.toList(),
    };

    for (var entry in _peerConnections.entries) {
      final participantId = entry.key;
      final connection = entry.value;
      
      stats['peerConnections'][participantId] = {
        'connectionState': connection.connectionState.toString(),
        'iceConnectionState': connection.iceConnectionState.toString(),
        'signalingState': connection.signalingState.toString(),
      };
    }

    return stats;
  }

  // Enhanced cleanup with better error handling
  Future<void> cleanup() async {
    developer.log('🧹 Cleaning up WebRTC resources...');
    
    try {
      // Stop and dispose local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        await _localStream!.dispose();
        _localStream = null;
        developer.log('✅ Local stream disposed');
      }

      // Stop screen stream
      if (_screenStream != null) {
        _screenStream!.getTracks().forEach((track) => track.stop());
        await _screenStream!.dispose();
        _screenStream = null;
        developer.log('✅ Screen stream disposed');
      }

      // Close all peer connections
      for (var entry in _peerConnections.entries) {
        final participantId = entry.key;
        try {
          await entry.value.close();
          developer.log('✅ Peer connection closed for: $participantId');
        } catch (e) {
          developer.log('⚠️ Error closing peer connection for $participantId: $e');
        }
      }
      _peerConnections.clear();

      // Clear remote streams
      _remoteStreams.clear();
      
      // Clear callbacks
      _mediaStreamCallbacks.clear();

      // Reset state
      _isAudioEnabled = true;
      _isVideoEnabled = true;
      _isScreenSharing = false;
      
      developer.log('🧹 WebRTC cleanup completed successfully');
    } catch (error) {
      developer.log('❌ Error during WebRTC cleanup: $error');
    }
  }

  // Reconnect functionality for handling connection failures
  Future<void> reconnectToParticipant(String participantId) async {
    developer.log('🔄 Reconnecting to participant: $participantId');
    
    try {
      // Close existing connection if it exists
      final existingConnection = _peerConnections[participantId];
      if (existingConnection != null) {
        await existingConnection.close();
        _peerConnections.remove(participantId);
      }
      
      // Remove old remote stream
      _remoteStreams.remove(participantId);
      
      // Create new connection and offer
      await Future.delayed(Duration(seconds: 1)); // Brief delay before reconnecting
      await createOffer(participantId);
      
      developer.log('✅ Reconnection initiated for: $participantId');
    } catch (error) {
      developer.log('❌ Failed to reconnect to $participantId: $error');
    }
  }

  // Remove participant
  Future<void> removeParticipant(String participantId) async {
    final RTCPeerConnection? peerConnection = _peerConnections[participantId];
    if (peerConnection != null) {
      await peerConnection.close();
      _peerConnections.remove(participantId);
    }
    _remoteStreams.remove(participantId);
  }
}

// Export singleton instance
final webrtcService = WebRTCService();