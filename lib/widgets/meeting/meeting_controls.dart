import 'package:flutter/material.dart';
import '../../models/meeting.dart';

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
  bool _isVideoOn = true;
  bool _isAudioOn = true;
  bool _isScreenSharing = false;

  @override
  Widget build(BuildContext context) {
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
              icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
              label: 'Video',
              isActive: _isVideoOn,
              activeColor: Colors.blue,
              inactiveColor: Colors.red,
              onPressed: () {
                setState(() {
                  _isVideoOn = !_isVideoOn;
                });
                // TODO: Implement video toggle
              },
            ),
            
            // Audio toggle
            _buildControlButton(
              icon: _isAudioOn ? Icons.mic : Icons.mic_off,
              label: 'Audio',
              isActive: _isAudioOn,
              activeColor: Colors.green,
              inactiveColor: Colors.red,
              onPressed: () {
                setState(() {
                  _isAudioOn = !_isAudioOn;
                });
                // TODO: Implement audio toggle
              },
            ),
            
            // Screen share toggle
            _buildControlButton(
              icon: _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
              label: 'Share',
              isActive: _isScreenSharing,
              activeColor: Colors.orange,
              inactiveColor: Colors.grey,
              onPressed: () {
                setState(() {
                  _isScreenSharing = !_isScreenSharing;
                });
                // TODO: Implement screen sharing
              },
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