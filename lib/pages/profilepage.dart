import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade100,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade200,
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 50),
            const Icon(
              Icons.person,
              size: 72,
            ),
            const SizedBox(height: 10),
            Text(
              currentUser.email!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            )
          ],
        ));
  }
}
