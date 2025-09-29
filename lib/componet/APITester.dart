import 'package:api_demo/servise/api_service.dart';
import 'package:api_demo/servise/socketService.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TestResult {
  final String test;
  final bool success;
  final dynamic data;
  final String? error;
  final DateTime timestamp;

  TestResult({
    required this.test,
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
  });
}

class APITester extends StatefulWidget {
  const APITester({super.key});

  @override
  _APITesterState createState() => _APITesterState();
}

class _APITesterState extends State<APITester> {
  final List<TestResult> _testResults = [];
  bool _testing = false;
  late SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
  }

  void _addResult(String test, bool success, {dynamic data, String? error}) {
    final result = TestResult(
      test: test,
      success: success,
      data: data,
      error: error,
      timestamp: DateTime.now(),
    );

    setState(() {
      _testResults.add(result);
    });
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  void _runAllTests() async {
    setState(() {
      _testing = true;
    });
    _clearResults();

    // Test 1: Health Check
    // try {
    //   // final healthResponse = await HealthCheckAPI.check();
    //   _addResult('Health Check', healthResponse.success,
    //       data: healthResponse.data, error: healthResponse.error);
    // } catch (error) {
    //   _addResult('Health Check', false, error: error.toString());
    // }

    // Test 2: Get All Live Courses
    try {
      final coursesResponse = await LiveCourseAPI.getAllCourses();
      _addResult('Get All Live Courses', coursesResponse.success,
          data: coursesResponse.data, error: coursesResponse.error);
    } catch (error) {
      _addResult('Get All Live Courses', false, error: error.toString());
    }

    // Test 3: Get Specific Live Course
    try {
      final courseResponse = await LiveCourseAPI.getCourseById('test123');
      _addResult('Get Live Course by ID', courseResponse.success,
          data: courseResponse.data, error: courseResponse.error);
    } catch (error) {
      _addResult('Get Live Course by ID', false, error: error.toString());
    }

    // Test 4: Start Live Course (creates meeting room)
    String testCourseId = 'test789';
    String meetingCode = '';

    try {
      final startResponse = await LiveCourseAPI.startCourse(testCourseId,  instructorName: 'API Test Instructor');

      if (startResponse.success &&
          startResponse.data != null &&
          startResponse.data['videoConferencing'] != null &&
          startResponse.data['videoConferencing']['meetingCode'] != null) {
        meetingCode = startResponse.data['videoConferencing']['meetingCode'];
        _addResult('Start Live Course', true, data: startResponse.data);
      } else {
        _addResult('Start Live Course', false, error: startResponse.error);
      }
    } catch (error) {
      _addResult('Start Live Course', false, error: error.toString());
    }

    // Test 5: Socket.IO Connection (if we have a meeting code)
    if (meetingCode.isNotEmpty) {
      try {
        await _socketService.connect();

        bool socketTestCompleted = false;
        bool chatMessageReceived = false;

        // Set up timeout
        Timer(const Duration(seconds: 5), () {
          if (!socketTestCompleted) {
            _addResult('Socket.IO Chat Test', false,
                error: 'Test timeout - no chat message received');
            socketTestCompleted = true;
          }
        });

        // Set up chat message listener
        _socketService.onChatMessage((message) {
          if (!chatMessageReceived && message.sender == 'API Test User') {
            chatMessageReceived = true;
            _addResult('Socket.IO Chat Test', true,
                data: {'message': message.message, 'timestamp': message.timestamp});
            socketTestCompleted = true;
          }
        });

        // Join the meeting room
        _socketService.joinMeetingRoom(meetingCode, 'API Test User', 'test_participant_123', false);

        // Send a test chat message after a short delay
        Timer(const Duration(milliseconds: 1500), () {
          _socketService.sendChatMessage(meetingCode, 'API Test User', 'Hello from API test!');
        });

        _addResult('Socket.IO Connection', true,
            data: {'meetingCode': meetingCode, 'status': 'Connected and joined meeting room'});
      } catch (error) {
        _addResult('Socket.IO Connection', false, error: error.toString());
      }
    }

    // Test 6: Complete Live Course (stops recording and ends meeting)
    Timer(const Duration(seconds: 6), () async {
      try {
        final completeResponse = await LiveCourseAPI.completeCourse(testCourseId);
        _addResult('Complete Live Course', completeResponse.success,
            data: completeResponse.data, error: completeResponse.error);
      } catch (error) {
        _addResult('Complete Live Course', false, error: error.toString());
      }

      setState(() {
        _testing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Tester',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Test all Beauty LMS Live Course APIs to ensure they work properly',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testing ? null : _runAllTests,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                    ),
                    child: _testing
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Running Tests...'),
                      ],
                    )
                        : const Text('Run All Tests'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _testing ? null : _clearResults,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Clear Results'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Test Results (${_testResults.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _testResults.isEmpty
                          ? const Center(
                        child: Text(
                          'No tests run yet. Click "Run All Tests" to start.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ListView.builder(
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final result = _testResults[index];
                          return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: result.success ? Colors.green : Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExpansionTile(
                              leading: Icon(
                                result.success ? Icons.check_circle : Icons.error,
                                color: result.success ? Colors.green : Colors.red,
                              ),
                              title: Text(result.test),
                              subtitle: Text(
                                '${result.timestamp.hour.toString().padLeft(2, '0')}:'
                                    '${result.timestamp.minute.toString().padLeft(2, '0')}:'
                                    '${result.timestamp.second.toString().padLeft(2, '0')}',
                              ),
                              children: [
                                if (result.data != null)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Data:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            result.data.toString(),
                                            style: const TextStyle(fontFamily: 'monospace'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (result.error != null)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Error:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          result.error!,
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}