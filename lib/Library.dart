import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CampusConnect/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'WelocomeLogIn/LogInPage.dart';

class Book {
  final String title;
  final String author;
  final double rating;
  final String pdfUrl;

  Book({
    required this.title,
    required this.author,
    required this.rating,
    required this.pdfUrl,
  });

  factory Book.fromDocument(String title, DocumentSnapshot doc) {
    return Book(
      title: title,
      author: doc['author'],
      rating: doc['rating'].toDouble(),
      pdfUrl: doc['pdfUrl'],
    );
  }
}

List<Book> books = [
  Book(
    title: "Book 1",
    author: "Author 1",
    rating: 4.5,
    pdfUrl: "/storage/emulated/0/Download/SecondReport.pdf",
  ),
  Book(
    title: "Book 2",
    author: "Author 2",
    rating: 3.8,
    pdfUrl: "/storage/emulated/0/Download/SecondReport.pdf",
  ),
];

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<Library> {
  Uint8List? _pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[300],
      appBar: AppBar(
        title: Text('Library Page'),
        actions: [
          if (Globals.roll == "Doctor")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Book',
              onPressed: () async {
                await _pickAndSetPdf();
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return BookItem(book: book);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSetPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfBytes = result.files.single.bytes;
        // Create a new Book instance
        Book newBook = Book(
          title: result.files.single
              .name, // You can set a default title or let the user choose
          author: Globals
              .userID, // You can set a default author or let the user choose
          rating: 0, // You can set a default rating or let the user choose
          pdfUrl: result.files.single.path!,
        );
        // Add the new book to the list of books
        books.add(newBook);
      });
    } else {
      // User canceled the picker
    }
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String mycourse = Globals.courseName;
      Reference reference =
      FirebaseStorage.instance.ref().child('$mycourse/$fileName');
      UploadTask uploadTask = reference.putFile(file);
      await uploadTask.whenComplete(() => print('File uploaded'));
    } else {
      // User canceled the picker
    }
  }
}

class BookItem extends StatelessWidget {
  final Book book;

  const BookItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          book.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              "Author: ${book.author}",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                SizedBox(width: 4),
                Text(
                  "${book.rating}",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.picture_as_pdf,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerPage(pdfUrl: book.pdfUrl),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _isLoading = true;
  bool _fileNotFound = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        PermissionStatus status = await Permission.storage.request();
        if (!status.isGranted) {
          throw 'Storage permission is required to view PDF files.';
        }
      }
      // For iOS, handle file access permissions accordingly
    } catch (e) {
      print('Error checking permissions: $e');
      // Handle permission errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('PDF Viewer'),
      ),
      body: _fileNotFound
          ? Center(
        child: Text('File not found.'),
      )
          : Stack(
        children: [
          PDFView(
            filePath: widget.pdfUrl,
            onRender: (pages) {
              setState(() {
                _isLoading = false;
              });
            },
            onError: (error) {
              print(error.toString());
              setState(() {
                _fileNotFound = true;
                _isLoading = false;
              });
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
          ),
          _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container(),
        ],
      ),
    );
  }
}
