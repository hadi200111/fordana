import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'ChatProvider.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String currentUserId;

  ChatScreen({
    required this.chatId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final ScrollController scrollController = ScrollController();
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Chat',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Messages>>(
              stream: chatProvider.getChatMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<Messages> messages = snapshot.data!;

                // Scroll to the bottom when new messages are added
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Messages message = messages[index];
                    bool isSentByMe = message.senderId == currentUserId;
                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              isSentByMe ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                              20), // Increased border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!isSentByMe)
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(
                                        'https://fastly.picsum.photos/id/40/4106/2806.jpg?hmac=MY3ra98ut044LaWPEKwZowgydHZ_rZZUuOHrc3mL5mI'),
                                  ),
                                if (!isSentByMe) SizedBox(width: 8),
                                Text(
                                  message.senderId,
                                  style: TextStyle(
                                    color: isSentByMe
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              message.getFormattedDate(),
                              style: TextStyle(
                                color: isSentByMe
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      String text = messageController.text.trim();
                      if (text.isNotEmpty) {
                        Messages message = Messages(
                          id: '', // Firestore will generate an ID
                          senderId: currentUserId,
                          text: text,
                          timestamp: Timestamp.now(),
                        );
                        chatProvider.sendMessage(chatId, message);
                        messageController.clear();

                        // Scroll to the bottom after sending a message
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (scrollController.hasClients) {
                            scrollController.jumpTo(
                              scrollController.position.maxScrollExtent,
                            );
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
