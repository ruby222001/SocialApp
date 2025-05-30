// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialapp/pages/image.dart';
import 'package:socialapp/pages/posting_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController bioController = TextEditingController();

  String? profileImageUrl;
  String? bio;
  bool isLoading = true;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userDoc =
          await firestore.collection('Users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        profileImageUrl = data?['profileImageUrl'];
        bio = data?['bio'];
        bioController.text = bio ?? '';
      }
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isUploadingImage = true;
      });
      try {
        final file = File(pickedFile.path);
        final ref = FirebaseStorage.instance
            .ref('profile_images/${currentUser.uid}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await firestore.collection('Users').doc(currentUser.uid).set(
          {'profileImageUrl': url},
          SetOptions(merge: true),
        );

        setState(() {
          profileImageUrl = url;
          isUploadingImage = false;
        });
      } catch (e) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _showBioDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Bio'),
          content: TextField(
            controller: bioController,
            decoration: const InputDecoration(
              hintText: 'Enter your bio',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedBio = bioController.text.trim();
                if (updatedBio == bio) {
                  Navigator.pop(context);
                  return;
                }

                await firestore.collection('Users').doc(currentUser.uid).set(
                  {'bio': updatedBio},
                  SetOptions(merge: true),
                );
                setState(() {
                  bio = updatedBio;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bio updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(String postId, String imageUrl) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        // Delete post from Firestore
        await FirebaseFirestore.instance
            .collection('User Posts')
            .doc(postId)
            .delete();

        // Delete image from Firebase Storage if exists
        if (imageUrl.isNotEmpty) {
          final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post.')),
        );
      }
    }
  }

  // void _showDeleteConfirmationDialog(String postId, String imageUrl) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: const Text("Delete Post"),
  //         content: const Text("Are you sure you want to delete this post?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _deletePost(postId, imageUrl);
  //             },
  //             child: const Text("Delete"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostingPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
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
              GestureDetector(
                onTap: _updateProfilePicture,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: profileImageUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    if (isUploadingImage)
                      const CircularProgressIndicator()
                    else
                      const Icon(Icons.camera_alt, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                currentUser.email!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 20),
              if (bio != null && bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    bio!,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                  foregroundColor: MaterialStateProperty.all(Colors.white), // T
                ),
                onPressed: _showBioDialog,
                child: const Text('Update Bio'),
              ),
              const SizedBox(height: 20),
              const Text('Your Posts',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey,
                  height: 20,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User Posts')
                      .where('UserEmail', isEqualTo: currentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No posts yet.',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    final posts = snapshot.data!.docs;
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final imageUrl = post['ImageUrl'];
                        final caption = post['Message'];
                        final postId = post.id;

                        return GestureDetector(
                          onTap: () {
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImageViewerPage(imageUrl: imageUrl),
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 4,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    imageUrl != null && imageUrl.isNotEmpty
                                        ? AspectRatio(
                                            aspectRatio:
                                                4 / 3, // Adjust as needed
                                            child: imageUrl != null &&
                                                    imageUrl.isNotEmpty
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey),
                                          )
                                        : const Icon(Icons.image_not_supported,
                                            size: 100, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        caption ?? '',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: -7,
                                  top: -4,
                                  child: PopupMenuButton<String>(
                                    color: Colors.white,
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deletePost(postId, imageUrl);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
