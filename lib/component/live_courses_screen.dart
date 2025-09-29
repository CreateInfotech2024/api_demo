import 'package:api_demo/component/meeting_room_screen.dart';
import 'package:api_demo/service/api_service.dart';
import 'package:flutter/material.dart';


class LiveCoursesScreen extends StatefulWidget {
  const LiveCoursesScreen({super.key});

  @override
  _LiveCoursesScreenState createState() => _LiveCoursesScreenState();
}

class _LiveCoursesScreenState extends State<LiveCoursesScreen> {
  List<LiveCourse> courses = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String? connectingCourseId;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses({bool isRefresh = false}) async {
    setState(() {
      if (isRefresh) {
        isRefreshing = true;
      } else {
        isLoading = true;
      }
    });

    try {
      final response = await LiveCourseAPI.getAllCourses();

      if (response.success && response.data != null) {
        setState(() {
          courses = response.data!;
        });
      } else {
        _showError(response.error ?? 'Failed to load courses');
      }
    } catch (e) {
      _showError('Failed to load courses: $e');
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Future<void> _handleHostConnect(LiveCourse course) async {
    setState(() {
      connectingCourseId = course.id;
    });

    try {

      // If course is already active and has meeting code, directly join as host
      if (course.status == 'active' && course.meetingCode != null) {
        _navigateToMeeting(course, true);
        return;
      }

      // Start the course as host
      final startResponse = await LiveCourseAPI.startCourse(course.id, instructorName: course.instructorName);

      if (startResponse.success && startResponse.data != null) {
        final meetingData = startResponse.data!['videoConferencing'];
        final updatedCourse = course;

        setState(() {
          final index = courses.indexWhere((c) => c.id == course.id);
          if (index != -1) {
            courses[index] = updatedCourse;
          }
        });

        _navigateToMeeting(updatedCourse, true);
      } else {
        _showError(startResponse.error ?? 'Failed to start course as host');
      }
    } catch (e) {
      _showError('Failed to connect as host: $e');
    } finally {
      setState(() {
        connectingCourseId = null;
      });
    }
  }

  Future<void> _handleParticipantConnect(LiveCourse course) async {
    setState(() {
      connectingCourseId = course.id;
    });

    try {
      final joinResponse = await LiveCourseAPI.joinCourse(course.id,userId: 'participant_${DateTime.now().millisecondsSinceEpoch}', userName: 'Test Participant');

      if (joinResponse.success) {
        _navigateToMeeting(course, false);
      } else {
        _showError(joinResponse.error ?? 'Failed to join course');
      }
    } catch (e) {
      _showError('Failed to connect as participant: $e');
    } finally {
      setState(() {
        connectingCourseId = null;
      });
    }
  }

  void _navigateToMeeting(LiveCourse course, bool isHost) {
    final participant = Participant(
      id: isHost ? course.instructorId : 'participant_${DateTime.now().millisecondsSinceEpoch}',
      name: isHost ? course.instructorName : 'Test Participant',
      isHost: isHost,
      joinedAt: DateTime.now().toIso8601String(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingRoomScreen(
          host: isHost,
          course: course,
          currentParticipant: participant,
        ),
      ),
    ).then((_) {
      // Refresh courses when returning from meeting
      loadCourses(isRefresh: true);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return '🔴';
      case 'completed':
        return '✅';
      case 'scheduled':
        return '📅';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading live courses...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => loadCourses(isRefresh: true),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎓 Live Courses',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: isRefreshing ? null : () => loadCourses(isRefresh: true),
                  icon: Icon(isRefreshing ? Icons.hourglass_empty : Icons.refresh),
                  label: Text(isRefreshing ? 'Refreshing...' : 'Refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: courses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No live courses available at the moment.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => loadCourses(isRefresh: true),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                course.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(course.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_getStatusIcon(course.status)} ${course.status.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (course.description != null) ...[
                          SizedBox(height: 8),
                          Text(
                            course.description!,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildDetailChip('👨‍🏫 ${course.instructorName}'),
                            _buildDetailChip('📂 ${course.category}'),
                            _buildDetailChip('⏱️ ${course.duration} min'),
                            _buildDetailChip('👥 ${course.enrolledUsers.length ?? 0} users'),
                            _buildDetailChip('📹 ${course.recordingEnabled ? '✅ Enabled' : '❌ Disabled'}'),
                            if (course.meetingCode != null)
                              _buildDetailChip('🔑 ${course.meetingCode}', isHighlight: true),
                            _buildDetailChip('📅 ${DateTime.parse(course.scheduledDateTime!).toLocal().toString().substring(0, 16)}'),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: connectingCourseId == course.id
                                    ? null
                                    : () => _handleHostConnect(course),
                                icon: Icon(connectingCourseId == course.id
                                    ? Icons.hourglass_empty
                                    : Icons.person_pin),
                                label: Text(connectingCourseId == course.id
                                    ? 'Connecting...'
                                    : 'Host'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: connectingCourseId == course.id
                                    ? null
                                    : () => _handleParticipantConnect(course),
                                icon: Icon(connectingCourseId == course.id
                                    ? Icons.hourglass_empty
                                    : Icons.group),
                                label: Text(connectingCourseId == course.id
                                    ? 'Joining...'
                                    : 'Join'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildDetailChip(String text, {bool isHighlight = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.purple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isHighlight ? Border.all(color: Colors.purple) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isHighlight ? Colors.purple : Colors.grey[700],
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}