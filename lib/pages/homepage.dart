import 'dart:convert';
import 'dart:io';

import 'package:app/auth/services/notification_page.dart';
import 'package:app/components/components/drawer.dart';
import 'package:app/helper/helper_functions.dart';
import 'package:app/pages/post.dart';
import 'package:app/pages/posting_page.dart';
import 'package:app/pages/profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> cachedPosts =
      []; // Local list to store cached posts

  @override
  void initState() {
    super.initState();
    loadCachedPosts(); // Load posts from SharedPreferences when the app starts
  }

  // Load cached posts from SharedPreferences
  Future<void> loadCachedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? postsJson = prefs.getString('cached_posts');

    if (postsJson != null) {
      final List<dynamic> decodedPosts = jsonDecode(postsJson);
      setState(() {
        cachedPosts =
            decodedPosts.map((post) => post as Map<String, dynamic>).toList();
      });
    }
  }

  // Save posts to SharedPreferences
  Future<void> savePostsToCache(List<Map<String, dynamic>> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedPosts = jsonEncode(posts);
    await prefs.setString('cached_posts', encodedPosts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      drawer: MyDrawer(
        onProfileTap: () {
          goToProfilePage(context);
        },
        onSignout: signOut,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostingPage()),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        title: const Text(
          'M I N I M A L',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Convert Firestore data to a list of maps
                    final fetchedPosts = snapshot.data!.docs.map((doc) {
                      return {
                        "UserEmail": doc["UserEmail"],
                        "Message": doc["Message"],
                        "PostId": doc.id,
                        "Likes": List<String>.from(doc['Likes'] ?? []),
                        "TimeStamp": doc["TimeStamp"],
                        "ImageUrl": doc["ImageUrl"] ?? '',
                      };
                    }).toList();

                    // Save to cache
                    savePostsToCache(fetchedPosts);

                    return buildPostList(fetchedPosts);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Show cached posts if Firestore data is still loading
                  return buildPostList(cachedPosts);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Function to build the list of posts
  Widget buildPostList(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text("No posts available"));
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Post(
          user: post["UserEmail"],
          message: post["Message"],
          postId: post["PostId"],
          likes: List<String>.from(post['Likes'] ?? []),
          time: formatData(post["TimeStamp"]),
          imageUrl: post["ImageUrl"].isNotEmpty ? post["ImageUrl"] : null,
        );
      },
    );
  }

  void goToProfilePage(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
