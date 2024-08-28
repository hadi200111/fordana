import 'dart:async';
import 'dart:io';
import 'package:CampusConnect/UserPage/EditProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../WelocomeLogIn/LogInPage.dart';
import 'SettingsPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isSwitch = false;
  bool? isChecked = false;
  late String _imagePath = '';
  late String _userName = '';
  late String _userID = '';
  late String _major = 'Computer Science';
  late String _roll = '';
  late List<String> _schedule = ['Math', 'Physics', 'Chemistry'];

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadProfileImage();
    _loadUserData();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('profile_image_path');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  Future<void> _saveProfileImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  //// the following 2 methods for saving the image into firebase
  Future<String> uploadImage(File image, String userId) async {
    final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId/${image.path.split('/').last}');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateUserProfileImage(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({'profileImageUrl': imageUrl});
    }
  }
  Future<void> _loadUserData() async {
    await Globals.loadFromPreferences();
    setState(() {
      _userName = Globals.userID;
      _userID = Globals.userID;
      //_major = Globals.major;
      _roll = Globals.roll;
      _schedule = Globals.Schedule;
      _schedule.remove('Private');
      _schedule.remove('Public');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String newPath = appDirectory.path + '/profile_image.jpg';
      final File newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _imagePath = newImage.path;
      });

      // Save the image path to shared preferences
      await _saveProfileImagePath(newPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 94, 53, 177),
                Colors.purpleAccent.shade700,
              ],
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            // physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 73),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          AntDesign.arrowleft,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          AntDesign.logout,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Add logout functionality
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "myprofile".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontFamily: 'Nisebuschgardens',
                    ),
                  ),
                  SizedBox(height: 22),
                  Container(
                    height:
                        height * 0.6, // Adjusted height for the main container
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: innerHeight * 0.6,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 80),
                                    Text(
                                      _userName,
                                      style: TextStyle(
                                        color: Color.fromRGBO(44, 90, 200, 1),
                                        fontFamily: 'Nunito',
                                        fontSize: 37,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _userID,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontFamily: 'Nunito',
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _roll,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontFamily: 'Nunito',
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      _major,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontFamily: 'Nunito',
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 200,
                              right: 20,
                              child: IconButton(
                                icon: Icon(
                                  AntDesign.setting,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingsPage()),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 200,
                              left: 20,
                              child: IconButton(
                                icon: Icon(
                                  AntDesign.edit,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),

                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Editprofile()),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _pickImage(ImageSource.gallery);
                                  },
                                  child: CircleAvatar(
                                    radius:
                                        120, // Increased radius for larger image
                                    backgroundColor: Colors.blueGrey,
                                    backgroundImage: _imagePath.isNotEmpty
                                        ? FileImage(File(_imagePath))
                                        : null,
                                    child: _imagePath.isEmpty
                                        ? Icon(Icons.add_a_photo,
                                            size: 70,
                                            color: Colors
                                                .grey) // Increased icon size
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height:
                        height * 0.6, // Adjusted height for the main container
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Schedule',
                            style: TextStyle(
                              color: Color.fromRGBO(44, 90, 200, 1),
                              fontSize: 27,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Divider(thickness: 1.5),
                          SizedBox(height: 10),
                          DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Subject',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _schedule.map((subject) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(subject),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          Divider(),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     debugPrint('Edit Profile');
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     padding: EdgeInsets.symmetric(vertical: 10),
                  //   ),
                  //   child: Text('Edit Profile', style: TextStyle(fontSize: 16)),
                  // ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
