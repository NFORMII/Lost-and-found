import 'package:flutter/material.dart';


class Appbar extends StatelessWidget {
  const Appbar({super.key});

@override
Widget build(BuildContext context) {
  return PreferredSize(
  preferredSize: const Size.fromHeight(70),
  child: AppBar(
    backgroundColor: Colors.white,
    elevation: 1,
    titleSpacing: 16,
    title: Row(
      children: [
        // Logo / App name
        Row(
          children: const [
            Icon(Icons.search, color: Colors.deepPurple),
            SizedBox(width: 6),
            Text(
              "laf",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // Search bar
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

        // Create Post Button
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

        const SizedBox(width: 8),

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
  ),
);
  }
}