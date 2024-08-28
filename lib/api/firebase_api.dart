import 'dart:convert';

import 'package:CampusConnect/Messages/NotificationsPage.dart';
import 'package:CampusConnect/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

     Future<void> handleBackgroundMessage(RemoteMessage message) async{
       print('Title: ${message.notification?.title}');
       print('Body: ${message.notification?.body}');
       print('Payload: ${message.data}');

     }

    class FirebaseApi {
      final _firebaseMessaging = FirebaseMessaging.instance;

      final _androidChannel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This is Used for Important notification',
        importance: Importance.defaultImportance,
      );
      final _localNotifications = FlutterLocalNotificationsPlugin();

      void handleMessage(RemoteMessage? message){
        if (message == null) return;
        navigatorKey.currentState?.pushNamed(
          NotificationsPage.route,
          arguments: message,
        );
      }

      Future initLocalNotifications() async {
        const iOS = DarwinInitializationSettings();
        const android = AndroidInitializationSettings('@drawable/launcher_icon');
        const settings = InitializationSettings(android: android , iOS: iOS);

        await _localNotifications.initialize(
          settings,
          onDidReceiveNotificationResponse: (payload){
            final message = RemoteMessage.fromMap(jsonDecode(payload as String));
            handleMessage(message);
          },
        );
        final platform = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await platform?.createNotificationChannel(_androidChannel);

      }
      Future initPushNotifications() async {
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
        FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
        FirebaseMessaging.onMessage.listen((message){
           final notification = message.notification;
           if(notification == null) return;
           _localNotifications.show(
               notification.hashCode,
               notification.title,
               notification.body,
               NotificationDetails(
                 android: AndroidNotificationDetails(
                   _androidChannel.id,
                   _androidChannel.name,
                   channelDescription: _androidChannel.description,
                   icon: '@drawable/launcher_icon',
                 ),
               ),
             payload: jsonEncode(message.toMap()),
           );

           /////hay edit mn 5areeeeha
        });

      }


      Future<void> initNotifications() async {
        await _firebaseMessaging.requestPermission();
        final fCMToken = await _firebaseMessaging.getToken();
        print('Token: $fCMToken');
        FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
        initPushNotifications();
        initLocalNotifications();
      }

    }

