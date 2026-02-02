import 'package:flutter/material.dart';
import 'package:letsfind/widgets/appbar.dart';
import '../../widgets/community_feed.dart';

class AllFeedScreen extends StatelessWidget {
  const AllFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunityFeed(filter: 'all');
  }
  }


class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 16,
      title: Row(
        children: [
          Row(
            children: const [
              Icon(Icons.search, color: Colors.deepPurple),
              SizedBox(width: 6),
              Text(
                "LAF",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search for lost or found items...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Create Post"),
          ),

          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

