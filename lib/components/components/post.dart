import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PostingField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Function(File? image)
      onImagePicked; // Callback to pass the picked image

  const PostingField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.onImagePicked,
  });

  @override
  State<PostingField> createState() => _PostingFieldState();
}

class _PostingFieldState extends State<PostingField> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget
          .onImagePicked(_selectedImage); // Pass the picked image to the parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.image),
          onPressed: _pickImage, // Handle image picking
        ),
      ),
      obscureText: widget.obscureText,
    );
  }
}
