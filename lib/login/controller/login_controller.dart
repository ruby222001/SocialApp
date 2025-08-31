import 'package:connect/components/components/snackbar.dart';
import 'package:connect/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

//LOGIN
  void loginUser({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
       SSnackbarUtil.showFadeSnackbar(
              context, "You are logged in", SnackbarType.success);
      // if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      SSnackbarUtil.showFadeSnackbar(
          context, e.message ?? "Login failed", SnackbarType.success);
    }
  }
}
