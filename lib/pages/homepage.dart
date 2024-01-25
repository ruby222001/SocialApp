import 'package:app/components/components/drawer.dart';
import 'package:app/components/components/my_textfield.dart';
import 'package:app/pages/post.dart';
import 'package:app/pages/profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

//controller
  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  //post message

  void postMessage() {
//only post if there is smthg
    if (textController.text.isNotEmpty) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes':[],
      });
    }
    //clear text
    setState((){
      {
      textController.clear();
    }
    });
  }
void goToProfilePage(){
  Navigator.pop(context);
  Navigator.push(context,MaterialPageRoute(builder: (context) => const ProfilePage(),
  ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
        title: const Text('M I N I M A L',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      
      ),
drawer: MyDrawer(
  onProfileTap: goToProfilePage,
   onSignout: signOut,
),
      body: Center(

        child: Column(

          children: [
            
            //the wall collect data from firebase
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                        // print("Data from Firestore: ${snapshot.data!.docs}");

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshot.data!.docs[index];
                        return Post(
                          user: post["UserEmail"],
                          message: post["Message"],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? [] ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            //post
            const SizedBox(
              height: 10,
            ),
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
                      onPressed: postMessage,
                      icon: const Icon(Icons.keyboard_arrow_down_outlined))
                ],
              ),
            ),
            //logged in as
            Text("logged in as:${currentUser.email!}"),
          ],
        ),
      ),
    );
  }
}
