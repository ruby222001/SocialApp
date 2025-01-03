import 'package:app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _FirebaseMessaging = FirebaseMessaging.instance;

// function to initialize notifications
  Future<void> initNotifications() async {
//request permission from user
    await _FirebaseMessaging.requestPermission();

//fetch the token for this device
    final fCMToken = await _FirebaseMessaging.getToken();

    //print token
    print('Token: $fCMToken');
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
