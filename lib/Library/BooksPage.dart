import 'package:flutter/material.dart';

class BooksPage extends StatefulWidget {
  final String major;
  final List<String> books;

  BooksPage({
    required this.major,
    required this.books,
  });

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late String _major;
  late List<String> _books;

  @override
  void initState() {
    super.initState();
    _major = widget.major;
    _books = List.from(widget.books);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Books - $_major',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (BuildContext context, int index) {
          final book = _books[index];
          return ListTile(
            title: Text(book),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addBook(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _addBook(BuildContext context) {
    String newBookName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add New Book',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            onChanged: (value) {
              newBookName = value;
            },
            decoration: InputDecoration(
              labelText: 'Book Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _books.add(newBookName);
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
