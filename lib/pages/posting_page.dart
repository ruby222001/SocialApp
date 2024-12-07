import 'package:app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:app/pages/profilepage.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // Alias to avoid conflicts

class PostingPage extends StatefulWidget {
  const PostingPage({super.key});

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _selectedImage;

  final _picker = ImagePicker();

  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = p.basename(imageFile.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('post_images/$fileName');

      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      return '';
    }
  }

  void postMessage() async {
    if (textController.text.isNotEmpty || _selectedImage != null) {
      final ref = FirebaseFirestore.instance.collection("User Posts").doc();

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      FirebaseFirestore.instance.collection("User Posts").doc(ref.id).set({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'ImageUrl': imageUrl ?? '',
      });

      setState(() {
        textController.clear();
        _selectedImage = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter text or select an image")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Write something here...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.black),
                  onPressed: _pickImage,
                ),
                IconButton(
                  onPressed: postMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
