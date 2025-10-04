import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meeting.dart';
import '../../providers/app_provider.dart';

class MeetingControls extends StatefulWidget {
  final Meeting meeting;
  final VoidCallback onToggleChat;
  final VoidCallback onLeaveMeeting;

  const MeetingControls({
    super.key,
    required this.meeting,
    required this.onToggleChat,
    required this.onLeaveMeeting,
  });

  @override
  State<MeetingControls> createState() => _MeetingControlsState();
}

class _MeetingControlsState extends State<MeetingControls> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Video toggle
                _buildControlButton(
                  icon: provider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: 'Video',
                  isActive: provider.isVideoEnabled,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.red,
                  onPressed: () => provider.toggleVideo(),
                ),
                
                // Audio toggle
                _buildControlButton(
                  icon: provider.isAudioEnabled ? Icons.mic : Icons.mic_off,
                  label: 'Audio',
                  isActive: provider.isAudioEnabled,
                  activeColor: Colors.green,
                  inactiveColor: Colors.red,
                  onPressed: () => provider.toggleAudio(),
                ),
                
                // Screen share toggle
                _buildControlButton(
                  icon: provider.isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                  label: 'Share',
                  isActive: provider.isScreenSharing,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey,
                  onPressed: () => provider.toggleScreenSharing(),
                ),
                
                // Chat toggle
                _buildControlButton(
                  icon: Icons.chat,
                  label: 'Chat',
                  isActive: true,
                  activeColor: Colors.purple,
                  inactiveColor: Colors.grey,
                  onPressed: widget.onToggleChat,
                ),
                
                // Leave meeting
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'Leave',
                  isActive: false,
                  activeColor: Colors.red,
                  inactiveColor: Colors.red,
                  onPressed: widget.onLeaveMeeting,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onPressed,
  }) {
    final color = isActive ? activeColor : inactiveColor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withOpacity(0.1),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}