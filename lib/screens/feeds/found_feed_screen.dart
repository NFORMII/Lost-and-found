import 'package:flutter/material.dart';
import 'all_feed_screen.dart';
import '../../widgets/community_feed.dart';

class FoundFeedScreen extends StatelessWidget {
  const FoundFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunityFeed(filter: 'found');
  }
}

// @overide 

// Widget build(BuildContext){
//   return const Scaffold(
//     appBar: CustomAppBar(),
//     floatingActionButton: AboutDialog(
    
//     ),


//   );



// }
