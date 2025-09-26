import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  // @override
  // void ondispose() {
  //   userController.dispose();
  //   emailController.dispose();
  //   passwordController.dispose();
  //   confirmpasswordController.dispose();
  //   super.dispose();
  // }
  void registerUser(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        if (passwordController.text.trim() ==
            confirmpasswordController.text.trim()) {
          // Create user with Firebase Auth
          UserCredential userCred =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
          User? user = userCred.user;

          if (user != null) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .set({
              'username': userController.text.trim(),
              'uid': user.uid,
              'email': user.email,
              'createdAt': DateTime.now(),'profileImageUrl': null, // placeholder
  'bio': '',

            });
          }
          // Close loading dialog
          Navigator.pop(context);

          // Navigate to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pop(context); // close loading
          showErrorMessage(context, "Passwords don't match");
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // close loading
        showErrorMessage(context, e.message ?? 'An error occurred');
      }
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
