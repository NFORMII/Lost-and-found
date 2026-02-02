import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../utils/date_utils.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(post.description),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(post.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text("Seen: ${formatDate(post.seenAt)}",
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text("Uploaded: ${formatDate(post.uploadedAt)}",
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            if (post.reunitedAt != null)
              Text("Reunited: ${formatDate(post.reunitedAt!)}",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.message_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => Share.share("Lost item: ${post.title}"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
