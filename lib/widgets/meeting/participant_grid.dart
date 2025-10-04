import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../models/meeting.dart';

class ParticipantGrid extends StatelessWidget {
  final List<Participant> participants;
  final MediaStream? localStream;
  final Map<String, MediaStream> remoteStreams;
  final String? currentParticipantId;

  const ParticipantGrid({
    super.key,
    required this.participants,
    this.localStream,
    this.remoteStreams = const {},
    this.currentParticipantId,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No participants yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    // Determine grid layout based on participant count
    int crossAxisCount;
    double aspectRatio;

    if (participants.length == 1) {
      crossAxisCount = 1;
      aspectRatio = 16 / 9;
    } else if (participants.length <= 4) {
      crossAxisCount = 2;
      aspectRatio = 4 / 3;
    } else if (participants.length <= 9) {
      crossAxisCount = 3;
      aspectRatio = 1;
    } else {
      crossAxisCount = 4;
      aspectRatio = 3 / 4;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        MediaStream? stream;
        
        // Get the appropriate stream for this participant
        if (participant.id == currentParticipantId) {
          stream = localStream;
        } else {
          stream = remoteStreams[participant.id];
        }
        
        return ParticipantTile(
          participant: participant,
          stream: stream,
          isLarge: participants.length == 1,
        );
      },
    );
  }
}

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final MediaStream? stream;
  final bool isLarge;

  const ParticipantTile({
    super.key,
    required this.participant,
    this.stream,
    this.isLarge = false,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  RTCVideoRenderer? _renderer;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  @override
  void didUpdateWidget(ParticipantTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _initRenderer();
    }
  }

  Future<void> _initRenderer() async {
    if (widget.stream != null) {
      _renderer = RTCVideoRenderer();
      await _renderer!.initialize();
      _renderer!.srcObject = widget.stream;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _renderer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: widget.participant.isHost
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          // Video stream or placeholder
          Center(
            child: widget.participant.hasVideo && _renderer != null && _renderer!.srcObject != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RTCVideoView(
                      _renderer!,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: true,
                    ),
                  )
                : _buildAvatarPlaceholder(),
          ),
          
          // Participant info overlay
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  // Audio indicator
                  Icon(
                    widget.participant.hasAudio ? Icons.mic : Icons.mic_off,
                    size: 16,
                    color: widget.participant.hasAudio ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  
                  // Participant name
                  Expanded(
                    child: Text(
                      widget.participant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Host indicator
                  if (widget.participant.isHost) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HOST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Video/Camera off indicator
          if (!widget.participant.hasVideo)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam_off,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return CircleAvatar(
      radius: widget.isLarge ? 64 : 32,
      backgroundColor: widget.participant.isHost ? Colors.yellow : Colors.blue.shade400,
      child: Text(
        widget.participant.name.isNotEmpty 
            ? widget.participant.name.substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: widget.isLarge ? 32 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}