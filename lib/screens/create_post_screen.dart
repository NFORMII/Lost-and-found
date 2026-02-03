import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  final String imagePath; // Passed from the image picker
  const CreatePostScreen({super.key, required this.imagePath});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // Matching your controllers from the existing UI
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String _selectedCategory = 'ELECTRONICS';
  bool _isUploading = false;

  // Integrated logic: ploads image to Storage, then metadata to Firestore
  Future<void> _uploadPost() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload to Firebase Storage
      //use File(widget.imagePath) because it's a local path from the pickRer
      File imageFile = File(widget.imagePath);
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Accessing FirebaseStorage instance directly
      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref(fileName)
          .putFile(imageFile);
      
      String downloadUrl = await uploadTask.ref.getDownloadURL();

      // 2. Save to Firestore
      // Setting status to 'lost' ensures it appears in 'All' and 'Lost' feeds
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategory.toLowerCase(),
        'imageUrl': downloadUrl,
        'status': 'lost', // Defaulting to lost as requested
        'createdAt': FieldValue.serverTimestamp(),
        'seenAt': DateTime.now(),
        'userId': 'demo-user', // replace this with actual Auth UID later
      });

      if (mounted) {
        Navigator.pop(context); // Return to feed
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        // This catches the 'getInstance' error if Firebase isn't ready
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: Check Firebase initialization")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
    

  @override
void initState() {
  super.initState();
  _loadDraft(); // Load saved text when screen opens
  
  // Save text to SharedPreferences as the user types
  _titleCtrl.addListener(_saveDraft);
  _descCtrl.addListener(_saveDraft);
}

Future<void> _loadDraft() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _titleCtrl.text = prefs.getString('draft_title') ?? '';
    _descCtrl.text = prefs.getString('draft_desc') ?? '';
  });
}

Future<void> _saveDraft() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('draft_title', _titleCtrl.text);
  await prefs.setString('draft_desc', _descCtrl.text);
}

// Clear draft after a SUCCESSFUL upload
Future<void> _clearDraft() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('draft_title');
  await prefs.remove('draft_desc');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Describe the item')),
      body: _isUploading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Local Image Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(widget.imagePath), height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'What did you find/lose?', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (color, brand, location...)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['ELECTRONICS', 'DOCUMENTS', 'PETS', 'OTHERS']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('SUBMIT POST', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }
}