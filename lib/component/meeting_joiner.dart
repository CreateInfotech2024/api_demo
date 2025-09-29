import 'package:api_demo/service/api_service.dart';
import 'package:flutter/material.dart';

class MeetingJoiner extends StatefulWidget {
  final Function(Meeting meeting, Participant participant) onMeetingJoined;
  final Function(String error) onError;

  const MeetingJoiner({
    super.key,
    required this.onMeetingJoined,
    required this.onError,
  });

  @override
  State<MeetingJoiner> createState() => _MeetingJoinerState();
}

class _MeetingJoinerState extends State<MeetingJoiner> {
  final _formKey = GlobalKey<FormState>();
  final _meetingCodeController = TextEditingController();
  final _participantNameController = TextEditingController(text: 'Test Participant');
  bool loading = false;

  @override
  void dispose() {
    _meetingCodeController.dispose();
    _participantNameController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final response = await LiveCourseAPI.joinCourse("", userId: _meetingCodeController.text, userName: _participantNameController.text);

      if (response.success && response.data != null) {
        widget.onMeetingJoined(response.data!['meeting'], response.data!['participant']);
      } else {
        widget.onError(response.error ?? 'Failed to join meeting');
      }
    } catch (error) {
      widget.onError(error.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🎯 Join Existing Meeting',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _meetingCodeController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Code',
                  hintText: 'Enter 6-digit meeting code',
                  border: OutlineInputBorder(),
                ),
                maxLength: 6,
                enabled: !loading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meeting code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _participantNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                enabled: !loading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: loading || _meetingCodeController.text.isEmpty
                    ? null
                    : handleSubmit,
                icon: Icon(loading ? Icons.hourglass_empty : Icons.rocket_launch),
                label: Text(loading ? 'Joining...' : 'Join Meeting'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}