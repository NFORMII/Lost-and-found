import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(radius: 40),
                SizedBox(height: 12),
                Text("name",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("email"),
              ],
            ),
          ),
        ),
      );
      
  }
}
