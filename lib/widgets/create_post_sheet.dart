import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/create_post/create_post_screen.dart';

void showCreatePostSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text("Use Camera"),
          onTap: () => _pick(context, ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo),
          title: const Text("From Gallery"),
          onTap: () => _pick(context, ImageSource.gallery),
        ),
      ],
    ),
  );
}

Future<void> _pick(BuildContext context, ImageSource source) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: source);

  if (image != null) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(imagePath: image.path),
      ),
    );
  }
}
