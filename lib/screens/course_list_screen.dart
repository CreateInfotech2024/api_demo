import 'package:api_demo/screens/meeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/course.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/course/course_card.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load courses when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💄 Beauty LMS Courses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '🔴 Live', icon: Icon(Icons.circle, color: Colors.red, size: 12)),
            Tab(text: '📅 Scheduled', icon: Icon(Icons.schedule)),
            Tab(text: '✅ Completed', icon: Icon(Icons.check_circle)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppProvider>().loadCourses();
            },
            tooltip: 'Refresh courses',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Loading courses...');
            }

            if (provider.errorMessage != null) {
              return CustomErrorWidget(
                message: provider.errorMessage!,
                onRetry: () => provider.loadCourses(),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCourseList(provider.courses.where((c) => c.isLive).toList(), 'No live courses at the moment'),
                _buildCourseList(provider.courses.where((c) => c.isScheduled).toList(), 'No scheduled courses'),
                _buildCourseList(provider.courses.where((c) => c.isCompleted).toList(), 'No completed courses yet'),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.home),
        label: const Text('Back to Home'),
        backgroundColor: Colors.pink.shade400,
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses, String emptyMessage) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<AppProvider>().loadCourses(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppProvider>().loadCourses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return CourseCard(
            course: course,
            onTap: () => _showCourseDetails(course),
          );
        },
      ),
    );
  }

  void _showCourseDetails(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCourseDetailsSheet(course),
    );
  }

  Widget _buildCourseDetailsSheet(Course course) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(course),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.statusDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (course.hasRecording)
                        const Icon(Icons.videocam, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Course title
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Instructor
                  if (course.instructorName != null)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Instructor: ${course.instructorName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Course details
                  _buildDetailRow('Participants', '${course.prerequisites.length}/${course.maxParticipants}'),
                  if (course.startedAt != null)
                    _buildDetailRow('Start Time', DateFormat('MMM dd, yyyy - hh:mm a').format(course.startedAt!)),
                  if (course.completedAt != null)
                    _buildDetailRow('End Time', DateFormat('MMM dd, yyyy - hh:mm a').format(course.completedAt!)),
                  if (course.meetingCode != null)
                    _buildDetailRow('Meeting Code', course.meetingCode!),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (course.isLive) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _joinLiveCourse(course),
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text('Join Live Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ] else if (course.hasRecording && course.recordingUrl != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigator.pop(context);
                          // Navigate to recording playback
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(Course course) {
    switch (course.status) {
      case 'active':
        return Colors.red;
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _joinLiveCourse(Course course) async {
    // Show dialog to choose between creating as host or joining as participant
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedRole;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Join Live Course'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course: ${course.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (course.instructorName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: ${course.instructorName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (course.meetingCode != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Meeting Code: ${course.meetingCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Enter your name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select your role:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    RadioListTile<String>(
                      title: const Text('Join as Host/Instructor'),
                      subtitle: const Text('Create and start the meeting'),
                      value: 'host',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: const Text('Join as Participant'),
                      subtitle: course.meetingCode != null
                          ? const Text('Join the existing meeting')
                          : const Text('Meeting code not available'),
                      value: 'participant',
                      groupValue: selectedRole,
                      onChanged: course.meetingCode != null
                          ? (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            }
                          : null,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    nameController.dispose();
                    Navigator.of(dialogContext).pop(null);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (formKey.currentState!.validate() && selectedRole != null) {
                      Navigator.of(dialogContext).pop({
                        'name': nameController.text.trim(),
                        'role': selectedRole,
                      });
                    } else if (selectedRole == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Please select your role'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      final provider = context.read<AppProvider>();
      final name = result['name'] as String;
      final role = result['role'] as String;
      
      // Close the course details sheet
      if (mounted) {
        Navigator.pop(context);
      }
      
      bool success = false;
      
      if (role == 'host') {
        // Create meeting as host
        success = await provider.createMeeting(
          hostName: name,
          title: course.title,
          description: course.description,
        );
      } else {
        // Join existing meeting as participant
        if (course.meetingCode != null) {
          success = await provider.joinMeeting(
            meetingCode: course.meetingCode!,
            participantName: name,
          );
        }
      }

      if (success && mounted) {
        // Navigate to meeting screen
        Navigator.pushNamed(context, '/meeting');
      }
    }

    nameController.dispose();
  }
}