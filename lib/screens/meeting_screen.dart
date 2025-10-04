import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/meeting.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/meeting/participant_grid.dart';
import '../widgets/meeting/chat_panel.dart';
import '../widgets/meeting/meeting_controls.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool _showChat = false;
  final _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final meeting = provider.currentMeeting;
        
        if (meeting == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Meeting')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64),
                  SizedBox(height: 16),
                  Text('No active meeting found'),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Code: ${meeting.code}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(_showChat ? Icons.video_call : Icons.chat),
                onPressed: () {
                  setState(() {
                    _showChat = !_showChat;
                  });
                },
                tooltip: _showChat ? 'Show Video' : 'Show Chat',
              ),
              IconButton(
                icon: const Icon(Icons.people),
                onPressed: () => _showParticipantsList(meeting),
                tooltip: 'Participants (${meeting.participantCount})',
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: _leaveMeeting,
                tooltip: 'Leave Meeting',
              ),
            ],
          ),
          body: Column(
            children: [
              // Meeting info bar
              _buildMeetingInfoBar(meeting),
              
              // Main content area
              Expanded(
                child: _showChat 
                    ? ChatPanel(
                        messages: provider.chatMessages,
                        onSendMessage: (message) => provider.sendChatMessage(message),
                      )
                    : ParticipantGrid(participants: meeting.participants),
              ),
              
              // Meeting controls
              MeetingControls(
                meeting: meeting,
                onToggleChat: () {
                  setState(() {
                    _showChat = !_showChat;
                  });
                },
                onLeaveMeeting: _leaveMeeting,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeetingInfoBar(Meeting meeting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Host: ${meeting.hostName} • ${meeting.participantCount} participants',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: meeting.isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  meeting.isActive ? '🟢 LIVE' : '🔴 ENDED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Started: ${DateFormat('HH:mm').format(meeting.createdAt)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showParticipantsList(Meeting meeting) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants (${meeting.participantCount})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...meeting.participants.map((participant) => ListTile(
              leading: CircleAvatar(
                backgroundColor: participant.isHost ? Colors.yellow : Colors.blue.shade100,
                child: Text(
                  participant.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: participant.isHost ? Colors.white : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(participant.name),
                  if (participant.isHost) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HOST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                'Joined: ${DateFormat('HH:mm').format(participant.joinedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    participant.hasVideo ? Icons.videocam : Icons.videocam_off,
                    size: 16,
                    color: participant.hasVideo ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    participant.hasAudio ? Icons.mic : Icons.mic_off,
                    size: 16,
                    color: participant.hasAudio ? Colors.green : Colors.red,
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _leaveMeeting() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meeting'),
        content: const Text('Are you sure you want to leave this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              final provider = context.read<AppProvider>();
              await provider.leaveMeeting();
              
              if (mounted) {
                Navigator.pop(context); // Return to home screen
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}