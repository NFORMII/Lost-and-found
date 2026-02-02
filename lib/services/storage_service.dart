import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file) async {
    final String fileName =
        DateTime.now().millisecondsSinceEpoch.toString();

    final ref = _storage.ref().child('items/$fileName.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String?> uploadPostImage(File file) async {}
}
