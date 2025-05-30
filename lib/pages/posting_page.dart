// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:socialapp/pages/homepage.dart'; // Alias to avoid conflicts

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
        'UserUID': FirebaseAuth.instance.currentUser!.uid,
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
          builder: (BuildContext context) => const HomePage(),
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          'Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/download.jpg",
                  ), // Your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
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
                ),
                const SizedBox(
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
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white),
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
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            onPressed: postMessage,
                            icon: const Icon(Icons.send, color: Colors.white),
                          ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
