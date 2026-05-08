import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'meal_tracking_screen.dart';
import 'fitness_plan_screen.dart';
import 'profile_screen.dart';
import 'app_data.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  /// The date (year/month/day) when meals were last loaded.
  late DateTime _lastLoadedDate;

  @override
  void initState() {
    super.initState();
    _lastLoadedDate = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the app comes back to the foreground (e.g. user
  /// switches back to the app after midnight).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDayRollover();
    }
  }

  /// If the calendar day has changed since we last loaded meals,
  /// clear the in-memory list and reload today's meals from Firestore.
  void _checkDayRollover() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final loaded = DateTime(
        _lastLoadedDate.year, _lastLoadedDate.month, _lastLoadedDate.day);

    if (today.isAfter(loaded)) {
      _lastLoadedDate = now;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AppData.loadTodaysMeals(user.uid);
      } else {
        // no user logged in — just clear meals
        AppData.meals.value = [];
      }
    }
  }

  List<Widget> get _screens => [
    DashboardScreen(
        onNavigate: (index) => setState(() => _currentIndex = index)),
    const MealTrackingScreen(),
    const FitnessPlanScreen(),
    const ProfileScreen(),
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
          // check for day rollover every time the user taps a tab
          _checkDayRollover();
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF378ADD),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_rounded),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}