import 'package:api_demo/componet/homescreen.dart';
import 'package:api_demo/servise/WebRTCService.dart';
import 'package:api_demo/servise/api_service.dart';
import 'package:api_demo/servise/socketService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 9308

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LiveCourseAPI>(create: (_) => LiveCourseAPI()),
        Provider<SocketService>(create: (_) => SocketService()),
        Provider<WebRTCService>(create: (_) => WebRTCService()),
      ],
      child: MaterialApp(
        title: 'Beauty LMS Live Courses',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}