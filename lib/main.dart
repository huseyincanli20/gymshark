import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/workout_tracker_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/progress_screen.dart';
import 'models/user_profile.dart';
import 'theme/app_theme.dart';

import 'services/exercise_repository.dart';
import 'services/food_repository.dart';
import 'services/routine_repository.dart';
import 'utils/app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
  await ExerciseRepository.instance.init();
  await FoodRepository.instance.init();
  await RoutineRepository.instance.init();
  runApp(const GymTrackApp());
}

class GymTrackApp extends StatelessWidget {
  const GymTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserSession.current,
      builder: (context, _) {
        return MaterialApp(
          title: 'GymTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getDarkTheme(UserSession.current.themeKey),
          home: const MainNavigationScreen(),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserSession.current,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomeScreen(),
              WorkoutTrackerScreen(),
              NutritionScreen(),
              ProgressScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                label: AppLocale.get('nav_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center_rounded),
                label: AppLocale.get('nav_workout'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.restaurant_rounded),
                label: AppLocale.get('nav_nutrition'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.insights_rounded),
                label: AppLocale.get('nav_progress'),
              ),
            ],
          ),
        );
      },
    );
  }
}
