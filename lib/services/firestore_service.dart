import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getItems({String filter = 'all'}) {
    Query query = _db.collection('items');
    
    if (filter != 'all') {
      query = query.where('status', isEqualTo: filter);
    }
    
    return query
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addItem({
    required String title,
    required String description,
    required String category,
    required String imageUrl,
  }) async {
    await _db.collection('items').add({
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Object?>>? streamPosts(String filter) {}
  
}
