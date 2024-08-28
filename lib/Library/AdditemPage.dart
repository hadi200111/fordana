import 'package:flutter/material.dart';

class AddItemPage extends StatelessWidget {
  final Map<String, Map<String, List<String>>> categories;
  final Function(String college, String major, String book) onAddItem;

  AddItemPage({required this.categories, required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    String newCollege = '';
    String newMajor = '';
    String newBook = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Item',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                newCollege = value;
              },
              decoration: InputDecoration(
                labelText: 'College Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                newMajor = value;
              },
              decoration: InputDecoration(
                labelText: 'Major Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                newBook = value;
              },
              decoration: InputDecoration(
                labelText: 'Book Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (categories.containsKey(newCollege)) {
                  if (categories[newCollege]!.containsKey(newMajor)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Major Already Exists'),
                          content: Text('The major $newMajor already exists.'),
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
                    onAddItem(newCollege, newMajor, newBook);
                    Navigator.pop(context);
                  }
                } else {
                  onAddItem(newCollege, newMajor, newBook);
                  Navigator.pop(context);
                }
              },
              child: Text('Add Item'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
