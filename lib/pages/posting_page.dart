import 'package:app/components/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({super.key});

  @override
  State<PostingPage> createState() => _PostingPageState();
}

final textController = TextEditingController();
final currentUser = FirebaseAuth.instance.currentUser!;

void postMessage(BuildContext context) {
  // Only post if there is something
  if (textController.text.isNotEmpty) {
    // Store in Firebase
    FirebaseFirestore.instance.collection("User Posts").add({
      'UserEmail': currentUser.email,
      'Message': textController.text,
      'TimeStamp': Timestamp.now(),
      'Likes': [],
    }).then((_) {
      // Clear the text
      textController.clear();

      // Navigate back to the homepage
      Navigator.pop(context);
    }).catchError((error) {
      // Handle any errors if posting fails
      if (kDebugMode) {
        print('Failed to post message: $error');
      }
    });
  }
}

class _PostingPageState extends State<PostingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                //textfield
                Expanded(
                  child: MyTextField(
                    hintText: 'Write something here',
                    obscureText: false,
                    controller: textController,
                  ),
                ),
                //post button
                const SizedBox(
                  width: 5,
                ),

                IconButton(
                    onPressed: () => postMessage,
                    icon: const Icon(Icons.keyboard_arrow_down_outlined))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
