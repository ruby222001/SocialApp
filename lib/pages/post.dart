import 'package:app/components/like_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String>likes;
  const Post({
     required this.message, required this.user, required this.postId, required this.likes, });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked =false;

  @override
  void initState(){
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike(){
    setState(() {
      isLiked=!isLiked;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8),),
      margin: EdgeInsets.only(top: 25,left: 25,right: 25),
      padding: EdgeInsets.all(25),
      
      child: Row(
        children: [
          //like
          LikeButton(isLiked: isLiked, onTap: toggleLike),
         
const SizedBox(width: 20),
          //message and username
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children:
             [
              Text(widget.user,style: TextStyle(color: Colors.grey[500]),),
             const SizedBox(height: 10,),
              Text(widget.message),
            ],
          )
        ],
      ),
    );
  }
}