import 'package:CampusConnect/WelocomeLogIn/LogInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:CampusConnect/Posts.dart';
import 'package:intl/intl.dart';

class PostWidget extends StatefulWidget {
  final Posts post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likedby.contains(Globals.userNumber);
    formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(widget.post.publishDate);
  }

  Future<void> _updateLikeStatus() async {
    setState(() {
      if (_isLiked) {
        widget.post.likeCounter--;
        widget.post.likedby.remove(Globals.userNumber);
      } else {
        widget.post.likeCounter++;
        widget.post.likedby.add(Globals.userNumber);
      }
      _isLiked = !_isLiked;
    });

    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id)
        .update({
      'likeCounter': widget.post.likeCounter,
      'likedby': widget.post.likedby,
    });
  }

  void _showCommentsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.post.comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(widget.post.comments[
                            index]), // Assuming you want to display the same date for each comment
                      );
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                    ),
                    onSubmitted: (value) async {
                      setState(() {
                        widget.post.comments.add(Globals.userID +
                            " " +
                            Globals.userNumber +
                            ": " +
                            value +
                            DateFormat('yyyy-MM-dd – kk:mm')
                                .format(DateTime.now()));
                      });
                      await FirebaseFirestore.instance
                          .collection('Posts')
                          .doc(widget.post.id)
                          .update({
                        'comments': widget.post.comments,
                      });
                      Navigator.pop(
                          context); // Close the dialog after adding comment
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8,
      shadowColor: Colors.deepPurple.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.post.userImageUrl),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.post.caption,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[800],
              ),
            ),
          ),
          if (widget.post.postImageUrl != null &&
              widget.post.postImageUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                    color: Colors.black, width: 2.0), // Black border here
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  widget.post.postImageUrl!,
                  fit: BoxFit.cover,
                  height: 200, // Adjust height as needed
                ),
              ),
            ),
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color:
                            _isLiked ? Colors.deepPurple.shade200 : Colors.grey,
                      ),
                      onPressed: _updateLikeStatus,
                    ),
                    Text(
                      '${widget.post.likeCounter}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.comment,
                    color: Colors.grey[600],
                  ),
                  onPressed: _showCommentsDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
