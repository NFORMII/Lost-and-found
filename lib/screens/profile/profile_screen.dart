import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  final User _user = FirebaseAuth.instance.currentUser!;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadProfilePhoto();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _loadProfilePhoto() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();

    setState(() {
      _photoUrl = doc.data()?['photoUrl'];
    });
  }

  // 📸 PROFILE PHOTO UPLOAD
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance
        .ref('profile_photos/${_user.uid}.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .update({'photoUrl': url});

    setState(() => _photoUrl = url);
  }

  // 🔓 LOGOUT
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ❌ DELETE ACCOUNT (FULL)
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "This will permanently delete your account and all your data. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete Firestore profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .delete();

      // Delete profile photo
      await FirebaseStorage.instance
          .ref('profile_photos/${_user.uid}.jpg')
          .delete()
          .catchError((_) {});

      // Delete Auth user
      await _user.delete();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Re-login required before deleting account.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildActionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 80),
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Anonymous';
        final email = data['email'] ?? '';

        return Container(
          padding: const EdgeInsets.only(top: 60, bottom: 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFEDE7F6),
                  backgroundImage:
                      _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  child: _photoUrl == null
                      ? const Icon(Icons.camera_alt,
                          size: 32, color: Colors.deepPurple)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Settings",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          const SizedBox(height: 12),
          _buildNotificationTile(),
          _buildProfileTile(
            icon: Icons.logout,
            title: "Logout",
            onTap: _logout,
          ),
          _buildProfileTile(
            icon: Icons.delete_forever,
            title: "Delete Account",
            onTap: _deleteAccount,
            danger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: danger ? Colors.red : Colors.deepPurple),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: danger ? Colors.red : Colors.black)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined,
            color: Colors.deepPurple),
        title: const Text("Push Notifications"),
        value: _notificationsEnabled,
        activeColor: Colors.deepPurple,
        onChanged: _toggleNotifications,
      ),
    );
  }
}
