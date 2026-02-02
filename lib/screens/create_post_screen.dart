import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _status = 'lost';
  File? _image;
  bool _loading = false;

  final _firestore = FirestoreService();
  final _storage = StorageService();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;

    setState(() => _loading = true);

    String? imageUrl;

    if (_image != null) {
      imageUrl = await _storage.uploadPostImage(_image!);
    }

    await _firestore.createPost(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: _status,
      imageUrl: imageUrl,
      userId: 'demo-user', // replace with FirebaseAuth uid
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'lost', child: Text('Lost')),
                DropdownMenuItem(value: 'found', child: Text('Found')),
              ],
              onChanged: (v) => setState(() => _status = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),

            const SizedBox(height: 16),

            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 180),
              ),

            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
