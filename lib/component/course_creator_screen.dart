import 'package:api_demo/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseCreatorScreen extends StatefulWidget {
  const CourseCreatorScreen({super.key});

  @override
  _CourseCreatorScreenState createState() => _CourseCreatorScreenState();
}

class _CourseCreatorScreenState extends State<CourseCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorNameController = TextEditingController(text: 'Default Instructor');

  String _selectedCategory = 'beauty';
  int _duration = 60;
  bool _recordingEnabled = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'beauty',
    'makeup',
    'hair',
    'skincare',
    'nail',
    'other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<LiveCourseAPI>();
      final scheduledDateTime = DateTime.now().add(Duration(minutes: 1)).toIso8601String();

      final courseData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'instructorId': 'instructor_default',
        'instructorName': _instructorNameController.text.trim(),
        'category': _selectedCategory,
        'duration': _duration,
        'recordingEnabled': _recordingEnabled,
        'scheduledDateTime': scheduledDateTime,
        'enrolledUsers': <String>[],
      };

      final response = await LiveCourseAPI.createCourse( name:  _nameController.text.trim(), instructorId: 'instructor_default', instructorName: _instructorNameController.text.trim(), category: _selectedCategory, duration: _duration);

      if (response.success && response.data != null) {
        _showSuccess('Course created successfully!');
        _clearForm();
      } else {
        _showError(response.error ?? 'Failed to create course');
      }
    } catch (e) {
      _showError('Failed to create course: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _instructorNameController.text = 'Default Instructor';
    setState(() {
      _selectedCategory = 'beauty';
      _duration = 60;
      _recordingEnabled = true;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              '🎓 Create New Course',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                hintText: 'Enter course name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
              enabled: !_isLoading,
            ),

            SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter course description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _instructorNameController,
                    decoration: InputDecoration(
                      labelText: 'Instructor Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter instructor name';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category[0].toUpperCase() + category.substring(1)),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration: $_duration minutes'),
                      Slider(
                        value: _duration.toDouble(),
                        min: 15,
                        max: 240,
                        divisions: 15,
                        label: '$_duration min',
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _duration = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Enable Recording'),
                    subtitle: Text('(Host Screen Only)'),
                    value: _recordingEnabled,
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _recordingEnabled = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createCourse,
              icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.rocket_launch),
              label: Text(_isLoading ? 'Creating...' : 'Create Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}