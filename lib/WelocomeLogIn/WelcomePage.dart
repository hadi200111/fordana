import 'dart:async';
import 'package:CampusConnect/Main_Page.dart';
import 'package:flutter/material.dart';
import 'LogInPage.dart';
import 'package:animate_do/animate_do.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Navigate to LogInPage after 5 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  LogInPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        // No need for a back button in the welcome page
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BounceInDown( // Animating the text with BounceInDown effect
                duration: Duration(seconds: 1),
                child: Text(
                  'Welcome to CampusConnect',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              FadeIn( // Animating the text with FadeIn effect
                duration: Duration(seconds: 2),
                child: Text(
                  'for Birzeit University',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              ZoomIn( // Animating the first image with ZoomIn effect
                duration: Duration(seconds: 1),
                child: Image.asset(
                  'images/bzu3.jpg',
                  height: 200,
                ),
              ),
              SizedBox(height: 20),
              ZoomIn( // Animating the text with ZoomIn effect
                duration: Duration(seconds: 1),
                child: Column(
                  children: [
                    Text(
                      'Connect with your peers, stay updated with events,',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'and manage your appointments seamlessly.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ZoomIn( // Animating the second image with ZoomIn effect
                duration: Duration(seconds: 1),
                child: Image.asset(
                  'images/bzu1.jpg',
                  height: 200,
                ),
              ),
              SizedBox(height: 20),
              FadeIn( // Animating the CircularProgressIndicator with FadeIn effect
                duration: Duration(seconds: 1),
                child: CircularProgressIndicator(), // Loading indicator
              ),
            ],
          ),
        ),
      ),
    );
  }
}