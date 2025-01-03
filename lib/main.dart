import 'package:app/auth/auth.dart';
import 'package:app/auth/services/firebase_api.dart';
import 'package:app/auth/services/notification_page.dart';
import 'package:app/firebase_options.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
        title: 'Flutter Demo',
        theme: ThemeData(),
        home: Authpage(),
        navigatorKey: navigatorKey,
        routes: {
          '/login_page': (context) => const LoginPage(),
          '/register_page': (context) => const RegisterPage(),
          '/notification_screen': (context) => const NotificationPage(),
        });
  }
}
