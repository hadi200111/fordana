import 'dart:async';

import 'package:CampusConnect/Locale/locale.dart';
import 'package:CampusConnect/Messages/NotificationsPage.dart';
import 'package:CampusConnect/WelocomeLogIn/LogInPage.dart';
import 'package:CampusConnect/api/firebase_api.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CampusConnect/Calendar/Appointments.dart';
import 'package:CampusConnect/Main_Page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:CampusConnect/Posts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CampusConnect/Messages/ChatProvider.dart';
import 'Locale/locale_controller.dart';

/////Notifications
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDK07y9RLzWSoLPrxAgY_gegeL-_qNsY8M",
        appId: "1:476838126677:android:a4b14bb36537f271d960dc",
        messagingSenderId: "476838126677",
        projectId: "campus-connect-3917b",
        storageBucket: "campus-connect-3917b.appspot.com"),
  );
  await FirebaseApi().initNotifications();

  // AwesomeNotifications().initialize(
  //   null,
  //   [
  //     NotificationChannel(
  //         channelKey: 'basic_channel',
  //         channelName: 'Basic Notifications',
  //         channelDescription: 'Notification '),
  //   ],
  //   debug: true,
  // );
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MyLocaleController controllerLang = Get.put(MyLocaleController());
    /////////// messages and chat
    return ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return ChangeNotifierProvider(
              create: (_) => ChatProvider(),
              child: GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'CampusConnect',
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                ),
                ////Dark
                darkTheme: ThemeData.dark(),
                themeMode: currentMode,
                locale: controllerLang.initialLang,
                translations: MyLocale(),
                // home: const MyHomePage(title: 'Connect Login'),
                home: SplashScreen(),
                routes: {
                  NotificationsPage.route: (context) => NotificationsPage(),
                },
              ));
        });
  }
}

////////////////////////////////////////////////////
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;

    Widget nextPage;
    if (keepLoggedIn) {
      await Globals.loadFromPreferences();
      nextPage = Main_Page();
    } else {
      nextPage = LogInPage();
    }

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BounceInDown(
          // Animating the text with BounceInDown effect
          duration: Duration(seconds: 3),
          child: Text(
            'Campus Connect',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
