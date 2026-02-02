import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'post_card.dart';

class CommunityFeed extends StatelessWidget {
  final String filter;
  const CommunityFeed({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final posts = PostService.getPosts(filter);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (_, i) => PostCard(post: posts[i]),
        ),
      ),
    );
  }
}
