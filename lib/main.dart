// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:connect/auth/auth.dart';
import 'package:connect/auth/services/firebase_api.dart';
import 'package:connect/auth/services/notification_page.dart';
import 'package:connect/firebase_options.dart';
import 'package:connect/login/page/login_page.dart';
import 'package:connect/pages/register_page.dart';

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
        title: 'Connect',
        theme: ThemeData(),
        home: Authpage(),
        // navigatorKey: navigatorKey,
        routes: {
          '/login_page': (context) => LoginPage(),
          '/register_page': (context) => RegisterPage(),
          '/notification_screen': (context) => const NotificationPage(),
        });
  }
}
