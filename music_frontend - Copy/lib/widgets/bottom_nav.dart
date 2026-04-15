import 'package:flutter/material.dart';
import '../models/user_model.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final User? user;
  final Function(int) onTabChange;
  final VoidCallback onProfileTap;

  const BottomNav({
    super.key,
    required this.index,
    this.user,
    required this.onTabChange,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        if (i == 3) {
          // Profile tab
          onProfileTap();
        } else {
          onTabChange(i);
        }
      },
      backgroundColor: Colors.black,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Liked"),
        BottomNavigationBarItem(
          icon: user != null
              ? CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(user!.profilePic),
                )
              : const Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}