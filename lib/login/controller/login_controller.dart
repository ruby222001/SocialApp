import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/components/components/snackbar.dart';
import 'package:connect/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//LOGIN
 Future<UserCredential?> loginUser({
  required BuildContext context,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required GlobalKey<FormState> formKey,
}) async {
  if (!formKey.currentState!.validate()) return null;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Save/update user in Firestore
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.uid)
        .set({
      'uid': userCredential.user!.uid,
      'email': emailController.text.trim(),
      'profileImageUrl': "",
    }, SetOptions(merge: true));

    if (context.mounted) {
      Navigator.pop(context); // close progress dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );

      SSnackbarUtil.showFadeSnackbar(
          context, "You are logged in", SnackbarType.success);
    }

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (context.mounted) Navigator.pop(context); // close progress dialog

    String message = "";

    switch (e.code) {
      case "invalid-email":
        message = "The email address is badly formatted.";
        break;
      case "user-disabled":
        message = "This user has been disabled.";
        break;
      case "user-not-found":
        message = "No user found with this email.";
        break;
      case "wrong-password":
        message = "Incorrect password.";
        break;
      case "invalid-credential":
        message = "Invalid credentials, please try again.";
        break;
      default:
        message = "Login failed. Please try again.";
    }

    SSnackbarUtil.showFadeSnackbar(context, message, SnackbarType.error);
    return null; // Do not rethrow, prevents app crash
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    SSnackbarUtil.showFadeSnackbar(
        context, "An error occurred. Please try again.", SnackbarType.error);
    return null;
  }
}


  User? getCurrentuser() {
    return FirebaseAuth.instance.currentUser;
  }
}
