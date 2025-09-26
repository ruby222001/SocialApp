import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/pages/bottomnav_controller.dart';
import 'package:connect/pages/chat_page.dart';
import 'package:connect/pages/homepage.dart';
import 'package:connect/pages/posting_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'post.dart';
import 'profilepage.dart';

class MainNavPage extends StatelessWidget {
  MainNavPage({super.key});

  final BottomNavController _navController = Get.put(BottomNavController());

  // Pages for bottom nav (no PostingPage here!)
  final List<Widget> pages = [
    HomePage(),
    PostingPage(),
    ChatPage(),
    ProfilePage(),
  ];

  final iconList = <Widget>[
    Icon(
      Icons.home,
    ),
    Icon(Icons.add),
    Icon(Icons.chat),
    Icon(Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: pages[_navController.currentIndex.value],
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          items: iconList,
          backgroundColor: Colors.black,
          animationCurve: Curves.easeIn,
          index: _navController.currentIndex.value,
          onTap: (index) {
            _navController.changeIndex(index);
          },
        ),
      );
    });
  }
}
