import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/workout_tracker_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/progress_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GymTrackApp());
}

class GymTrackApp extends StatelessWidget {
  const GymTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutTrackerScreen(),
    NutritionScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Antrenman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Beslenme',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'İlerleme',
          ),
        ],
      ),
    );
  }
}
