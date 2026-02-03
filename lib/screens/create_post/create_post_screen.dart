import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../auth/login_screen.dart';

class CreatePostScreen extends StatefulWidget {
  final String imagePath;

  const CreatePostScreen({super.key, required this.imagePath});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String selectedCategory = "electronics";
  bool isUploading = false;

  /// 🔐 Auth gate before upload
  void _handleSubmit() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSignupRequiredDialog();
    } else {
      _uploadPost(user.uid);
    }
  }

  /// 🪟 Popup asking user to sign up
  void _showSignupRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign up required"),
        content: const Text(
          "Please sign up or log in to upload an item.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Sign up / Login"),
          ),
        ],
      ),
    );
  }

  /// 🚀 Upload image to Cloudinary
  Future<String?> _uploadToCloudinary(File file) async {
    const cloudName = "dhuqoz85q";
    const uploadPreset = "";

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(resBody);
      return data['secure_url']; // This is the image URL
    } else {
      debugPrint("Cloudinary upload failed: $resBody");
      return null;
    }
  }

  /// 🚀 Actual upload logic (only runs if logged in)
  Future<void> _uploadPost(String userId) async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      // 1️⃣ Upload to Cloudinary
      final File imageFile = File(widget.imagePath);
      final imageUrl = await _uploadToCloudinary(imageFile);

      if (imageUrl == null) {
        throw "Image upload failed!";
      }

      // 2️⃣ Save post to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'category': selectedCategory,
        'imageUrl': imageUrl,
        'userId': userId,
        'status': 'lost',
        'createdAt': FieldValue.serverTimestamp(),
        'seenAt': DateTime.now(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Describe the item")),
      body: isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "What did you find/lose?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description (color, brand, location...)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: const ["electronics", "documents", "pets", "others"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "SUBMIT POST",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
