import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String userName;
  final String userImageUrl;
  final String? postImageUrl;
  final String caption;
  int likeCounter;
  List<String> comments;
  List<String> readby;
  final String? id;
  List<String> likedby;
  String? postVisability;
  DateTime publishDate;

  Posts(
      {this.id,
      required this.userName,
      required this.userImageUrl,
      this.postImageUrl,
      required this.caption,
      required this.likeCounter,
      required this.comments,
      required this.readby,
      required this.likedby,
      required this.postVisability,
      required this.publishDate});
}
