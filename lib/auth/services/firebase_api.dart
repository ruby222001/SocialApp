import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:socialapp/main.dart';

class FirebaseApi {
  // ignore: non_constant_identifier_names
  final _FirebaseMessaging = FirebaseMessaging.instance;

// function to initialize notifications
  Future<void> initNotifications() async {
//request permission from user
    await _FirebaseMessaging.requestPermission();

//fetch the token for this device

    //print token
    initNotifications();
  }

  void handleMesasge(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState
        ?.pushNamed('/notification_screen', arguments: message);
  }

  Future<void> initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMesasge);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMesasge);
  }
}
