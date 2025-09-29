import 'package:api_demo/component/course_creator_screen.dart';
import 'package:api_demo/component/live_courses_screen.dart';
import 'package:api_demo/service/WebRTCService.dart';
import 'package:api_demo/service/socketService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Cleanup services
    context.read<SocketService>().disconnect();
    context.read<WebRTCService>().cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎓 Beauty LMS Live Courses'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.video_call), text: 'Live Courses'),
            Tab(icon: Icon(Icons.add_circle), text: 'Create Course'),
            // Tab(icon: Icon(Icons.bug_report), text: 'API Tester'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LiveCoursesScreen(),
          CourseCreatorScreen(),
          // ApiTesterScreen(),
        ],
      ),
    );
  }
}