import 'package:flutter/material.dart';

import '../servise/api_service.dart';

class ParticipantsList extends StatelessWidget {
  final List participants;
  final Participant currentParticipant;
  final VoidCallback onRefresh;

  const ParticipantsList({
    super.key,
    required this.participants,
    required this.currentParticipant,
    required this.onRefresh,
  });

  String _formatJoinTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final safeParticipants = participants.isNotEmpty ? participants : <Participant>[];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.grey,
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Participants (${safeParticipants.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh participants',
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: safeParticipants.isEmpty
                ? const Center(
              child: Text(
                'No participants found',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: safeParticipants.length,
              itemBuilder: (context, index) {
                final participant = safeParticipants[index];
                final isCurrentUser = participant.id == currentParticipant.id;

                return Container(
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue.shade50 : null,
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.2),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: participant.isHost ? Colors.orange : Colors.blue,
                      child: Text(
                        participant.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            participant.name,
                            style: TextStyle(
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (participant.isHost) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                        ],
                        if (isCurrentUser) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '(You)',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      'Joined: ${_formatJoinTime(participant.joinedAt!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}