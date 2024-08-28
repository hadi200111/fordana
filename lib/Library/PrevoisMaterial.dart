import 'package:flutter/material.dart';
import 'AddCategoryDialog.dart';
import 'CategoryTile.dart';

class PreviousMaterial extends StatefulWidget {
  const PreviousMaterial({Key? key}) : super(key: key);

  @override
  _PreviousMaterialState createState() => _PreviousMaterialState();
}

class _PreviousMaterialState extends State<PreviousMaterial> {
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
    return Scaffold(
      appBar: AppBar(
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
              // Handle search action
            },
          ),
        ],
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = _categories.keys.elementAt(index);
          return CategoryTile(
            category: category,
            majors: _categories[category]!,
          );
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
