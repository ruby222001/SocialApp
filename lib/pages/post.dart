import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialapp/components/components/comment.dart';
import 'package:socialapp/components/components/comment_button.dart';
import 'package:socialapp/components/like_button.dart';
import 'package:socialapp/helper/helper_functions.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String time;

  final String postId;
  final List<String> likes;
  final String? imageUrl;
  final String? userimageUrl;

  Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    this.imageUrl,
    this.userimageUrl,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;

  String? profileImageUrl;
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    _loadProfileImage();
  }

  // Toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  bool isLoading = true;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _loadProfileImage() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.user)
          .get();

      if (doc.exists) {
        setState(() {
          profileImageUrl = doc.data()?['profileImageUrl'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile image: $e");
    }
  }

  final _commentTextController = TextEditingController();
// Add a comment only if the text is not empty
  void addComment(String commentText) {
    if (commentText.trim().isEmpty) {
      return;
    }

    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

// Dialog for adding a comment
  void showcommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Enter comment"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              if (_commentTextController.text.trim().isNotEmpty) {
                _commentTextController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Post"),
          ),
          TextButton(
            onPressed: () {
              _commentTextController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
// user profile from profile page
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[700],
                child: widget.userimageUrl != null &&
                        widget.userimageUrl!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.userimageUrl!,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      )
                    : const Icon(Icons.person, size: 25, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.user,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Display selected image if present
          Image.network(
            widget.imageUrl!,
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              LikeButton(isLiked: isLiked, onTap: toggleLike),
              Text(
                widget.likes.length.toString(),
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      children: [
                        CommentButton(onTap: showcommentDialog),
                        const SizedBox(width: 5),
                        const Text(
                          "0",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }
                  final commentCount = snapshot.data!.docs.length;
                  return Row(
                    children: [
                      CommentButton(onTap: showcommentDialog),
                      const SizedBox(width: 5),
                      Text(
                        commentCount.toString(),
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    final commentData = doc.data() as Map<String, dynamic>;
                    return Comment(
                      text: commentData["CommentText"],
                      user: commentData["CommentedBy"],
                      time: formatData(commentData["CommentTime"]),
                    );
                  }).toList(),
                );
              })
        ],
      ),
    );
  }
}
