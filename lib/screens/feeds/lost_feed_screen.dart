import 'package:flutter/material.dart';
import '../../widgets/community_feed.dart';

class LostFeedScreen extends StatelessWidget {
  const LostFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunityFeed(filter: 'lost');
  }
}
