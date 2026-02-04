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

  // Load notification toggle from SharedPreferences
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

  // Load profile photo from Firestore
  Future<void> _loadProfilePhoto() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();

    setState(() {
      _photoUrl = doc.data()?['photoUrl'] as String?;
    });
  }

  // Pick image from gallery and upload to Firebase Storage
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref('profile_photos/${_user.uid}.jpg');

    // Upload file
    await ref.putFile(file);

    // Get download URL
    final url = await ref.getDownloadURL();

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .update({'photoUrl': url});

    // Update state to refresh UI
    setState(() => _photoUrl = url);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  get route => null;

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "This action is permanent. All your data will be deleted."),
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
      // Delete Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .delete();

      // Delete profile photo in storage
      await FirebaseStorage.instance
          .ref('profile_photos/${_user.uid}.jpg')
          .delete()
          .catchError((_) {});

      // Delete Firebase Auth user
      await _user.delete();

      if (!mounted) return;
      Navigator.of(context).popUntil((route).isFirst);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please re-login before deleting your account.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
      future:
          FirebaseFirestore.instance.collection('users').doc(_user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('User data not found'),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final name = data['name'] ?? 'Anonymous';
        final email = data['email'] ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child: _photoUrl == null
                        ? const Icon(Icons.camera_alt,
                            size: 30, color: Colors.deepPurple)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
                child: const Text("Edit Profile",
                    style: TextStyle(color: Colors.white)),
              ),
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
        children: [
          _buildTile(
            icon: Icons.article_outlined,
            title: "My Posts",
            onTap: () {
              Navigator.pushNamed(context, '/my-posts');
            },
          ),
          _buildNotificationTile(),
          _buildTile(
            icon: Icons.logout,
            title: "Logout",
            onTap: _logout,
          ),
          const SizedBox(height: 16),
          _buildTile(
            icon: Icons.delete_forever,
            title: "Delete Account",
            onTap: _deleteAccount,
            danger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
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
                color: danger ? Colors.red : Colors.black,
                fontWeight: FontWeight.w500)),
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
        onChanged: (value) {
          _toggleNotifications(value);
        },
      ),
    );
  }
}
