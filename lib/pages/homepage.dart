import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/components/components/drawer.dart';
import 'package:socialapp/helper/helper_functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialapp/pages/post.dart';
import 'package:socialapp/pages/posting_page.dart';
import 'package:socialapp/pages/profilepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> cachedPosts =
      []; // Local list to store cached posts

  Map<String, String> userProfilePics = {}; // uid -> profileImageUrl

  @override
  void initState() {
    super.initState();
    loadCachedPosts();
    loadAllUserProfiles(); // Load all user profiles at start
  }

  Future<void> loadAllUserProfiles() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    final Map<String, String> profiles = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      profiles[doc.id] = data['profileImageUrl'] ?? '';
    }
    setState(() {
      userProfilePics = profiles;
    });
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
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          'S O C I A L',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              String currentUID = currentUser.uid;
              String? profileUrl = userProfilePics[currentUID];

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[700],
                    child: profileUrl != null && profileUrl.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profileUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                      strokeWidth: 2),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : const Icon(Icons.person,
                            size: 20, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
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
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .orderBy("TimeStamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final fetchedPosts = snapshot.data!.docs.map((doc) {
                          final data = doc.data();
                          final uid = data["UserUID"] ?? '';
                          return {
                            "UserEmail": data["UserEmail"] ?? '',
                            "Message": data["Message"] ?? '',
                            "PostId": doc.id,
                            "Likes": List<String>.from(data['Likes'] ?? []),
                            "TimeStamp": data["TimeStamp"] ?? '',
                            "ImageUrl": data["ImageUrl"] ?? '',
                            "UserUID": uid,
                            "UserProfilePic": userProfilePics[uid] ??
                                '', // Use latest profile pic from map
                          };
                        }).toList();

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
          ],
        ),
      ),
    );
  }

  // Function to build the list of posts
  Widget buildPostList(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return Scaffold(
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
            const Center(child: Text("No posts available")),
          ],
        ),
      );
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
          imageUrl: post["ImageUrl"],
          userimageUrl:
              post["UserProfilePic"], // use dynamic user profile pic here
        );
      },
    );
  }

  void goToProfilePage(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ProfilePage(); // The page you want to navigate to
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Starting point (from right)
          const end = Offset.zero; // Ending point (to center)
          const curve = Curves.easeInOut; // Transition curve

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
              position: offsetAnimation,
              child: child); // Slide transition from right to left
        },
      ),
    );
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
