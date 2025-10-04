import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print("check name ${course.title}");
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Instructor name
              if (course.instructorName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      course.instructorName!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // Description
              // Text(
              //   course.description,
              //   style: Theme.of(context).textTheme.bodyMedium,
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
              
              const SizedBox(height: 12),
              
              // Course details row
              if(course.prerequisites != null)
              Row(
                children: [
                  // Participants count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.prerequisites.length}/${course.maxParticipants}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Meeting code (if available)
                  if (course.meetingCode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.code,
                            size: 14,
                            color: Colors.purple.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.meetingCode!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Recording indicator
                  if (course.hasRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Recorded',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Time information
              if (course.startedAt != null || course.completedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimeInfo(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    String text;
    IconData? icon;

    switch (course.status) {
      case 'active':
        backgroundColor = Colors.red;
        text = 'LIVE';
        icon = Icons.circle;
        break;
      case 'scheduled':
        backgroundColor = Colors.blue;
        text = 'SCHEDULED';
        icon = Icons.schedule;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        text = 'COMPLETED';
        icon = Icons.check_circle;
        break;
      default:
        backgroundColor = Colors.grey;
        text = course.status.toUpperCase();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeInfo() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM dd, HH:mm');
    
    if (course.isLive) {
      return 'Started: ${dateFormat.format(course.startedAt!)}';
    } else if (course.isScheduled && course.startedAt != null) {
      final difference = course.startedAt!.difference(now);
      if (difference.inDays > 0) {
        return 'Starts: ${dateFormat.format(course.startedAt!)}';
      } else if (difference.inHours > 0) {
        return 'Starts in ${difference.inHours}h ${difference.inMinutes % 60}m';
      } else if (difference.inMinutes > 0) {
        return 'Starts in ${difference.inMinutes}m';
      } else {
        return 'Starting soon';
      }
    } else if (course.isCompleted) {
      if (course.completedAt != null) {
        return 'Ended: ${dateFormat.format(course.completedAt!)}';
      } else {
        return 'Completed: ${dateFormat.format(course.updatedAt)}';
      }
    }
    
    return 'Created: ${dateFormat.format(course.createdAt)}';
  }
}