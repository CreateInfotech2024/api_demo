import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  // Local media stream (user's camera and microphone)
  MediaStream? _localStream;
  
  // Map of peer connections by participant ID
  final Map<String, RTCPeerConnection> _peerConnections = {};
  
  // Map of remote streams by participant ID
  final Map<String, MediaStream> _remoteStreams = {};
  
  // ICE servers configuration
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  // Media constraints for mobile-friendly capture
  final Map<String, dynamic> _mediaConstraints = {
    'audio': {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
    },
    'video': {
      'mandatory': {
        'minWidth': '320',
        'minHeight': '240',
        'maxWidth': '1280',
        'maxHeight': '720',
        'minFrameRate': '15',
        'maxFrameRate': '30',
      },
      'facingMode': 'user',
    }
  };

  // Getters
  MediaStream? get localStream => _localStream;
  Map<String, MediaStream> get remoteStreams => _remoteStreams;
  Map<String, RTCPeerConnection> get peerConnections => _peerConnections;

  // Initialize local media (camera and microphone)
  Future<MediaStream?> initializeLocalMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      return _localStream;
    } catch (e) {
      print('Error initializing local media: $e');
      return null;
    }
  }

  // Create peer connection for a specific participant
  Future<RTCPeerConnection?> createPeerConnection(
    String participantId,
    Function(RTCIceCandidate) onIceCandidate,
    Function(MediaStream) onAddStream,
  ) async {
    try {
      final pc = await createPeerConnectionWithConfig(_configuration);
      
      // Add local stream tracks to peer connection
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          pc.addTrack(track, _localStream!);
        });
      }

      // Handle ICE candidates
      pc.onIceCandidate = (candidate) {
        if (candidate != null) {
          onIceCandidate(candidate);
        }
      };

      // Handle remote stream
      pc.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          final stream = event.streams[0];
          _remoteStreams[participantId] = stream;
          onAddStream(stream);
        }
      };

      // Handle connection state changes
      pc.onConnectionState = (state) {
        print('Peer connection state for $participantId: $state');
      };

      _peerConnections[participantId] = pc;
      return pc;
    } catch (e) {
      print('Error creating peer connection for $participantId: $e');
      return null;
    }
  }

  // Helper to create peer connection with proper configuration
  Future<RTCPeerConnection> createPeerConnectionWithConfig(Map<String, dynamic> config) async {
    return await createPeerConnection(config);
  }

  // Create and return an SDP offer
  Future<RTCSessionDescription?> createOffer(String participantId) async {
    try {
      final pc = _peerConnections[participantId];
      if (pc == null) return null;

      final offer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      
      await pc.setLocalDescription(offer);
      return offer;
    } catch (e) {
      print('Error creating offer for $participantId: $e');
      return null;
    }
  }

  // Create and return an SDP answer
  Future<RTCSessionDescription?> createAnswer(String participantId) async {
    try {
      final pc = _peerConnections[participantId];
      if (pc == null) return null;

      final answer = await pc.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      
      await pc.setLocalDescription(answer);
      return answer;
    } catch (e) {
      print('Error creating answer for $participantId: $e');
      return null;
    }
  }

  // Set remote description
  Future<void> setRemoteDescription(String participantId, RTCSessionDescription description) async {
    try {
      final pc = _peerConnections[participantId];
      if (pc != null) {
        await pc.setRemoteDescription(description);
      }
    } catch (e) {
      print('Error setting remote description for $participantId: $e');
    }
  }

  // Add ICE candidate
  Future<void> addIceCandidate(String participantId, RTCIceCandidate candidate) async {
    try {
      final pc = _peerConnections[participantId];
      if (pc != null) {
        await pc.addCandidate(candidate);
      }
    } catch (e) {
      print('Error adding ICE candidate for $participantId: $e');
    }
  }

  // Toggle audio on/off
  void toggleAudio(bool enabled) {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  // Toggle video on/off
  void toggleVideo(bool enabled) {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  // Close peer connection for a specific participant
  Future<void> closePeerConnection(String participantId) async {
    final pc = _peerConnections[participantId];
    if (pc != null) {
      await pc.close();
      _peerConnections.remove(participantId);
    }
    _remoteStreams.remove(participantId);
  }

  // Cleanup all resources
  Future<void> dispose() async {
    // Close all peer connections
    for (var pc in _peerConnections.values) {
      await pc.close();
    }
    _peerConnections.clear();
    
    // Stop local stream
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        track.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }
    
    // Clear remote streams
    for (var stream in _remoteStreams.values) {
      await stream.dispose();
    }
    _remoteStreams.clear();
  }
}
