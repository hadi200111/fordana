import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../api/push_notifications_services.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Chat>> getUserChats(String userId) {
    print('Fetching chats for user: $userId');
    return _firestore
        .collection('chats')
        .where('users', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      print('Chats fetched for user: $userId');
      return snapshot.docs.map((doc) => Chat.fromDocument(doc)).toList();
    });
  }

  Stream<List<Messages>> getChatMessages(String chatId) {
    print('Fetching messages for chat: $chatId');
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      print('Messages fetched for chat: $chatId');
      return snapshot.docs.map((doc) => Messages.fromDocument(doc)).toList();
    });
  }

  Future<void> sendMessage(String chatId, Messages message) async {
    print('Sending message in chat: $chatId');
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    print('Message sent, updating lastMessageTime for chat: $chatId');
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({'lastMessageTime': message.timestamp});
    print('lastMessageTime updated for chat: $chatId');

    await sendChatNotification(chatId, message.senderId, message.text);
  }

  Future<String> createChat(List<String> users) async {
    print('Creating chat for users: $users');
    QuerySnapshot querySnapshot = await _firestore
        .collection('chats')
        .where('users', arrayContains: users[0])
        .get();

    for (var doc in querySnapshot.docs) {
      List<dynamic> userList = doc['users'];
      if (userList.contains(users[1])) {
        print('Chat already exists for users: $users');
        return doc.id;
      }
    }

    print('No existing chat found, creating a new chat for users: $users');
    DocumentReference chatRef = await _firestore.collection('chats').add({
      'users': users,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'courseId': null,
    });
    print('New chat created with ID: ${chatRef.id} for users: $users');
    return chatRef.id;
  }

  /////////  Notifications here /////////
  Future<void> sendChatNotification(
      String chatId, String senderName, String messageContent) async {
    // Example: Send notification using PushNotificationsService
    String recipientDeviceToken =
        'ctuvqfdmTOGVfOFlAABPEf:APA91bEfwGgNyZp9hUoL5woBKSNN_nyacutx6qzocF5ebRLbcZb6yOvTnFGwg81Pk-_2NIeZBgh4fkue_n14Yhgy62g6uY7U8VYcQsXr39HVM6y-lT8Mn1jmBtp_4M0eQgZwYZ5zGXDS';
    //await getRecipientDeviceToken(chatId);
    print(recipientDeviceToken + " hahahahahahhahhahahaha");
    String title = 'New message from $senderName';
    String body = messageContent;

    // Call your notification service to send the notification
    await PushNotificationsServices.sendNotification(
        recipientDeviceToken, title, body);
  }

  Future<String> getRecipientDeviceToken(String recipientUserId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(recipientUserId)
          .get();

      // Check if the document exists and has the recipientUserId field
      if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('recipientUserId')) {
          return data['recipientUserId'];
        } else {
          // Handle case where recipientUserId field is missing
          print('Recipient user document does not contain recipientUserId');
          return ''; // Or handle default value/error condition as needed
        }
      } else {
        // Handle case where document doesn't exist or data is not of expected type
        print('Recipient user document not found or data format incorrect');
        return ''; // Or handle default value/error condition as needed
      }
    } catch (e) {
      print('Error fetching recipient device token: $e');
      return ''; // Or handle error condition
    }
  }

  //////////////// End here ////////////////

  Future<String> createGroupChat(String courseId, String doctorId) async {
    print('Creating group chat for course: $courseId');

    // Check if a group chat with this courseId already exists
    QuerySnapshot querySnapshot = await _firestore
        .collection('chats')
        .where('courseId', isEqualTo: courseId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print('Group chat already exists for course: $courseId');
      return 'Group chat already exists for this course.';
    }

    // Create a new group chat
    DocumentReference chatRef = await _firestore.collection('chats').add({
      'users': [doctorId],
      'courseId': courseId,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    // Update the course document with the new chatId
    await _firestore.collection('courses').doc(courseId).update({
      'chatId': chatRef.id,
    });

    print(
        'New group chat created with ID: ${chatRef.id} for course: $courseId');
    return chatRef.id;
  }

  Future<void> addUserToGroupChat(String courseId, String userId) async {
    try {
      print('Adding user: $userId to group chat for course: $courseId');
      QuerySnapshot chatQuery = await _firestore
          .collection('chats')
          .where('courseId', isEqualTo: courseId)
          .get();

      if (chatQuery.docs.isEmpty) {
        print('Group chat not found for courseId: $courseId');
        return;
      }

      DocumentSnapshot chatDoc = chatQuery.docs.first;
      print('Group chat found for courseId: $courseId, adding user: $userId');
      await chatDoc.reference.update({
        'users': FieldValue.arrayUnion([userId]),
      });
      print('User: $userId added to group chat for courseId: $courseId');
    } catch (e) {
      print('Error adding user to group chat: $e');
    }
  }

  Stream<List<Chat>> getGroupChats(String userId) async* {
    print('Fetching group chats for user: $userId');
    QuerySnapshot coursesSnapshot = await _firestore
        .collection('courses')
        .where('students', arrayContains: userId)
        .get();

    List<String> courseChatIds = coursesSnapshot.docs
        .where((doc) => doc['chatId'] != null)
        .map((doc) => doc['chatId'] as String)
        .toList();

    print('Course chat IDs fetched for user: $userId - $courseChatIds');
    Stream<List<Chat>> groupChats = _firestore
        .collection('chats')
        .where(FieldPath.documentId,
            whereIn: courseChatIds.isNotEmpty ? courseChatIds : ['dummy'])
        .snapshots()
        .map((snapshot) {
      print('Group chats fetched for user: $userId');
      return snapshot.docs.map((doc) => Chat.fromDocument(doc)).toList();
    });

    yield* groupChats;
  }

  Future<void> deleteChat(String chatId) async {
    print('Deleting chat: $chatId');
    await _firestore.collection('chats').doc(chatId).delete();
    notifyListeners();
  }
}

class Messages {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  Messages(
      {required this.id,
      required this.senderId,
      required this.text,
      required this.timestamp});

  factory Messages.fromDocument(DocumentSnapshot doc) {
    print('Creating Messages from document: ${doc.id}');
    return Messages(
      id: doc.id,
      senderId: doc['senderId'],
      text: doc['text'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    print('Converting Messages to map for ID: $id');
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }

  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());
  }
}

class Chat {
  final String id;
  final List<String> users;
  final String? courseId;
  final Timestamp lastMessageTime;

  Chat(
      {required this.id,
      required this.users,
      required this.courseId,
      required this.lastMessageTime});

  factory Chat.fromDocument(DocumentSnapshot doc) {
    print('Creating Chat from document: ${doc.id}');
    return Chat(
      id: doc.id,
      users: List<String>.from(doc['users']),
      courseId: doc['courseId'],
      lastMessageTime: doc['lastMessageTime'],
    );
  }

  Map<String, dynamic> toMap() {
    print('Converting Chat to map for ID: $id');
    return {
      'users': users,
      'courseId': courseId,
      'lastMessageTime': lastMessageTime,
    };
  }
}
