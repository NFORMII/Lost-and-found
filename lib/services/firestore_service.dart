import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // 🔥 STREAM (you already use this)
  Stream<QuerySnapshot> streamPosts(String filter) {
    if (filter == 'all') {
      return _db
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }

    return _db
        .collection('posts')
        .where('status', isEqualTo: filter)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ➕ CREATE POST
  Future<void> createPost({
    required String title,
    required String description,
    required String status,
    String? imageUrl,
    required String postId,
    required File image,
    required String userId,
    required String category,
    required dynamic doc,
  }) async {
    final ref = 
              FirebaseStorage.instance.ref('pst_images/$postId.jpg');

    await ref.ptfile(image);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({'imageUrl': url});
    
    await _db.collection('posts').add({
      'title': title,
      'description': description,
      'status': status,
      'category': category.text.tolowercase(),
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': null
    });
    return doc.id;
  }
}

extension on String {
  get text => null;
}

class FirebaseStorage {
  static get instance => null;
}



















// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Stream<QuerySnapshot> getItems({String filter = 'all'}) {
//     Query query = _db.collection('items');
    
//     if (filter != 'all') {
//       query = query.where('status', isEqualTo: filter);
//     }
    
//     return query
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }

//   Future<void> addItem({
//     required String title,
//     required String description,
//     required String category,
//     required String imageUrl,
//   }) async {
//     await _db.collection('items').add({
//       'title': title,
//       'description': description,
//       'category': category,
//       'imageUrl': imageUrl,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   Stream<QuerySnapshot<Object?>>? streamPosts(String filter) {}
  
// }
