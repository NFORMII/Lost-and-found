// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SIGN UP
  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LOGIN
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // DELETE ACCOUNT
  Future<void> deleteUser() async {
    final user = _auth.currentUser!;
    await _db.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
