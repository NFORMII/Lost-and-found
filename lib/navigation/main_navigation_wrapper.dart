import 'package:flutter/material.dart';
import 'package:letsfind/screens/feeds/messages_screen.dart';
import 'package:letsfind/widgets/community_feed.dart';
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
          // AllFeedScreen(),
          // LostFeedScreen(),
          // FoundFeedScreen(),
          CommunityFeed (filter: 'filter',),
          MessagesScreen()
        
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
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.location_off), label: "Lost"),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.check_circle), label: "Found"),
          BottomNavigationBarItem(
              icon: Icon(Icons.message), label: "Messages"),
        ],
      ),
    );
  }
}
