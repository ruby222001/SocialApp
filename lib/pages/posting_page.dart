import 'package:app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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
  bool isLoading = false;

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
    if (textController.text.isNotEmpty && _selectedImage != null) {
      setState(() {
        isLoading = true; // Start loading
      });

      final ref = FirebaseFirestore.instance.collection("User Posts").doc();
      String? imageUrl;

      // Upload Image (if available)
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      // Add the post to Firestore
      await FirebaseFirestore.instance
          .collection("User Posts")
          .doc(ref.id)
          .set({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'ImageUrl': imageUrl ?? '',
      });

      setState(() {
        isLoading = false; // Stop loading
        textController.clear();
        _selectedImage = null;
      });

      // Navigate to HomePage
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

  Future<void> _pickCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        title: Text(
          'Post',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  maxLines: 5,
                  controller: textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Write something here...',
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.black),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.black),
                    onPressed: _pickCamera,
                  ),
                  isLoading
                      ? const SizedBox(
                          height:
                              24, // Set the size of the CircularProgressIndicator
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth:
                                2, // Make it smaller for better alignment
                            color: Colors.black,
                          ),
                        )
                      : IconButton(
                          onPressed: postMessage,
                          icon: const Icon(Icons.send, color: Colors.black),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
