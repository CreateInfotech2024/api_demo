import 'package:api_demo/service/api_service.dart';
import 'package:flutter/material.dart';

class LiveCoursesList extends StatefulWidget {
  final Function(LiveCourse course, bool isHost) onHostConnect;
  final Function(String error) onError;

  const LiveCoursesList({
    super.key,
    required this.onHostConnect,
    required this.onError,
  });

  @override
  State<LiveCoursesList> createState() => _LiveCoursesListState();
}

class _LiveCoursesListState extends State<LiveCoursesList> {
  List<LiveCourse> courses = [];
  bool loading = true;
  bool refreshing = false;
  String? connectingCourseId;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses({bool isRefresh = false}) async {
    setState(() {
      if (isRefresh) {
        refreshing = true;
      } else {
        loading = true;
      }
    });

    try {
      final response = await LiveCourseAPI.getAllCourses();

      if (response.success && response.data != null) {
        setState(() {
          courses = response.data!;
        });
      } else {
        widget.onError(response.error ?? 'Failed to load courses');
      }
    } catch (error) {
      widget.onError(error.toString());
    } finally {
      setState(() {
        loading = false;
        refreshing = false;
      });
    }
  }

  Future<void> handleHostConnect(LiveCourse course) async {
    setState(() {
      connectingCourseId = course.id;
    });

    try {
      // If course is already active and has meeting code, directly join as host
      if (course.status == 'active' && course.meetingCode != null) {
        print('Course already active, joining as host...');
        widget.onHostConnect(course, true);
        return;
      }

      // First, get recording status
      final recordingResponse = await LiveCourseAPI.getRecordingStatus(course.id);

      if (recordingResponse.success) {
        print('Recording status: ${recordingResponse.data}');
      }

      // Start the course as host
      final startResponse = await LiveCourseAPI.startCourse(course.id,  instructorName: course.instructorName);

      if (startResponse.success) {
        // Update course status locally
        final updatedCourse = course;

        setState(() {
          final index = courses.indexWhere((c) => c.id == course.id);
          if (index != -1) {
            courses[index] = updatedCourse;
          }
        });

        widget.onHostConnect(updatedCourse, true);
      } else {
        widget.onError(startResponse.error ?? 'Failed to start course as host');
      }
    } catch (error) {
      widget.onError(error.toString());
    } finally {
      setState(() {
        connectingCourseId = null;
      });
    }
  }

  Future<void> handleParticipantConnect(LiveCourse course) async {
    setState(() {
      connectingCourseId = course.id;
    });

    try {
      final joinResponse = await LiveCourseAPI.joinCourse(course.id,
       userId: "participant_${DateTime.now().millisecondsSinceEpoch}", userName: 'Test Participant');

      if (joinResponse.success) {
        widget.onHostConnect(course, false);
      } else {
        widget.onError(joinResponse.error ?? 'Failed to join course');
      }
    } catch (error) {
      widget.onError(error.toString());
    } finally {
      setState(() {
        connectingCourseId = null;
      });
    }
  }

  Color getStatusColor(String status) {
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

  String getStatusIcon(String status) {
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
    if (loading) {
      return const Center(
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

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🎓 Live Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: refreshing ? null : () => loadCourses(isRefresh: true),
                icon: Icon(refreshing ? Icons.hourglass_empty : Icons.refresh),
                label: Text(refreshing ? 'Refreshing...' : 'Refresh'),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: courses.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No live courses available at the moment.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => loadCourses(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseCard(
                course: course,
                connectingCourseId: connectingCourseId,
                onHostConnect: () => handleHostConnect(course),
                onParticipantConnect: () => handleParticipantConnect(course),
                statusColor: getStatusColor(course.status),
                statusIcon: getStatusIcon(course.status),
              );
            },
          ),
        ),
      ],
    );
  }
}
class CourseCard extends StatelessWidget {
  final LiveCourse course;
  final String? connectingCourseId;
  final VoidCallback onHostConnect;
  final VoidCallback onParticipantConnect;
  final Color statusColor;
  final String statusIcon;

  const CourseCard({
    super.key,
    required this.course,
    this.connectingCourseId,
    required this.onHostConnect,
    required this.onParticipantConnect,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isConnecting = connectingCourseId == course.id;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$statusIcon ${course.status.toUpperCase()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              course.description ?? 'No description available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailItem(label: '👨‍🏫 Instructor:', value: course.instructorName),
                  DetailItem(label: '📂 Category:', value: course.category),
                  DetailItem(label: '⏱️ Duration:', value: '${course.duration} min'),
                  DetailItem(label: '👥 Enrolled:', value: '${course.enrolledUsers.length ?? 0} users'),
                  DetailItem(
                    label: '🎹 Recording:',
                    value: course.recordingEnabled ? '✅ Enabled' : '❌ Disabled',
                  ),
                  DetailItem(
                    label: '📅 Scheduled:',
                    value: DateTime.parse(course.scheduledDateTime!).toLocal().toString().substring(0, 16),
                  ),
                  if (course.meetingCode != null)
                    DetailItem(label: '🔑 Meeting Code:', value: course.meetingCode!),
                ],
              ),
            ),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConnecting ? null : onHostConnect,
                    icon: Icon(isConnecting ? Icons.hourglass_empty : Icons.person),
                    label: Text(isConnecting ? 'Connecting...' : 'Host'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConnecting ? null : onParticipantConnect,
                    icon: Icon(isConnecting ? Icons.hourglass_empty : Icons.group),
                    label: Text(isConnecting ? 'Joining...' : 'Join'),
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
  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const DetailItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}