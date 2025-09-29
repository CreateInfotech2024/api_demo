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
      final stream = widget.host ? await webrtcService.initializeLocalMedia(): null;
      if (stream != null) {
        localRenderer.srcObject = stream;
      }

      // Setup WebRTC callbacks
      webrtcService.onRemoteStream((stream) {
        print('Received remote stream: $stream');
        // Handle remote streams
      });

      // Connect to Socket.IO
      final socketService = context.read<SocketService>();
      socketService.connect();

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
      _showError('Failed to access camera/microphone. Please check permissions.');
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

      _addSystemMessage('${data.participantName} joined the meeting');

      // Create WebRTC offer for the new participant
      context.read<WebRTCService>().createOffer(data.participantId);
    });

    socketService.onParticipantLeft((data) {
      setState(() {
        participants.removeWhere((p) => p.id == data.participantId);
      });

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
    final webrtcService = context.read<WebRTCService>();
    final newState = webrtcService.toggleAudio();
    setState(() {
      isAudioEnabled = newState;
    });
  }

  Future<void> _toggleVideo() async {
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
        // Switch back to camera
        final stream = webrtcService.getLocalStream();
        if (stream != null) {
          localRenderer.srcObject = stream;
        }
      } else {
        final screenStream = await webrtcService.startScreenShare();
        setState(() {
          isScreenSharing = true;
        });
        // Show screen share in local video
        if (screenStream != null) {
          localRenderer.srcObject = screenStream;
        }
      }
    } catch (e) {
      _showError('Failed to toggle screen sharing. Please try again.');
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

    // Cleanup services
    final socketService = context.read<SocketService>();
    if (widget.course.meetingCode != null) {
      socketService.leaveMeetingRoom(
        widget.course.meetingCode!,
        widget.currentParticipant.name,
      );
    }
    socketService.removeAllListeners();
    context.read<WebRTCService>().cleanup();

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
                            '🔄 Initializing Camera...',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            'Please allow access to camera and microphone',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              RTCVideoView(
                                localRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'You (${isScreenSharing ? 'Screen' : 'Camera'})',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (participants.length == 1)
                          Container(
                            height: 100,
                            color: Colors.grey[800],
                            child: Center(
                              child: Text(
                                '👥 Waiting for other participants to join...',
                                style: TextStyle(color: Colors.white),
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