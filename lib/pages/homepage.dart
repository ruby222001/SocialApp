import 'dart:io';

import 'package:app/components/components/drawer.dart';
import 'package:app/helper/helper_functions.dart';
import 'package:app/pages/post.dart';
import 'package:app/pages/posting_page.dart';
import 'package:app/pages/profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _selectedImage;

  final _picker = ImagePicker();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = basename(imageFile.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('post_images/$fileName');

      // Upload image to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the download URL for the uploaded image
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      return ''; // Return empty string if upload fails
    }
  }

  Future<String> getImageUrl(String filePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      final url =
          await storageRef.getDownloadURL(); // Get the valid download URL
      return url;
    } catch (e) {
      print("Error fetching image URL: $e");
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
    } else {
      // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      //   SnackBar(content: Text("Please enter text or select an image")),
      // );
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

  void goToProfilePage() {
    Navigator.pop(context as BuildContext);
    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        backgroundColor: Colors.blue.shade100,
        drawer: MyDrawer(
          onProfileTap: goToProfilePage,
          onSignout: signOut,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostingPage()),
            );
          },
        ),
        appBar: AppBar(
          title: const Text(
            'M I N I M A L',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              // Display posts from Firestore
              Expanded(
                  child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return Post(
                          user: post["UserEmail"],
                          message: post["Message"],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatData(post["TimeStamp"]),
                          imageUrl:
                              post["ImageUrl"] != '' ? post["ImageUrl"] : null,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
