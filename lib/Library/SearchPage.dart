import 'package:flutter/material.dart';
import 'package:CampusConnect/Library/LibraryPage.dart';

/// Flutter code sample for [SearchBar].

//void main() => runApp(const SearchBarApp());

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  Map<String, Map<String, List<String>>> _categories = {
    'Engineering': {
      'Mechanical Engineering': ['Course 1', 'Course 2'],
      'Civil Engineering': ['Course 3', 'Course 4'],
    },
    'Science': {
      'Physics': ['Course 5', 'Course 6'],
      'Chemistry': ['Course 7', 'Course 8'],
    },
    'Arts': {
      'Design': ['Course 1', 'Course 2'],
      'Music': ['Course 3', 'Course 4'],
    },
    'Commerce': {
      'Marketing': ['Course 5', 'Course 6'],
      'Business': ['Course 7', 'Course 8'],
    },
    'Literature': {
      'Arabic': ['Course 5', 'Course 6'],
      'English': ['Course 7', 'Course 8'],
    },
    'Information Technology': {
      'Computer Science': ['Course 5', 'Course 6'],
      'Cyber Security': ['Course 7', 'Course 8'],
      'Electrical Engineering': ['Java', 'Course'],
    },
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Bar Sample')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
                String searchQuery =
                    'Course 5'; // The value you want to search for

// Iterate through the outer map's keys and values
                _categories.forEach((category, subCategories) {
                  // Check if the search query matches the category
                  if (category.contains(searchQuery)) {
                    // If it matches, do something with the category
                    print('Found matching category: $category');
                  }

                  // Iterate through the inner map's keys and values
                  subCategories.forEach((subCategory, courses) {
                    // Check if the search query matches the subcategory
                    if (subCategory.contains(searchQuery)) {
                      // If it matches, do something with the subcategory
                      print('Found matching subcategory: $subCategory');
                    }

                    // Iterate through the list of courses
                    courses.forEach((course) {
                      // Check if the search query matches any course
                      if (course.contains(searchQuery)) {
                        // If it matches, do something with the course
                        print('Found matching course: $course');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LibraryPage()),
                        );
                      }
                    });
                  });
                });
                print("hey");
              },
              onChanged: (_) {
                controller.openView();
                print("hey1");
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                Tooltip(
                  message: 'Change brightness mode',
                  child: IconButton(
                    isSelected: isDark,
                    onPressed: () {
                      setState(() {
                        isDark = !isDark;
                      });
                    },
                    icon: const Icon(Icons.wb_sunny_outlined),
                    selectedIcon: const Icon(Icons.brightness_2_outlined),
                  ),
                )
              ],
            );
          }, suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          }),
        ),
      ),
    );
  }
}
