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
      // showDialog(
      //   context: context,
      //   builder: (context) => const Center(child: CircularProgressIndicator()),
      // );

      try {
        if (passwordController.text.trim() ==
            confirmpasswordController.text.trim()) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          showErrorMessage(context,"Passwords don't match");
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showErrorMessage(context,e.message ?? 'An error occurred');
      }
    }
  }

  void showErrorMessage(BuildContext context,String message) {
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