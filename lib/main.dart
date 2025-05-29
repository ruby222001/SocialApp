// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth/auth.dart';
import 'package:socialapp/auth/services/firebase_api.dart';
import 'package:socialapp/auth/services/notification_page.dart';
import 'package:socialapp/firebase_options.dart';
import 'package:socialapp/pages/login_page.dart';
import 'package:socialapp/pages/register_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initPushNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RUBY',
        theme: ThemeData(),
        home: Authpage(),
        navigatorKey: navigatorKey,
        routes: {
          '/login_page': (context) => LoginPage(),
          '/register_page': (context) => const RegisterPage(),
          '/notification_screen': (context) => const NotificationPage(),
        });
  }
}
