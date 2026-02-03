import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
// Note: Ensure this import path matches your project structure
// import 'create_post_screen.dart'; 

class CommunityFeed extends StatelessWidget {
  final String filter;
  const CommunityFeed({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: Row(
          children: [
            const Text(
              "LAF",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search items...",
                    hintStyle: TextStyle(fontSize: 14),
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- HORIZONTAL CATEGORIES ---
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildCategoryChip("All", isSelected: true),
                _buildCategoryChip("Documents"),
                _buildCategoryChip("Electronics"),
                _buildCategoryChip("Wallets"),
                _buildCategoryChip("kKeys"),
                _buildCategoryChip("Pets"),
              ],
            ),
          ),
          
          // --- MAIN FEED ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.streamPosts(filter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final data = posts[index].data() as Map<String, dynamic>;
                    return _buildPostCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      );
      // --- FLOATING ACTION BUTTON ---
     
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    
    
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.deepPurple.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No posts yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "Be the first to help the community!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                data['imageUrl'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['title'] ?? 'No Title',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data['status'] == 'lost' ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (data['status'] ?? '').toUpperCase(),
                        style: TextStyle(
                          color: data['status'] == 'lost' ? Colors.red : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['description'] ?? '',
                  style: const TextStyle(color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data['createdAt'] != null
                          ? (data['createdAt'] as Timestamp).toDate().toString().substring(0, 10)
                          : '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


































// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/firestore_service.dart';

// class CommunityFeed extends StatelessWidget {
//   final String filter;
//   const CommunityFeed({super.key, required this.filter});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: const Color.fromARGB(255, 219, 216, 216),
//       elevation: 1,
//       titleSpacing: 16,
//       title: Row(
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.search, color: Colors.deepPurple),
//               SizedBox(width: 6),
//               Text(
//                 "LAF",
//                 style: TextStyle(
//                   color: Colors.deepPurple,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(width: 16),

//           Expanded(
//             child: Container(
//               height: 42,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: const TextField(
//                 decoration: InputDecoration(
//                   hintText: "Search for lost or found items...",
//                   border: InputBorder.none,
//                   icon: Icon(Icons.search),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(width: 16),

//           // ElevatedButton.icon(
//           //   onPressed: () {},
//           //   style: ElevatedButton.styleFrom(
//           //     backgroundColor: Colors.deepPurple,
//           //     shape: RoundedRectangleBorder(
//           //       borderRadius: BorderRadius.circular(24),
//           //     ),
//           //   ),
//           //   icon: const Icon(Icons.add, size: 18),
//           //   label: const Text("Create Post"),
//           // ),
//           IconButton(
//             icon: const Icon(Icons.notifications_none),
//             onPressed: () {},
//           ),

//           IconButton(icon: const Icon(Icons.person), onPressed: () {}),
//         ],
//       ),
//     );
//   }
// }


// // @override
// // Widget build(BuildContext context, String filter) {
// //   final service = FirestoreService();

// //   return StreamBuilder<QuerySnapshot>(
// //     stream: service.streamPosts(filter),
// //     builder: (context, snapshot) {
// //       if (snapshot.connectionState == ConnectionState.waiting) {
// //         return const Center(child: CircularProgressIndicator());
// //       }

// //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //         return const Center(child: Text("this is the icon for the new app"));
// //       }

// //       final posts = snapshot.data!.docs;

// //       return ListView.builder(
// //         padding: const EdgeInsets.all(12),
// //         itemCount: posts.length,
// //         itemBuilder: (context, index) {
// //           final data = posts[index].data() as Map<String, dynamic>;

// //           return Card(
// //             margin: const EdgeInsets.only(bottom: 12),
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 if (data['imageUrl'] != null)
// //                   ClipRRect(
// //                     borderRadius: const BorderRadius.vertical(
// //                       top: Radius.circular(16),
// //                     ),
// //                     child: Image.network(
// //                       data['imageUrl'],
// //                       height: 200,
// //                       width: double.infinity,
// //                       fit: BoxFit.cover,
// //                     ),
// //                   ),

// //                 Padding(
// //                   padding: const EdgeInsets.all(12),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         data['title'],
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),

// //                       const SizedBox(height: 6),

// //                       Text(data['description']),

// //                       const SizedBox(height: 8),

// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Chip(
// //                             label: Text(
// //                               data['status'].toUpperCase(),
// //                               style: const TextStyle(color: Colors.white),
// //                             ),
// //                             backgroundColor: data['status'] == 'lost'
// //                                 ? Colors.red
// //                                 : Colors.green,
// //                           ),

// //                           Text(
// //                             (data['createdAt'] as Timestamp)
// //                                 .toDate()
// //                                 .toString()
// //                                 .substring(0, 16),
// //                             style: const TextStyle(fontSize: 12),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       );
// //     },
// //   );
// // }
