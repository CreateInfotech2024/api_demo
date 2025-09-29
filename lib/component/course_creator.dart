import 'package:api_demo/model/api_response.dart';
import 'package:api_demo/service/api_service.dart';
import 'package:flutter/material.dart';

class CourseCreator extends StatefulWidget {
  final Function(LiveCourse course) onCourseCreated;
  final Function(String error) onError;

  const CourseCreator({
    super.key,
    required this.onCourseCreated,
    required this.onError,
  });

  @override
  State<CourseCreator> createState() => _CourseCreatorState();
}

class _CourseCreatorState extends State<CourseCreator> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorNameController = TextEditingController(text: 'Default Instructor');

  String category = 'beauty';
  int duration = 60;
  bool recordingEnabled = true;
  bool loading = false;

  final List<String> categories = [
    'beauty',
    'makeup',
    'hair',
    'skincare',
    'nail',
    'other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final scheduledDateTime = DateTime.now().add(const Duration(minutes: 1)).toIso8601String();

      final courseData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'instructorId': 'instructor_default',
        'instructorName': _instructorNameController.text,
        'category': category,
        'duration': duration,
        'recordingEnabled': recordingEnabled,
        'scheduledDateTime': scheduledDateTime,
        'enrolledUsers': <String>[],
      };

      final response = await LiveCourseAPI.createCourse( name: _nameController.text, instructorId: "instructor_default", instructorName: _instructorNameController.text, category: category, duration: duration);

      if (response.success && response.data != null) {
        widget.onCourseCreated(response.data!);
        // Reset form
        _nameController.clear();
        _descriptionController.clear();
        _instructorNameController.text = 'Default Instructor';
        setState(() {
          category = 'beauty';
          duration = 60;
          recordingEnabled = true;
        });
      } else {
        widget.onError(response.error ?? 'Failed to create course');
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
                '🎓 Create New Course',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'Enter course name',
                  border: OutlineInputBorder(),
                ),
                enabled: !loading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter course description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !loading,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _instructorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Instructor Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !loading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter instructor name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.substring(0, 1).toUpperCase() + cat.substring(1)),
                      )).toList(),
                      onChanged: loading ? null : (value) {
                        setState(() {
                          category = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: duration.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !loading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        final dur = int.tryParse(value);
                        if (dur == null || dur < 15 || dur > 240) {
                          return 'Duration must be between 15-240 minutes';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final dur = int.tryParse(value);
                        if (dur != null) {
                          duration = dur;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Enable Recording\n(Host Screen Only)'),
                      value: recordingEnabled,
                      onChanged: loading ? null : (value) {
                        setState(() {
                          recordingEnabled = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: loading || _nameController.text.trim().isEmpty
                    ? null
                    : handleSubmit,
                icon: Icon(loading ? Icons.hourglass_empty : Icons.rocket_launch),
                label: Text(loading ? 'Creating...' : 'Create Course'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
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