import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  final String imagePath;
  const CreatePostScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(imagePath, height: 200),
            TextField(decoration: const InputDecoration(labelText: "Title")),
            TextField(decoration: const InputDecoration(labelText: "Description")),
            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "documents", child: Text("Documents")),
                DropdownMenuItem(value: "electronics", child: Text("Electronics")),
                DropdownMenuItem(value: "pets", child: Text("Pets")),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Upload"),
            )
          ],
        ),
      ),
    );
  }
}
