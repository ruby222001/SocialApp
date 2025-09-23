// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileController extends GetxController {
//   final currentUser = FirebaseAuth.instance.currentUser!;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final TextEditingController bioController = TextEditingController();

//   // Observable variables
//   var profileImageUrl = ''.obs;
//   var username = ''.obs;
//   var bio = ''.obs;
//   var isLoading = true.obs;
//   var isUploadingImage = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadUserProfile();
//   }

//   Future<void> loadUserProfile() async {
//     try {
//       final userDoc = await firestore.collection('Users').doc(currentUser.uid).get();
//       if (userDoc.exists) {
//         final data = userDoc.data();
//         profileImageUrl.value = data?['profileImageUrl'] ?? '';
//         username.value = data?['username'] ?? '';
//         bio.value = data?['bio'] ?? '';
//         bioController.text = bio.value;
//       }
//     } catch (e) {
//       print("Error loading profile: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> updateProfilePicture() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       isUploadingImage.value = true;
//       try {
//         final file = File(pickedFile.path);
//         final ref = FirebaseStorage.instance.ref('profile_images/${currentUser.uid}.jpg');
//         await ref.putFile(file);
//         final url = await ref.getDownloadURL();

//         await firestore.collection('Users').doc(currentUser.uid).update({
//           'profileImageUrl': url,
//         });

//         profileImageUrl.value = url;
//       } catch (e) {
//         print("Error uploading profile image: $e");
//       } finally {
//         isUploadingImage.value = false;
//       }
//     }
//   }

//   Future<void> updateBio(String updatedBio) async {
//     if (updatedBio.trim() == bio.value) return;

//     try {
//       await firestore.collection('Users').doc(currentUser.uid).update({
//         'bio': updatedBio.trim(),
//       });
//       bio.value = updatedBio.trim();
//     } catch (e) {
//       print("Error updating bio: $e");
//     }
//   }

//   Future<void> deletePost(String postId, String imageUrl) async {
//     try {
//       await firestore.collection('User Posts').doc(postId).delete();
//       if (imageUrl.isNotEmpty) {
//         final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
//         await storageRef.delete();
//       }
//       Get.snackbar('Success', 'Post deleted successfully');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to delete post');
//     }
//   }
// }
