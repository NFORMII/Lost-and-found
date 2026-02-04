import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../auth/login_screen.dart';

class CreatePostScreen extends StatefulWidget {
  final String? imagePath; // 👈 image is OPTIONAL

  const CreatePostScreen({super.key, this.imagePath});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final category = TextEditingController();

  String selectedCategory = "electronics";
  bool isUploading = false;

  void _handleSubmit() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSignupRequiredDialog();
    } else {
      _createPost(user.uid);
    }
  }

  void _showSignupRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign up required"),
        content: const Text("Please sign up or log in to upload an item."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Sign up / Login"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Upload image to Cloudinary (optional)
  Future<String?> _uploadToCloudinary(File file) async {
    const cloudName = "dhuqoz85q";
    const uploadPreset = ""; // <-- must exist in Cloudinary

    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body)['secure_url'];
    }
    return null;
  }

  /// NEW: Create Firestore post FIRST
  Future<void> _createPost(String userId) async {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      // 1️⃣ Create Firestore post immediately
      final docRef =
          await FirebaseFirestore.instance.collection('posts').add({
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'category': selectedCategory,
        'imageUrl': null, // +placeholder
        'userId': userId,
        'status': 'found',
        'createdAt': FieldValue.serverTimestamp(),
      });

    // 2Upload image ONLY if user selected one
      if (widget.imagePath != null) {
        final imageFile = File(widget.imagePath!);
        final imageUrl = await _uploadToCloudinary(imageFile);

        if (imageUrl != null) {
          await docRef.update({'imageUrl': imageUrl});
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
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
                  if (widget.imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "What did you find?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: category,
                    decoration: const InputDecoration(labelText: 'Category(documents, electronics, wallets, keys, pets)')
                  ),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration
                    
                    (
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: const [
                      "electronics",
                      "documents",
                      'Wallets'
                      "pets",
                      "others"
                    ]
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c.toUpperCase())))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedCategory = val!),
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
                        backgroundColor: const Color.fromARGB(255, 197, 192, 205),
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
