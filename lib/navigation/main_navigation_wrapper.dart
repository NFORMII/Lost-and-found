import 'package:flutter/material.dart';
import '../screens/feeds/all_feed_screen.dart';
import '../screens/feeds/lost_feed_screen.dart';
import '../screens/feeds/found_feed_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/create_post_sheet.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() =>
      _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AllFeedScreen(),
          LostFeedScreen(),
          FoundFeedScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreatePostSheet(context),
        icon: const Icon(Icons.add_a_photo),
        label: const Text("Create Post"),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: "All"),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_off), label: "Lost"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: "Found"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
