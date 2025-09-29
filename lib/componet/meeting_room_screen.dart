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
      
      // Initialize media for all participants (both host and non-host)
      MediaStream? stream;
      if (widget.currentParticipant.isHost!) {
        // Host always initializes media
        stream = await webrtcService.initializeLocalMedia();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
        }
      } else {
        // Non-host participants also initialize media to be visible and audible
        try {
          stream = await webrtcService.initializeLocalMedia();
          if (stream != null) {
            await localRenderer.setSrcObject(stream);
            print('✅ Non-host participant media initialized successfully');
          }
        } catch (e) {
          print('⚠️ Non-host participant media initialization failed: $e');
          // Continue without local media - participant can still view others
        }
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

      // After joining, create offers for any existing participants if we have media
      // This ensures late joiners can see existing participants' streams
      Future.delayed(Duration(seconds: 2), () {
        final webrtcService = context.read<WebRTCService>();
        if (webrtcService.getLocalStream() != null) {
          for (final participant in participants) {
            if (participant.id != widget.currentParticipant.id) {
              print('🔄 Creating offer for existing participant: ${participant.name}');
              webrtcService.createOffer(participant.id);
            }
          }
        }
        
        // Log connection status for debugging
        webrtcService.logConnectionStatus();
      });

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

      // Create WebRTC offer for the new participant if we have local media
      final webrtcService = context.read<WebRTCService>();
      if (webrtcService.getLocalStream() != null) {
        webrtcService.createOffer(data.participantId);
      }
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
    if (context.read<WebRTCService>().getLocalStream() == null) {
      try {
        final webrtcService = context.read<WebRTCService>();
        final stream = await webrtcService.initializeLocalMedia();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
          print('✅ Media initialized for audio toggle');
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
    if (context.read<WebRTCService>().getLocalStream() == null) {
      try {
        final webrtcService = context.read<WebRTCService>();
        final stream = await webrtcService.initializeLocalMedia();
        if (stream != null) {
          await localRenderer.setSrcObject(stream);
          print('✅ Media initialized for video toggle');
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
      
      print('🔄 Updating remote stream renderer for ${remoteStreams.length} remote streams');
      
      String? foundParticipantId;
      for (var entry in remoteStreams.entries) {
        if (entry.value == stream) {
          foundParticipantId = entry.key;
          break;
        }
      }
      
      if (foundParticipantId != null) {
        print('📺 Found matching stream for participant: $foundParticipantId');
        
        // Initialize renderer if it doesn't exist
        if (!remoteRenderers.containsKey(foundParticipantId)) {
          await _initializeRemoteRenderer(foundParticipantId);
        }
        
        final renderer = remoteRenderers[foundParticipantId];
        if (renderer != null) {
          try {
            await renderer.setSrcObject(stream);
            print('✅ Successfully set remote stream for $foundParticipantId');
            
            // Verify the stream has active tracks
            final videoTracks = stream.getVideoTracks();
            final audioTracks = stream.getAudioTracks();
            print('  - Video tracks: ${videoTracks.length} (enabled: ${videoTracks.where((t) => t.enabled).length})');
            print('  - Audio tracks: ${audioTracks.length} (enabled: ${audioTracks.where((t) => t.enabled).length})');
            
            setState(() {
              // Force rebuild to show new remote streams
            });
          } catch (rendererError) {
            print('❌ Error setting stream to renderer: $rendererError');
            // Try to recreate the renderer
            await _cleanupRemoteRenderer(foundParticipantId);
            await _initializeRemoteRenderer(foundParticipantId);
            final newRenderer = remoteRenderers[foundParticipantId];
            if (newRenderer != null) {
              await newRenderer.setSrcObject(stream);
              setState(() {});
            }
          }
        }
      } else {
        print('⚠️ Could not find participant ID for received stream');
        // Log available streams for debugging
        for (var entry in remoteStreams.entries) {
          print('  - Available stream: ${entry.key}');
        }
      }
    } catch (e) {
      print('❌ Error updating remote stream renderer: $e');
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
      final webrtcService = context.read<WebRTCService>();
      final connectionState = webrtcService.getConnectionState(participant.id);
      final hasActiveStream = webrtcService.hasRemoteStream(participant.id);
      
      // Determine connection status
      String statusText = 'Connecting...';
      Color statusColor = Colors.orange;
      IconData statusIcon = Icons.hourglass_empty;
      
      if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected && hasActiveStream) {
        statusText = 'Connected';
        statusColor = Colors.green;
        statusIcon = Icons.videocam;
      } else if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        statusText = 'Connection failed';
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
      } else if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        statusText = 'Disconnected';
        statusColor = Colors.red;
        statusIcon = Icons.videocam_off;
      }
      
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: participant.isHost ? Colors.orange : Colors.white, 
            width: participant.isHost ? 2 : 1
          ),
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
                      Icon(statusIcon, size: 24, color: statusColor),
                      SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              
              // Participant name with better styling
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black70,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    participant.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              // Host indicator with better styling
              if (participant.isHost)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.star, size: 10, color: Colors.white),
                  ),
                ),
              
              // Connection status indicator
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
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
                        // Main video area - Google Meet style video display
                        if (remoteRenderers.isNotEmpty)
                          // Participants see remote participants (prioritizing host) in main area
                          Builder(
                            builder: (context) {
                              // Find the best remote stream to display (prioritize host)
                              RTCVideoRenderer? bestRenderer;
                              String? bestParticipantName;
                              
                              // First, try to find host's video
                              final hostParticipant = participants.firstWhere(
                                (p) => p.isHost == true && p.id != widget.currentParticipant.id,
                                orElse: () => Participant(id: '', name: '', isHost: false),
                              );
                              
                              if (hostParticipant.id.isNotEmpty) {
                                final hostRenderer = remoteRenderers[hostParticipant.id];
                                if (hostRenderer != null && hostRenderer.srcObject != null) {
                                  // Check if host's video stream is active
                                  final stream = hostRenderer.srcObject as MediaStream?;
                                  if (stream != null && stream.getVideoTracks().isNotEmpty) {
                                    final videoTrack = stream.getVideoTracks().first;
                                    if (videoTrack.enabled) {
                                      bestRenderer = hostRenderer;
                                      bestParticipantName = '👑 ${hostParticipant.name} (Host)';
                                    }
                                  }
                                }
                              }
                              
                              // If no host video, find any active remote stream
                              if (bestRenderer == null) {
                                for (var entry in remoteRenderers.entries) {
                                  final renderer = entry.value;
                                  if (renderer.srcObject != null) {
                                    final stream = renderer.srcObject as MediaStream?;
                                    if (stream != null && stream.getVideoTracks().isNotEmpty) {
                                      final videoTrack = stream.getVideoTracks().first;
                                      if (videoTrack.enabled) {
                                        bestRenderer = renderer;
                                        final participant = participants.firstWhere(
                                          (p) => p.id == entry.key,
                                          orElse: () => Participant(id: entry.key, name: entry.key, isHost: false),
                                        );
                                        bestParticipantName = participant.name;
                                        break;
                                      }
                                    }
                                  }
                                }
                              }
                              
                              if (bestRenderer != null) {
                                return Stack(
                                  children: [
                                    RTCVideoView(
                                      bestRenderer,
                                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                    ),
                                    // Show participant name in main video
                                    if (bestParticipantName != null)
                                      Positioned(
                                        bottom: 16,
                                        left: 16,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            bestParticipantName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }
                              
                              // Fallback to any available renderer
                              final fallbackRenderer = remoteRenderers.values
                                  .firstWhere((renderer) => renderer.srcObject != null,
                                  orElse: () => remoteRenderers.values.first);
                              return RTCVideoView(
                                fallbackRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              );
                            },
                          )
                        else if (widget.currentParticipant.isHost! && localRenderer.srcObject != null)
                          // Host shows their own video in main area when no participants joined
                          Stack(
                            children: [
                              RTCVideoView(
                                localRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '👑 You (Host)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (!widget.currentParticipant.isHost! && localRenderer.srcObject != null)
                          // Non-host participants can see their own video if no remote streams
                          Stack(
                            children: [
                              RTCVideoView(
                                localRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'You',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          // Waiting for participants with Google Meet-like styling
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.people_outline, 
                                    size: 64, 
                                    color: Colors.white54
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  participants.length == 1 
                                      ? 'Waiting for others to join...'
                                      : 'Connecting to participants...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  participants.length == 1
                                      ? 'Share the meeting code: ${widget.course.meetingCode ?? 'N/A'}'
                                      : 'Setting up video connections with ${participants.length - 1} participant(s)...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (participants.length == 1) ...[
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      '💡 Your camera and microphone are ready',
                                      style: TextStyle(
                                        color: Colors.blue[200],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
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
                        
                        // Local video thumbnail (bottom right, Google Meet style) - show for all participants when they have local stream
                        if (localRenderer.srcObject != null && participants.length > 1)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 120,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    RTCVideoView(
                                      localRenderer,
                                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                      mirror: !isScreenSharing, // Mirror camera but not screen share
                                    ),
                                    
                                    // Video controls overlay
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Row(
                                        children: [
                                          if (widget.currentParticipant.isHost!)
                                            Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.star, size: 8, color: Colors.white),
                                            ),
                                          SizedBox(width: 4),
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: isVideoEnabled ? Colors.green : Colors.red,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                                              size: 8,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: isAudioEnabled ? Colors.green : Colors.red,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isAudioEnabled ? Icons.mic : Icons.mic_off,
                                              size: 8,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Name label
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      right: 4,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black70,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isScreenSharing ? 'You (Screen)' : 'You',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Audio button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAudioEnabled ? Colors.grey[800] : Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: isInitializingMedia ? null : _toggleAudio,
                          icon: Icon(
                            isAudioEnabled ? Icons.mic : Icons.mic_off,
                            color: Colors.white,
                          ),
                          tooltip: isAudioEnabled ? 'Mute microphone' : 'Unmute microphone',
                        ),
                      ),
                      
                      // Video button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isVideoEnabled ? Colors.grey[800] : Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: isInitializingMedia ? null : _toggleVideo,
                          icon: Icon(
                            isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                            color: Colors.white,
                          ),
                          tooltip: isVideoEnabled ? 'Turn off camera' : 'Turn on camera',
                        ),
                      ),
                      
                      // Screen share button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isScreenSharing ? Colors.orange : Colors.grey[800],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: isInitializingMedia ? null : _toggleScreenShare,
                          icon: Icon(
                            isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                            color: Colors.white,
                          ),
                          tooltip: isScreenSharing ? 'Stop sharing screen' : 'Share screen',
                        ),
                      ),
                      
                      // Leave meeting button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _leaveMeeting,
                          icon: Icon(Icons.call_end, color: Colors.white),
                          tooltip: 'Leave meeting',
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