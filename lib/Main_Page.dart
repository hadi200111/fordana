import 'dart:io';
import 'package:CampusConnect/Library/PrevoisMaterial.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CampusConnect/Posts.dart';
import 'package:CampusConnect/PostWidget.dart';
import 'package:CampusConnect/ToDoList/ToDoList.dart';
import 'package:CampusConnect/Calendar/CalendarPage.dart';
import 'package:CampusConnect/Library/LibraryPage.dart';
import 'package:CampusConnect/Messages/NotificationsPage.dart';
import 'package:CampusConnect/UserPage/ProfilePage.dart';
import 'package:CampusConnect/UserPage/SettingsPage.dart';
import 'package:CampusConnect/WelocomeLogIn/About.dart';
import 'package:CampusConnect/WelocomeLogIn/LogInPage.dart';
import 'package:CampusConnect/Messages/ChatListScreen.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:CampusConnect/Messages/ChatProvider.dart';

List<Posts> posts = [];

class Main_Page extends StatefulWidget {
  const Main_Page({Key? key}) : super(key: key);

  @override
  Main_PageState createState() => Main_PageState();
}

class Main_PageState extends State<Main_Page> {
  int currentPage = 2;

  final List<Widget> _pages = [
    const CalendarPage(),
    ProfilePage(),
    MainHomePage(),
    const NotificationsPage(),
    About(),
  ];

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple.shade200,
          title: Row(
            children: [
              Image.asset(
                'images/ConnectBZU.png', // Path to your logo image
                height: 20, // Adjust the height as needed
              ),
              SizedBox(width: 8), // Space between the logo and the title
              Text("0".tr),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.message_rounded,
                size: 23,
                color: Colors.deepPurple,
              ),
              onPressed: () async {
                print("Messages tapped");
                if (Globals.Friends.isEmpty) {
                  print('No friends found');
                  return;
                }
                // Create chats for all friends if they don't exist
                for (String friendId in Globals.Friends) {
                  print(friendId);
                  print("HEY");
                  await chatProvider.createChat([Globals.userID, friendId]);
                }

                for (String schedule in Globals.Schedule) {
                  await chatProvider.addUserToGroupChat(
                      schedule, Globals.userID);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatListScreen(currentUserId: Globals.userID),
                  ),
                );
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [Colors.deepPurpleAccent, Colors.purple],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Adding the image
                    CircleAvatar(
                      radius: 38, // Adjust the size as needed
                      backgroundColor:
                          Colors.grey, // Add your desired background color
                      child: Icon(
                        Icons.person,
                        size: 50, // Adjust the icon size as needed
                        color: Colors.white, // Add your desired icon color
                      ), // Path to your image
                    ),
                    SizedBox(
                        width:
                            16), // Adding some space between the image and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Globals.userID, // First text
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        SizedBox(height: 8), // Adding some space between texts
                        Text(
                          "welcome".tr,
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontFamily: 'Nunito',
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.calendar_month_outlined,
                title: "calendar".tr,
                onTap: () {
                  if (Globals.Schedule.contains("Private") ||
                      Globals.Schedule.contains("Public")) {
                  } else {
                    Globals.Schedule.add("Private");
                    Globals.Schedule.add("Public");
                  }
                  _navigateToPage(const CalendarPage());
                },
              ),
              _buildDrawerItem(
                icon: Icons.book_online_sharp,
                title: "library".tr,
                onTap: () => _navigateToPage(const LibraryPage()),
              ),
              _buildDrawerItem(
                icon: Icons.library_books_outlined,
                title: "previous".tr,
                onTap: () => _navigateToPage(const PreviousMaterial()),
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: "profile".tr,
                onTap: () => _navigateToPage(ProfilePage()),
              ),
              _buildDrawerItem(
                icon: Icons.notifications,
                title: "notification".tr,
                onTap: () => _navigateToPage(const NotificationsPage()),
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: "settings".tr,
                onTap: () => _navigateToPage(const SettingsPage()),
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: "logout".tr,
                onTap: () => _navigateToPage(LogInPage()),
              ),
              _buildDrawerItem(
                icon: Icons.info,
                title: "about".tr,
                onTap: () => _navigateToPage(const About()),
              ),
              _buildDrawerItem(
                icon: Icons.view_timeline_outlined,
                title: "todolist".tr,
                onTap: () => _navigateToPage(ToDoList()),
              ),
            ],
          ),
        ),
        body: _pages[currentPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_sharp), label: 'Search'),
          ],
          backgroundColor:
              Colors.deepPurpleAccent, // Background color of the navigation bar
          selectedItemColor:
              Colors.deepPurple.shade700, // Color of the selected item
          unselectedItemColor:
              Colors.grey.shade700, // Color of the unselected items
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required void Function() onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class MainHomePage extends StatefulWidget {
  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final TextEditingController postController = TextEditingController();
  String postImageUrl = "";
  String myPostURL = "";
  String? selectedVisibility;
  File? _image;
  bool isLoadingMore = false;
  bool noMorePosts = false; // Track if there are no more posts to load
  List<Posts> visiblePosts = [];
  int visiblePostCount = 4;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getInitialPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!isLoadingMore && !noMorePosts) {
        setState(() {
          isLoadingMore = true;
        });
        loadMorePosts();
      }
    }
  }

  Future<void> getInitialPosts() async {
    try {
      List<Posts> fetchedPosts = await getPosts();
      setState(() {
        posts = fetchedPosts;
        visiblePosts = posts.take(visiblePostCount).toList();
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  void loadMorePosts() {
    if (visiblePostCount >= posts.length) {
      setState(() {
        noMorePosts = true;
        isLoadingMore = false;
      });
    } else {
      setState(() {
        visiblePostCount += 4; // Increase the count to load more posts
        visiblePosts = posts.take(visiblePostCount).toList();
        isLoadingMore = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() async {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        myPostURL = await uploadImage(
            File(pickedFile.path), Globals.userNumber, Globals.userID);
        print(myPostURL + "HAHAHAHAH");
      } else {
        print('No image selected.');
      }
    });
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: postController,
                decoration: InputDecoration(
                  hintText: 'What are you thinking?',
                ),
                maxLines: 4,
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedVisibility,
                hint: Text("Select Visibility"),
                items: <String>['Public', Globals.major, 'Friends']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedVisibility = newValue;
                  });
                },
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: _pickImage,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                postController.clear();
                postImageUrl = "";
                selectedVisibility = null;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Post'),
              onPressed: () async {
                if (postController.text.isNotEmpty) {
                  setState(() {
                    posts.add(Posts(
                      userName: Globals.userID,
                      userImageUrl: 'https://picsum.photos/250?image=9',
                      postImageUrl: myPostURL,
                      caption: postController.text,
                      likeCounter: 0,
                      comments: [],
                      readby: [],
                      likedby: [],
                      postVisability: selectedVisibility,
                      publishDate: DateTime.now(),
                    ));
                    visiblePosts = posts
                        .take(visiblePostCount)
                        .toList(); // Update visible posts
                  });
                  Navigator.of(context).pop();
                  await writePost(Posts(
                      userName: Globals.userID,
                      postImageUrl: myPostURL,
                      userImageUrl: 'https://picsum.photos/250?image=9',
                      caption: postController.text,
                      likeCounter: 0,
                      comments: [],
                      readby: [],
                      likedby: [],
                      postVisability: selectedVisibility,
                      publishDate: DateTime.now()));
                  postController.clear();
                  postImageUrl = "";
                  selectedVisibility = null;
                  _image = null;
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadImage(File image, String number, String name) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts_images/${number + name}/${image.path.split('/').last}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  Future<void> writePost(Posts post) async {
    try {
      CollectionReference PostsCollection =
          FirebaseFirestore.instance.collection('Posts');

      await PostsCollection.add({
        'userName': post.userName,
        'userImageUrl': post.userImageUrl,
        'postImageUrl': post.postImageUrl,
        'caption': post.caption,
        'likeCounter': post.likeCounter,
        'comments': post.comments,
        'readby': post.readby,
        'likedby': post.likedby,
        'postVisability': post.postVisability,
        'publishDate': post.publishDate,
      });

      print('Post added successfully.');
    } catch (error) {
      print('Error adding post: $error');
      _showAlertDialog('Error', 'Error adding post: $error');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Posts>> getPosts() async {
    List<Posts> posts = [];
    bool check = false;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Posts').get();
    querySnapshot.docs.forEach((doc) async {
      var field1 = doc.get("userName");
      var field2 = doc.get("userImageUrl");
      var field3 = doc.get("postImageUrl");
      var field4 = doc.get("caption");
      var field5 = doc.get("likeCounter");
      var field6 = doc.get("comments");
      var field7 = doc.get("readby");
      var field8 = doc.get("likedby");
      var field9 = doc.get("postVisability");
      var field10 = doc.get("publishDate");
      var id = doc.id;

      final String userName = field1 as String;
      final String userImageUrl = field2 as String;
      final String postImageUrl = field3 as String;
      final String caption = field4 as String;
      final int likeCounter = field5 as int;
      final List<dynamic> commentsList = field6 as List<dynamic>;
      final List<dynamic> readbyList = field7 as List<dynamic>;
      final List<dynamic> likedbyList = field8 as List<dynamic>;
      final String postVisability = field9 as String;

      List<String> comments = commentsList.cast<String>();
      List<String> readby = readbyList.cast<String>();
      List<String> likedby = likedbyList.cast<String>();

      if (postVisability == "Friends") {
        if (Globals.Friends.contains(userName)) {
          check = true;
          print("dude is a friend");
        } else {
          check = false;
          print("dude is not a friend");
        }
      } else {
        check = false;
        print("its not friends");
        if (postVisability == Globals.major) {
          check = true;
        } else {
          check = false;
          print("its not major");
          if (postVisability == "Public") {
            check = true;
            print("its Public");
          } else {
            check = false;
            print("its not public");
          }
        }
      }
      print("----------");
      if (check == true) {
        readby.add(Globals.userNumber);
        posts.add(Posts(
          userName: userName,
          userImageUrl: userImageUrl,
          postImageUrl: postImageUrl,
          caption: caption,
          likeCounter: likeCounter,
          comments: comments,
          readby: readby,
          likedby: likedby,
          id: id,
          postVisability: postVisability,
          publishDate: (field10 as Timestamp).toDate(),
        ));
        await FirebaseFirestore.instance.collection('Posts').doc(id).update({
          'readby': readby,
        });
      }
    });
    posts.sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => _showCreatePostDialog(context),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'What are you thinking?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              enabled: false,
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification &&
                  _scrollController.position.extentAfter == 0) {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  loadMorePosts();
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: visiblePosts.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < visiblePosts.length) {
                  return PostWidget(
                    post: visiblePosts[index],
                  );
                } else if (noMorePosts) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No more new posts.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
