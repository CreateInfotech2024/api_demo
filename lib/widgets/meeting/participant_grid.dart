import 'package:flutter/material.dart';
import '../../models/meeting.dart';

class ParticipantGrid extends StatelessWidget {
  final List<Participant> participants;

  const ParticipantGrid({
    super.key,
    required this.participants,
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
        return ParticipantTile(
          participant: participants[index],
          isLarge: participants.length == 1,
        );
      },
    );
  }
}

class ParticipantTile extends StatelessWidget {
  final Participant participant;
  final bool isLarge;

  const ParticipantTile({
    super.key,
    required this.participant,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: participant.isHost
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          // Video placeholder (in a real implementation, this would be the video stream)
          Center(
            child: participant.hasVideo
                ? _buildVideoPlaceholder()
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
                    participant.hasAudio ? Icons.mic : Icons.mic_off,
                    size: 16,
                    color: participant.hasAudio ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  
                  // Participant name
                  Expanded(
                    child: Text(
                      participant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Host indicator
                  if (participant.isHost) ...[
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
          if (!participant.hasVideo)
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

  Widget _buildVideoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: isLarge ? 48 : 32,
              color: Colors.white,
            ),
            if (isLarge) ...[
              const SizedBox(height: 8),
              const Text(
                'Video Stream',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return CircleAvatar(
      radius: isLarge ? 64 : 32,
      backgroundColor: participant.isHost ? Colors.yellow : Colors.blue.shade400,
      child: Text(
        participant.name.isNotEmpty 
            ? participant.name.substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: isLarge ? 32 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}