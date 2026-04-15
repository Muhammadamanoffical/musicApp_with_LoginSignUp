import 'package:flutter/material.dart';
import 'screens/auth/login_signup_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/player_screen.dart';
import 'widgets/bottom_nav.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomeWrapper(),
        '/login': (context) => const LoginSignupScreen(),
      },
    );
  }
}

// 🔐 AUTH WRAPPER - Check if user is logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const HomeWrapper();
        } else {
          return const LoginSignupScreen();
        }
      },
    );
  }
}

// 🏠 HOME WRAPPER - Main app with bottom nav
class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int index = 0;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() => currentUser = user);
  }

  final screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: BottomNav(
        index: index,
        user: currentUser,
        onTabChange: (i) => setState(() => index = i),
        onProfileTap: () {
          if (currentUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(user: currentUser!),
              ),
            );
          }
        },
      ),
    );
  }
}