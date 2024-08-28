import 'package:CampusConnect/HomePage.dart';
import 'package:CampusConnect/Posts.dart';
import 'package:CampusConnect/WelocomeLogIn/WelcomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CampusConnect/Calendar/Appointments.dart';
import 'package:CampusConnect/Main_Page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'About.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static String userNumber = "";
  static String userID = "";
  static String roll = "";
  static List<String> Schedule = [];
  static List<String> Friends = [];
  static String courseName = "";
  static String major = "";
  static List<Map<String, Map<String, List<String>>>> categories = [];
  static Appointments app = Appointments(
      author: "Hadi",
      subject: "subject",
      description: "description",
      date: DateTime(2024, 9, 9, 9),
      startTime: DateTime(2024, 9, 9, 9),
      endTime: DateTime(2024, 9, 9, 9),
      location: "location",
      status: "Private",
      docID: "");
  static Future<void> saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', userID);
    await prefs.setString('roll', roll);
    await prefs.setStringList('Schedule', Schedule);
    await prefs.setStringList('Friends', Friends);
    await prefs.setString('courseName', courseName);
    // Serialize and save other complex data if needed
  }

  static Future<void> loadFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? '';
    roll = prefs.getString('roll') ?? '';
    Schedule = prefs.getStringList('Schedule') ?? [];
    Friends = prefs.getStringList('Friends') ?? [];
    courseName = prefs.getString('courseName') ?? '';
    // Deserialize and load other complex data if needed
  }
}

// Future<void> main() async {
//   //WidgetsFlutterBinding.ensureInitialized();
//   runApp(LogInPage());
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//         apiKey: "AIzaSyDK07y9RLzWSoLPrxAgY_gegeL-_qNsY8M",
//         appId: "1:476838126677:android:a4b14bb36537f271d960dc",
//         messagingSenderId: "476838126677",
//         projectId: "campus-connect-3917b",
//         storageBucket: "campus-connect-3917b.appspot.com"),
//   );
// }

Future<bool> fetchUserData(String email, String password) async {
  bool check = false;
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Users').get();
  querySnapshot.docs.forEach((doc) {
    var myemail = doc.get("email");
    var mypassword = doc.get("password");

    if (myemail == email && mypassword == password) {
      check = true;
      Globals.userID = doc.get("firstName");
      Globals.roll = doc.get("role");
      Globals.userNumber = doc.get("userNumber");
      Globals.major = doc.get("major");
      print(Globals.userNumber);
      List<dynamic> scheduleFromFirestore = doc.get("Schedule");
      Globals.Schedule = List<String>.from(
          scheduleFromFirestore.map((schedule) => schedule.toString()));
      Globals.Schedule.addAll(['Private', 'Public']);
      List<dynamic> friendsFromFirestore = doc.get("Friends");
      Globals.Friends = List<String>.from(
          friendsFromFirestore.map((friends) => friends.toString()));
      Globals.saveToPreferences();
    }
  });
  return check;
}

Future<void> saveTokenToDatabase() async {
  String? fcmToken = await FirebaseMessaging.instance.getToken();

  if (fcmToken != null) {
    var tokensRef = FirebaseFirestore.instance.collection('Users').doc("1");

    await tokensRef.set(
        {
          'fcmToken': fcmToken,
        },
        SetOptions(
            merge: true)); // Use merge: true to avoid overwriting existing data
  }
}
//////////////////////////////////////////////////////

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _keepLoggedIn = false;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false; // AdFpaad this line
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;
      if (_keepLoggedIn) {
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        Globals.loadFromPreferences();
      }
    });
  }

  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepLoggedIn', _keepLoggedIn);
    if (_keepLoggedIn) {
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  void _showAlertDialog(String message, IconData iconData, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                iconData,
                color: iconColor,
              ),
              SizedBox(width: 10),
              Text("Alert"),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.deepPurple.shade700,
                Colors.deepPurpleAccent,
                Colors.purple.shade300
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    FadeInUp(
                        duration: Duration(milliseconds: 1300),
                        child: Text(
                          "Welcome Back",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60))),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(225, 95, 27, .3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                          hintText: "UserName",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _keepLoggedIn,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _keepLoggedIn = newValue!;
                                    });
                                    _saveCredentials();
                                  },
                                ),
                                Text("Remember Me",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.grey),
                            )),
                        SizedBox(
                          height: 40,
                        ),
                        FadeInUp(
                            duration: Duration(milliseconds: 1600),
                            child: MaterialButton(
                              onPressed: () async {
                                String email = _usernameController.text;
                                String password = _passwordController.text;
                                if (email.isEmpty || password.isEmpty) {
                                  _showAlertDialog(
                                    "Please enter both username and password.",
                                    Icons.error,
                                    Colors.red,
                                  );
                                } else {
                                  if (await fetchUserData(email, password)) {
                                    _saveCredentials();
                                    saveTokenToDatabase();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Main_Page()),
                                    );
                                  } else {
                                    _showAlertDialog(
                                      "Incorrect username or password.",
                                      Icons.warning,
                                      Colors.yellow,
                                    );
                                  }
                                }
                              },
                              height: 50,
                              color: Colors.deepPurple[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 50,
                        ),
                        FadeInUp(
                            duration: Duration(milliseconds: 1700),
                            child: Text(
                              "Continue with Ritaj",
                              style: TextStyle(color: Colors.grey),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FadeInUp(
                                  duration: Duration(milliseconds: 1800),
                                  child: MaterialButton(
                                    onPressed: () {
                                      const url =
                                          'https://ritaj.birzeit.edu/register/';
                                      launch(url);
                                    },
                                    height: 50,
                                    color: Colors.green[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Ritaj",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: FadeInUp(
                                  duration: Duration(milliseconds: 1900),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const About()),
                                      );
                                    },
                                    height: 50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    color: Colors.black,
                                    child: Center(
                                      child: Text(
                                        "VisitorPick",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
