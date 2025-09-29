import 'dart:developer' as developer;
import 'package:api_demo/servise/socketService.dart';
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
  MediaStream? getLocalStream() => _localStream;

  void _setupSocketListeners() {
    socketService.onOffer(_handleOffer);
    socketService.onAnswer(_handleAnswer);
    socketService.onIceCandidate(_handleIceCandidate);
    socketService.onScreenShareOffer(_handleScreenShareOffer);
    socketService.onScreenShareAnswer(_handleScreenShareAnswer);
    socketService.onScreenShareIceCandidate(_handleScreenShareIceCandidate);
  }

  // Initialize local media (camera and microphone)
  Future<MediaStream?> initializeLocalMedia() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      developer.log('✅ Local media initialized');
      return _localStream;
    } catch (error) {
      developer.log('❌ Failed to initialize local media: $error');
      rethrow;
    }
  }

  // Create peer connection for a participant
  Future<RTCPeerConnection> _createPeerConnection(String participantId) async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };

    final RTCPeerConnection peerConnection = await createPeerConnection(configuration);

    // Handle incoming stream
    peerConnection.onTrack = (RTCTrackEvent event) {
      developer.log('📺 Received remote stream from $participantId');
      if (event.streams.isNotEmpty) {
        _remoteStreams[participantId] = event.streams[0];
        final callback = _mediaStreamCallbacks['remoteStream'];
        if (callback != null) {
          callback(event.streams[0]);
        }
      }
    };

    // Handle ICE candidates
    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      socketService.sendIceCandidate(candidate.toMap(), to: participantId);
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

      socketService.sendAnswer(answer.toMap(), to: from);
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

      socketService.sendOffer(offer.toMap(), to: participantId);
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
      socketService.toggleAudio(_isAudioEnabled);
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
      socketService.toggleVideo(_isVideoEnabled);
      return _isVideoEnabled;
    }
    return false;
  }

  // Start screen sharing
  Future<MediaStream?> startScreenShare() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'video': {
          'deviceId': {'exact': 'screen'},
          'mandatory': {},
        },
        'audio': true,
      };

      _screenStream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      _isScreenSharing = true;
      socketService.startScreenShare();

      // Replace video track in all peer connections
      final videoTrack = _screenStream!.getVideoTracks().first;
      for (var entry in _peerConnections.entries) {
        final peerConnection = entry.value;
        final senders = await peerConnection.getSenders();
        final videoSender = senders.firstWhere(
              (sender) => sender.track?.kind == 'video',
          orElse: () => throw StateError('No video sender found'),
        );
        await videoSender.replaceTrack(videoTrack);
      }

      // Listen for screen share end
      videoTrack.onEnded = () {
        stopScreenShare();
      };

      return _screenStream;
    } catch (error) {
      developer.log('❌ Failed to start screen sharing: $error');
      rethrow;
    }
  }

  // Stop screen sharing
  Future<void> stopScreenShare() async {
    if (_screenStream != null) {
      _screenStream!.getTracks().forEach((track) => track.stop());
      _screenStream = null;
      _isScreenSharing = false;
      socketService.stopScreenShare();

      // Replace back to camera
      if (_localStream != null) {
        final videoTrack = _localStream!.getVideoTracks().first;
        for (var entry in _peerConnections.entries) {
          final peerConnection = entry.value;
          final senders = await peerConnection.getSenders();
          final videoSender = senders.firstWhere(
                (sender) => sender.track?.kind == 'video',
            orElse: () => throw StateError('No video sender found'),
          );
          await videoSender.replaceTrack(videoTrack);
        }
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

  // Set callback for remote streams
  void onRemoteStream(Function(MediaStream) callback) {
    _mediaStreamCallbacks['remoteStream'] = callback;
  }

  // Clean up resources
  Future<void> cleanup() async {
    // Stop local stream
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
      await _localStream!.dispose();
      _localStream = null;
    }

    // Stop screen stream
    if (_screenStream != null) {
      _screenStream!.getTracks().forEach((track) => track.stop());
      await _screenStream!.dispose();
      _screenStream = null;
    }

    // Close all peer connections
    for (var entry in _peerConnections.entries) {
      await entry.value.close();
    }

    // Clear maps
    _peerConnections.clear();
    _remoteStreams.clear();
    _mediaStreamCallbacks.clear();
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