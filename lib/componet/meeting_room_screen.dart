import 'package:api_demo/componet/ParticipantsList.dart';
import 'package:api_demo/componet/chat_panel.dart';
import 'package:api_demo/servise/WebRTCService.dart';
import 'package:api_demo/servise/api_service.dart';
import 'package:api_demo/servise/socketService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MeetingRoomScreen extends StatefulWidget {
  final LiveCourse course;
  final Participant currentParticipant;
  final bool host;

  const MeetingRoomScreen({
    super.key,
    required this.course,
    required this.currentParticipant, required this.host,
  });

  @override
  _MeetingRoomScreenState createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  List<Participant> participants = [];
  List<ChatMessage> chatMessages = [];
  bool isChatVisible = true;
  LiveCourse? meetingInfo;
  bool isAudioEnabled = true;
  bool isVideoEnabled = true;
  bool isScreenSharing = false;
  bool isInitializingMedia = false;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  Map<String, RTCVideoRenderer> remoteRenderers = {};

  @override
  void initState() {
    super.initState();
    meetingInfo = widget.course;
    participants = [widget.currentParticipant];
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await localRenderer.initialize();

    setState(() {
      isInitializingMedia = true;
    });

    try {
      // Initialize WebRTC
      final webrtcService = context.read<WebRTCService>();
      
      // Only initialize media for host or when specifically needed
      MediaStream? stream;
      if (widget.currentParticipant.isHost!) {
        stream = await webrtcService.initializeLocalMedia();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
        }
      } else {
        // For non-host participants, only initialize if explicitly requested
        print('Non-host participant - media initialization skipped initially');
      }

      // Setup WebRTC callbacks for remote streams
      webrtcService.onRemoteStream((stream) {
        print('Received remote stream: $stream');
        
        // Find the participant ID for this stream and update renderer
        _updateRemoteStreamRenderer(stream);
      });

      // Connect to Socket.IO
      final socketService = context.read<SocketService>();
      await socketService.connect();

      // Join meeting room
      if (widget.course.meetingCode != null) {
        socketService.joinMeetingRoom(
          widget.course.meetingCode!,
          widget.currentParticipant.name,
          widget.currentParticipant.id,
          widget.currentParticipant.isHost!,
        );
      }

      // Setup socket listeners
      _setupSocketListeners(socketService);

    } catch (e) {
      print('Initialization error: $e');
      _showError('Failed to initialize meeting room: ${e.toString()}');
    } finally {
      setState(() {
        isInitializingMedia = false;
      });
    }
  }

  void _setupSocketListeners(SocketService socketService) {
    socketService.onChatMessage((message) {
      setState(() {
        chatMessages.add(message);
      });
    });

    socketService.onParticipantJoined((data) {
      final newParticipant = Participant(
        id: data.participantId,
        name: data.participantName,
        isHost: data.isHost ?? false,
        joinedAt: data.joinedAt?? DateTime.now().toIso8601String(),
      );

      setState(() {
        final exists = participants.any((p) => p.id == newParticipant.id);
        if (!exists) {
          participants.add(newParticipant);
        }
      });

      // Initialize remote video renderer for new participant (async)
      if (!remoteRenderers.containsKey(data.participantId)) {
        _initializeRemoteRenderer(data.participantId);
      }

      _addSystemMessage('${data.participantName} joined the meeting');

      // Create WebRTC offer for the new participant
      context.read<WebRTCService>().createOffer(data.participantId);
    });

    socketService.onParticipantLeft((data) {
      setState(() {
        participants.removeWhere((p) => p.id == data.participantId);
      });

      // Clean up remote video renderer (async)
      _cleanupRemoteRenderer(data.participantId);

      _addSystemMessage('${data.participantName} left the meeting');

      // Remove participant from WebRTC
      context.read<WebRTCService>().removeParticipant(data.participantId);
    });

    socketService.onScreenShareStarted((data) {
      _addSystemMessage('${data['hostName']} started screen sharing');
    });

    socketService.onScreenShareStopped((data) {
      _addSystemMessage('${data['hostName']} stopped screen sharing');
    });

    socketService.onError((error) {
      _showError(error['message'] ?? 'Connection error occurred');
    });
  }

  void _addSystemMessage(String message) {
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'System',
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      meetingCode: widget.course.meetingCode,
    );

    setState(() {
      chatMessages.add(systemMessage);
    });
  }

  void _sendMessage(String message) {
    if (widget.course.meetingCode != null) {
      context.read<SocketService>().sendChatMessage(
        widget.course.meetingCode!,
        widget.currentParticipant.name,
        message,
      );
    } else {
      _showError('Meeting room not properly initialized for chat');
    }
  }

  Future<void> _toggleAudio() async {
    // For non-host participants, initialize media if not already done
    if (!widget.currentParticipant.isHost! && context.read<WebRTCService>().getLocalStream() == null) {
      try {
        final webrtcService = context.read<WebRTCService>();
        final stream = await webrtcService.initializeLocalMedia();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
        }
      } catch (e) {
        _showError('Failed to access microphone: ${e.toString()}');
        return;
      }
    }
    
    final webrtcService = context.read<WebRTCService>();
    final newState = webrtcService.toggleAudio();
    setState(() {
      isAudioEnabled = newState;
    });
  }

  Future<void> _toggleVideo() async {
    // For non-host participants, initialize media if not already done
    if (!widget.currentParticipant.isHost! && context.read<WebRTCService>().getLocalStream() == null) {
      try {
        final webrtcService = context.read<WebRTCService>();
        final stream = await webrtcService.initializeLocalMedia();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
        }
      } catch (e) {
        _showError('Failed to access camera: ${e.toString()}');
        return;
      }
    }
    
    final webrtcService = context.read<WebRTCService>();
    final newState = webrtcService.toggleVideo();
    setState(() {
      isVideoEnabled = newState;
    });
  }

  Future<void> _toggleScreenShare() async {
    try {
      final webrtcService = context.read<WebRTCService>();

      if (isScreenSharing) {
        await webrtcService.stopScreenShare();
        setState(() {
          isScreenSharing = false;
        });
        // Switch back to camera - ensure local stream exists
        final stream = webrtcService.getLocalStream();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
        }
      } else {
        // Ensure we have proper permissions and local media before screen sharing
        if (webrtcService.getLocalStream() == null) {
          await webrtcService.initializeLocalMedia();
        }
        
        final screenStream = await webrtcService.startScreenShare();
        setState(() {
          isScreenSharing = true;
        });
        // Show screen share in local video - add safety checks
        if (screenStream != null) {
          await localRenderer.setSrcObject(screenStream);
        }
      }
    } catch (e) {
      setState(() {
        isScreenSharing = false; // Reset state on error
      });
      print('Screen sharing error: $e');
      _showError('Failed to toggle screen sharing: ${e.toString()}');
    }
  }

  Future<void> _endMeeting() async {
    if (!widget.currentParticipant.isHost!) {
      _showError('Only the host can complete the course');
      return;
    }

    try {
      final apiService = context.read<LiveCourseAPI>();
      final response = await LiveCourseAPI.completeCourse(widget.course.id);

      if (response.success) {
        Navigator.pop(context);
      } else {
        _showError(response.error ?? 'Failed to complete course');
      }
    } catch (e) {
      _showError('Failed to complete course: $e');
    }
  }

  void _leaveMeeting() {
    final socketService = context.read<SocketService>();
    if (widget.course.meetingCode != null) {
      socketService.leaveMeetingRoom(
        widget.course.meetingCode!,
        widget.currentParticipant.name,
      );
    }
    Navigator.pop(context);
  }

  Future<void> _updateRemoteStreamRenderer(MediaStream stream) async {
    try {
      final webrtcService = context.read<WebRTCService>();
      final remoteStreams = webrtcService.remoteStreams;
      
      for (var entry in remoteStreams.entries) {
        if (entry.value == stream && remoteRenderers.containsKey(entry.key)) {
          final renderer = remoteRenderers[entry.key];
          if (renderer != null) {
            await renderer.setSrcObject(stream);
            setState(() {
              // Force rebuild to show new remote streams
            });
          }
          break;
        }
      }
    } catch (e) {
      print('Error updating remote stream renderer: $e');
    }
  }

  Future<void> _initializeRemoteRenderer(String participantId) async {
    try {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      setState(() {
        remoteRenderers[participantId] = renderer;
      });
    } catch (e) {
      print('Error initializing remote renderer for $participantId: $e');
    }
  }

  Future<void> _cleanupRemoteRenderer(String participantId) async {
    try {
      if (remoteRenderers.containsKey(participantId)) {
        await remoteRenderers[participantId]?.dispose();
        setState(() {
          remoteRenderers.remove(participantId);
        });
      }
    } catch (e) {
      print('Error cleaning up remote renderer for $participantId: $e');
    }
  }

  List<Widget> _buildParticipantThumbnails() {
    final otherParticipants = participants
        .where((p) => p.id != widget.currentParticipant.id)
        .toList();
    
    return otherParticipants.map((participant) {
      final hasRenderer = remoteRenderers.containsKey(participant.id);
      final renderer = remoteRenderers[participant.id];
      
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            children: [
              if (hasRenderer && renderer != null && renderer.srcObject != null)
                RTCVideoView(
                  renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 24, color: Colors.white54),
                      SizedBox(height: 4),
                      Text(
                        'Connecting...',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    participant.name,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (participant.isHost)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(Icons.star, size: 12, color: Colors.orange),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  @override
  void dispose() {
    localRenderer.dispose();
    
    // Clean up all remote renderers
    remoteRenderers.values.forEach((renderer) {
      renderer.dispose();
    });
    remoteRenderers.clear();

    // Cleanup services
    try {
      final socketService = context.read<SocketService>();
      if (widget.course.meetingCode != null) {
        socketService.leaveMeetingRoom(
          widget.course.meetingCode!,
          widget.currentParticipant.name,
        );
      }
      socketService.removeAllListeners();
      context.read<WebRTCService>().cleanup();
    } catch (e) {
      print('Error during dispose: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎥 ${meetingInfo?.name ?? 'Meeting Room'}'),
            Text(
              'Code: ${widget.course.meetingCode ?? 'N/A'} • ${participants.length} participants',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => setState(() => isChatVisible = !isChatVisible),
            icon: Icon(isChatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline),
            tooltip: isChatVisible ? 'Hide Chat' : 'Show Chat',
          ),
          if (widget.currentParticipant.isHost!)
            IconButton(
              onPressed: _endMeeting,
              icon: Icon(Icons.check_circle),
              tooltip: 'Complete Course',
            ),
          IconButton(
            onPressed: _leaveMeeting,
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Leave Meeting',
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: isChatVisible ? 3 : 1,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: isInitializingMedia
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            '🔄 Initializing Meeting...',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            widget.currentParticipant.isHost! 
                                ? 'Please allow access to camera and microphone'
                                : 'Connecting to meeting room...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                        : Stack(
                      children: [
                        // Main video area - show local video for host or remote videos
                        if (widget.currentParticipant.isHost! || localRenderer.srcObject != null)
                          RTCVideoView(
                            localRenderer,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          )
                        else if (remoteRenderers.isNotEmpty)
                          // Show remote participant video if available
                          Builder(
                            builder: (context) {
                              final firstRemoteRenderer = remoteRenderers.values.first;
                              return RTCVideoView(
                                firstRemoteRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              );
                            },
                          )
                        else
                          // Waiting for participants
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.white54),
                                SizedBox(height: 16),
                                Text(
                                  participants.length == 1 
                                      ? '👥 Waiting for other participants to join...'
                                      : '📹 Waiting for video streams...',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        
                        // Participant thumbnails overlay
                        if (participants.length > 1)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              width: 120,
                              child: Column(
                                children: _buildParticipantThumbnails(),
                              ),
                            ),
                          ),
                        
                        // Local video thumbnail (bottom left)
                        if (widget.currentParticipant.isHost! && localRenderer.srcObject != null)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              width: 120,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    RTCVideoView(
                                      localRenderer,
                                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      right: 4,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'You (${isScreenSharing ? 'Screen' : 'Camera'})',
                                          style: TextStyle(color: Colors.white, fontSize: 10),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[900],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isInitializingMedia ? null : _toggleAudio,
                        icon: Icon(isAudioEnabled ? Icons.mic : Icons.mic_off),
                        label: Text(isAudioEnabled ? 'Mute' : 'Unmute'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAudioEnabled ? Colors.green : Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isInitializingMedia ? null : _toggleVideo,
                        icon: Icon(isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                        label: Text(isVideoEnabled ? 'Stop Video' : 'Start Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isVideoEnabled ? Colors.blue : Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (isInitializingMedia || !widget.currentParticipant.isHost!)
                            ? null
                            : _toggleScreenShare,
                        icon: Icon(isScreenSharing ? Icons.stop_screen_share : Icons.screen_share),
                        label: Text(isScreenSharing ? 'Stop Sharing' : 'Share Screen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isScreenSharing ? Colors.orange : Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isChatVisible)
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  Expanded(
                    child: ParticipantsList(
                      participants: participants,
                      currentParticipant: widget.currentParticipant, onRefresh: () {  },
                    ),
                  ),
                  Expanded(
                    child: ChatPanel(
                      messages: chatMessages,
                      onSendMessage: _sendMessage,
                      currentUser: widget.currentParticipant.name,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}