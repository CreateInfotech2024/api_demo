import 'package:api_demo/component/ParticipantsList.dart';
import 'package:api_demo/component/chat_panel.dart';
import 'package:api_demo/model/chat_message.dart';
import 'package:api_demo/service/api_service.dart' hide LiveCourse;
import 'package:flutter/material.dart';
import 'package:api_demo/model/live_course.dart';

class MeetingRoom extends StatefulWidget {
  final LiveCourse meeting;
  final Participant currentParticipant;
  final VoidCallback onLeaveMeeting;
  final Function(String error) onError;
  final Function(LiveCourse course)? onCourseCompleted;

  const MeetingRoom({
    super.key,
    required this.meeting,
    required this.currentParticipant,
    required this.onLeaveMeeting,
    required this.onError,
    this.onCourseCompleted,
  });

  @override
  State<MeetingRoom> createState() => _MeetingRoomState();
}

class _MeetingRoomState extends State<MeetingRoom> {
  List<Participant> participants = [];
  List<ChatMessage> chatMessages = [];
  bool isChatVisible = true;
  LiveCourse meetingInfo = LiveCourse.empty();
  bool isAudioEnabled = true;
  bool isVideoEnabled = true;
  bool isScreenSharing = false;
  bool isInitializingMedia = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    meetingInfo = widget.meeting;
    participants = [widget.currentParticipant];
    initializeConnection();
  }

  Future<void> initializeConnection() async {
    setState(() {
      isInitializingMedia = true;
    });

    try {
      // Initialize media and socket connection
      await initializeMedia();
      await connectToSocket();
    } catch (error) {
      widget.onError('Failed to initialize connection: ${error.toString()}');
    } finally {
      setState(() {
        isInitializingMedia = false;
      });
    }
  }

  Future<void> initializeMedia() async {
    // Initialize camera/microphone access
    // This would integrate with flutter camera and audio plugins
    print('🎥 Initializing media...');
  }

  Future<void> connectToSocket() async {
    if (widget.meeting.meetingCode != null) {
      // Connect to Socket.IO room
      // This would integrate with socket_io_client package
      print('🔌 Connecting to socket room: ${widget.meeting.meetingCode}');
      setState(() {
        isConnected = true;
      });
    }
  }

  Future<void> handleSendMessage(String message) async {
    if (widget.meeting.meetingCode != null) {
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: widget.currentParticipant.name,
        message: message,
        timestamp: DateTime.now().toIso8601String(),
        meetingCode: widget.meeting.meetingCode!,
      );

      setState(() {
        chatMessages.add(chatMessage);
      });

      // Send via socket
      print('📤 Sending message: $message');
    }
  }

  Future<void> handleEndMeeting() async {
    if (!widget.currentParticipant.isHost!) {
      widget.onError('Only the host can complete the course');
      return;
    }

    try {
      final response = await LiveCourseAPI.completeCourse(widget.meeting.id);
      if (response.success) {
        if (widget.onCourseCompleted != null) {
          widget.onCourseCompleted!(widget.meeting);
        }
        widget.onLeaveMeeting();
      } else {
        widget.onError(response.error ?? 'Failed to complete course');
      }
    } catch (error) {
      widget.onError('Failed to complete course');
    }
  }

  Future<void> refreshMeetingInfo() async {
    try {
      final response = await LiveCourseAPI.getCourseById(widget.meeting.id);
      if (response.success && response.data != null) {
        setState(() {
          meetingInfo = response.data! as LiveCourse;
        });
      }
    } catch (error) {
      widget.onError('Failed to refresh course info');
    }
  }

  void toggleAudio() {
    setState(() {
      isAudioEnabled = !isAudioEnabled;
    });
    print('🎤 Audio ${isAudioEnabled ? "enabled" : "disabled"}');
  }

  void toggleVideo() {
    setState(() {
      isVideoEnabled = !isVideoEnabled;
    });
    print('📹 Video ${isVideoEnabled ? "enabled" : "disabled"}');
  }

  Future<void> toggleScreenShare() async {
    try {
      setState(() {
        isScreenSharing = !isScreenSharing;
      });
      print('🖥️ Screen sharing ${isScreenSharing ? "started" : "stopped"}');
    } catch (error) {
      widget.onError('Failed to toggle screen sharing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎥 ${meetingInfo.name ?? "Meeting Room"}'),
        actions: [
          IconButton(
            onPressed: () => setState(() => isChatVisible = !isChatVisible),
            icon: Icon(isChatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline),
            tooltip: isChatVisible ? 'Hide Chat' : 'Show Chat',
          ),
          IconButton(
            onPressed: refreshMeetingInfo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: widget.onLeaveMeeting,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Leave Meeting',
          ),
          if (widget.currentParticipant.isHost!)
            IconButton(
              onPressed: handleEndMeeting,
              icon: const Icon(Icons.check_circle),
              tooltip: 'Complete Course',
            ),
        ],
      ),
      body: Column(
        children: [
          // Meeting Info Bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Text('Code: ${widget.meeting.meetingCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Text('👥 ${participants.length} participants'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isConnected ? '🟢 Connected' : '🔴 Disconnected',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Row(
              children: [
                // Video Area
                Expanded(
                  flex: isChatVisible ? 3 : 4,
                  child: Column(
                    children: [
                      // Video Container
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: isInitializingMedia
                              ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  '📹 Initializing Camera...',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  'Please allow access to camera and microphone',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                              : Stack(
                            children: [
                              // Local Video
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  width: 150,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: isVideoEnabled
                                            ? const Icon(Icons.videocam, color: Colors.white, size: 32)
                                            : const Icon(Icons.videocam_off, color: Colors.red, size: 32),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'You (${isScreenSharing ? "Screen" : "Camera"})',
                                            style: const TextStyle(color: Colors.white, fontSize: 10),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Remote Videos or Empty State
                              if (participants.length == 1)
                                const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_outline, size: 64, color: Colors.white54),
                                      SizedBox(height: 16),
                                      Text(
                                        '👥 Waiting for other participants to join...',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: participants.length > 4 ? 3 : 2,
                                    childAspectRatio: 16 / 9,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: participants.length - 1,
                                  itemBuilder: (context, index) {
                                    final participant = participants
                                        .where((p) => p.id != widget.currentParticipant.id)
                                        .toList()[index];
                                    return RemoteVideoWidget(participant: participant);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Video Controls
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[900],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VideoControlButton(
                              icon: isAudioEnabled ? Icons.mic : Icons.mic_off,
                              label: isAudioEnabled ? 'Mute' : 'Unmute',
                              isEnabled: isAudioEnabled,
                              onPressed: isInitializingMedia ? null : toggleAudio,
                              color: isAudioEnabled ? Colors.blue : Colors.red,
                            ),
                            const SizedBox(width: 16),
                            VideoControlButton(
                              icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                              label: isVideoEnabled ? 'Stop Video' : 'Start Video',
                              isEnabled: isVideoEnabled,
                              onPressed: isInitializingMedia ? null : toggleVideo,
                              color: isVideoEnabled ? Colors.blue : Colors.red,
                            ),
                            const SizedBox(width: 16),
                            VideoControlButton(
                              icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                              label: isScreenSharing ? 'Stop Sharing' : 'Share Screen',
                              isEnabled: widget.currentParticipant.isHost!,
                              onPressed: (isInitializingMedia || !widget.currentParticipant.isHost!)
                                  ? null
                                  : toggleScreenShare,
                              color: isScreenSharing ? Colors.orange : Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sidebar
                if (isChatVisible)
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      children: [
                        // Participants List
                        // Container(
                        //   height: 200,
                        //   padding: const EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey[50],
                        //     border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                        //   ),
                        //   child: ParticipantsList(
                        //     participants: participants,
                        //     currentParticipant: widget.currentParticipant, onRefresh: () {  },
                        //   ),
                        // ),

                        // Chat Panel
                        Expanded(
                          child: ChatPanel(
                            messages: chatMessages,
                            onSendMessage: handleSendMessage,
                            currentUser: widget.currentParticipant.name,
                          ),
                        ),
                      ],
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

class RemoteVideoWidget extends StatelessWidget {
  final Participant participant;

  const RemoteVideoWidget({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.person, size: 48, color: Colors.white54),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                participant.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final Color color;

  const VideoControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isEnabled,
    this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}