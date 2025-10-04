import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/course_list_screen.dart';
import 'screens/meeting_screen.dart';

void main() {
  runApp(const BeautyLMSApp());
}

class BeautyLMSApp extends StatelessWidget {
  const BeautyLMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Beauty LMS',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          primaryColor: Colors.pink.shade400,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink.shade400,
            brightness: Brightness.light,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.pink.shade400,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/courses': (context) => const CourseListScreen(),
          '/meeting': (context) => const MeetingScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}