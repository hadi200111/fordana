import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../WelocomeLogIn/LogInPage.dart';
import 'ChatProvider.dart';
import 'ChatScreen.dart';
import 'package:rxdart/rxdart.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  ChatListScreen({required this.currentUserId});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String dropdownValue = Globals.Schedule.first;
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    Globals.Schedule.remove("Public");
    Globals.Schedule.remove("Private");

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
        actions: [
          if (Globals.roll == "Doctor")
            IconButton(
              icon: Icon(Icons.group, color: Colors.white70),
              iconSize: 28,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Open Course Chat'),
                      content: DropdownButton<String>(
                        value: dropdownValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            chatProvider.createGroupChat(
                                dropdownValue, Globals.userID);
                          });
                          Navigator.of(context).pop();
                        },
                        items: Globals.Schedule.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(value),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Chats',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.all(16.0),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: CombineLatestStream.combine2(
                chatProvider.getUserChats(widget.currentUserId),
                chatProvider.getGroupChats(widget.currentUserId),
                (List<Chat> userChats, List<Chat> groupChats) {
                  List<Chat> combinedChats = [...userChats, ...groupChats];
                  return combinedChats;
                },
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No chats available'));
                }

                List<Chat> chats = snapshot.data!.where((chat) {
                  String chatTitle;
                  if (chat.courseId != null) {
                    chatTitle = chat.courseId.toString();
                  } else {
                    chatTitle = chat.users
                        .firstWhere((user) => user != widget.currentUserId);
                  }
                  return chatTitle.toLowerCase().contains(searchText);
                }).toList();

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    Chat chat = chats[index];
                    String chatTitle;
                    if (chat.courseId != null) {
                      chatTitle = chat.courseId.toString();
                    } else {
                      chatTitle = chat.users
                          .firstWhere((user) => user != widget.currentUserId);
                    }

                    return GestureDetector(
                      onLongPressStart: (details) {
                        if (Globals.roll == "Doctor" && chat.courseId != null) {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      leading:
                                          Icon(Icons.delete, color: Colors.red),
                                      title: Text('Delete Chat'),
                                      onTap: () {
                                        chatProvider.deleteChat(chat.id);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            // Prevent the tap on the ListTile from triggering navigation
                            enableDrag: false,
                            isDismissible: false,
                            // Ensure that the modal bottom sheet stays open until an action is taken
                          );
                        }
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('images/chat.png'),
                        ),
                        title: Text(
                          chatTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                            'Last message at ${chat.lastMessageTime.toDate()}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chat.id,
                                currentUserId: widget.currentUserId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
