import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CampusConnect/Library.dart';
import 'package:CampusConnect/Library/AddCategoryDialog.dart';
import 'package:CampusConnect/Library/BooksPage.dart';
import 'package:CampusConnect/Library/CategoryTile.dart';
import 'package:CampusConnect/Library/SearchPage.dart';
import 'package:CampusConnect/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../WelocomeLogIn/LogInPage.dart';

String myid = "";
Map<String, Map<String, List<String>>> _categories = {};

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text(
          'Library',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchBarApp()),
              );
            },
          ),
        ],
        backgroundColor: Colors.deepPurpleAccent,
      ),*/
      body: FutureBuilder(
        future: getCata(), // Get the list of majors
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> majors = snapshot.data as List<String>;
            return FutureBuilder(
              future: getCourses(majors), // Get courses for each major
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, Map<String, List<String>>>> courses =
                      snapshot.data
                          as List<Map<String, Map<String, List<String>>>>;
                  // Update _categories with the retrieved courses
                  _categories.clear();
                  for (var course in courses) {
                    _categories.addAll(course);
                  }
                  return ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final category = _categories.keys.elementAt(index);
                      return CategoryExpansionTile(
                        category: category,
                        subCategories: _categories[category]!,
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCategoryDialog(
          onCategoryAdded: (category) {
            if (_categories.containsKey(category)) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Category Already Exists'),
                    content: Text('The category "$category" already exists.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              setState(() {
                _categories[category] = {};
              });
            }
          },
        );
      },
    );
  }
}

Future<List<String>> getCata() async {
  List<String> majors = [];

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Categories').get();
  querySnapshot.docs.forEach((doc) {
    myid = doc.id;
    List<dynamic> scheduleFromFirestore = doc.get("majors");
    majors.addAll(scheduleFromFirestore.map((major) => major.toString()));
  });

  return majors;
}

Future<List<Map<String, Map<String, List<String>>>>> getCourses(
    List<String> majors) async {
  List<Map<String, Map<String, List<String>>>> categories = [];

  // Fetch categories from the 'Categories' collection
  QuerySnapshot categoriesSnapshot =
      await FirebaseFirestore.instance.collection('Categories').get();

  for (QueryDocumentSnapshot categoryDoc in categoriesSnapshot.docs) {
    String category = categoryDoc.id;
    Map<String, List<String>> subCategories = {};

    // Fetch subcategories from the 'mymajors' collection under each category
    QuerySnapshot subCategoriesSnapshot =
        await categoryDoc.reference.collection('mymajors').get();

    for (QueryDocumentSnapshot subCategoryDoc in subCategoriesSnapshot.docs) {
      String subCategory = subCategoryDoc.id;
      List<String> courses = [];

      // Fetch courses from the subcollection under each subcategory
      QuerySnapshot coursesSnapshot =
          await subCategoryDoc.reference.collection('courses').get();

      for (QueryDocumentSnapshot courseDoc in coursesSnapshot.docs) {
        courses.add(courseDoc.id);
      }

      subCategories[subCategory] = courses;
    }

    categories.add({category: subCategories});
  }

  return categories;
}

class CategoryExpansionTile extends StatefulWidget {
  final String category;
  final Map<String, List<String>> subCategories;

  const CategoryExpansionTile({
    required this.category,
    required this.subCategories,
  });

  @override
  _CategoryExpansionTileState createState() => _CategoryExpansionTileState();
}

class _CategoryExpansionTileState extends State<CategoryExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.category),
      children: widget.subCategories.entries
          .map((entry) => SubCategoryExpansionTile(
                subCategory: entry.key,
                courses: entry.value,
              ))
          .toList(),
    );
  }
}

class SubCategoryExpansionTile extends StatefulWidget {
  final String subCategory;
  final List<String> courses;

  const SubCategoryExpansionTile({
    required this.subCategory,
    required this.courses,
  });

  @override
  _SubCategoryExpansionTileState createState() =>
      _SubCategoryExpansionTileState();
}

class _SubCategoryExpansionTileState extends State<SubCategoryExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.subCategory),
      children: widget.courses
          .map((course) => GestureDetector(
                onTap: () async {
                  // Navigate to the book page when tapping on a course
                  Globals.courseName = course;
                  await downloadPDF("Sec. 4.3.pdf", books);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Library(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(course),
                ),
              ))
          .toList(),
    );
  }

  Future<File> downloadPDF(String fileName, List<Book> mybooks) async {
    try {
      print("hey2");
      // Get a reference to the file in Firebase Storage
      Reference reference =
          FirebaseStorage.instance.ref().child('pdfs/$fileName');

      // Get the temporary directory
      print("hey1");
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File tempFile = File('$tempPath/$fileName');

      // Download the file
      await reference.writeToFile(tempFile);
      print(tempFile.path);

      Book newBook = Book(
        title:
            "something", // You can set a default title or let the user choose
        author: Globals
            .userID, // You can set a default author or let the user choose
        rating: 0, // You can set a default rating or let the user choose
        pdfUrl: tempFile.path,
      );
      // Add the new book to the list of books
      books.add(newBook);

      // Return the downloaded file
      return tempFile;
    } catch (e) {
      print('Error downloading PDF: $e');
      throw e;
    }
  }
}
