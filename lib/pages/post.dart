import 'package:app/components/components/comment.dart';
import 'package:app/components/components/comment_button.dart';
import 'package:app/components/like_button.dart';
import 'package:app/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String time;

  final String postId;
  final List<String> likes;
  final String? imageUrl;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    this.imageUrl,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
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

  final _commentTextController = TextEditingController();
//add a comment
  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

//dialog for comment
  void showcommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add comment"),
              content: TextField(
                  controller: _commentTextController,
                  decoration: const InputDecoration(hintText: "enter comment")),
              actions: [
                TextButton(
                    onPressed: () {
                      addComment(_commentTextController.text);
                      _commentTextController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Post")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _commentTextController.clear();
                    },
                    child: const Text("cancel"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          // Message and username
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.time),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Display selected image if present
          widget.imageUrl != null && widget.imageUrl!.isNotEmpty
              ? Image.network(
                  widget.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // The image has finished loading.
                    }
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200], // Placeholder background color
                      child: Center(
                        child: Image.asset(
                          'assets/images/zunun_logo.png', // Path to your default image
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200], // Background for failed image load
                    child: Center(
                      child: Image.asset(
                        'assets/images/zunun_logo.png', // Default image on error
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Image.asset(
                  'assets/images/zunun_logo.png', // Default image when URL is empty
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),

          SizedBox(
            height: 10,
          ),
          Text(widget.message),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              LikeButton(isLiked: isLiked, onTap: toggleLike),
              Text(widget.likes.length.toString()),
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
                        const Text("0"),
                      ],
                    );
                  }
                  final commentCount = snapshot.data!.docs.length;
                  return Row(
                    children: [
                      CommentButton(onTap: showcommentDialog),
                      const SizedBox(width: 5),
                      Text(commentCount.toString()),
                    ],
                  );
                },
              ),
            ],
          ),

          SizedBox(
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
