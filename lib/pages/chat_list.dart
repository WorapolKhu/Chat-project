import 'package:chatty/pages/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _store = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedInUser = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Chat')),
      ),
      body: SafeArea(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          FutureBuilder(
              future: getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                return StreamBuilder(
                    stream: _store
                        .collection('chatList')
                        .where('users', arrayContains: loggedInUser?.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      var chatRooms = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          var chatRoom = chatRooms[index];
                          var users = chatRoom['users'] as List<dynamic>;

                          // Find the other user in the chat room
                          //TODO: change to Username
                          var otherUserEmail = users.firstWhere(
                              (email) => email != loggedInUser?.email);
                          return StreamBuilder(
                              stream: chatRoom.reference
                                  .collection('message')
                                  .orderBy('created_at', descending: true)
                                  .limit(1)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return ListTile(
                                    title: Text(otherUserEmail),
                                    subtitle: const Text('Start chat now!'),
                                    onTap: () {
                                      Navigator.pushNamed(context, ChatPage.id,
                                          arguments: chatRoom.reference);
                                    },
                                  );
                                }
                                var latestMessage = snapshot.data!.docs.first;
                                var messageData = latestMessage.data();
                                return ListTile(
                                  title: Text(otherUserEmail),
                                  subtitle: Text(messageData['text']),
                                  onTap: () {
                                    Navigator.pushNamed(context, ChatPage.id,
                                        arguments: chatRoom.reference);
                                  },
                                );
                              });
                        },
                      );
                    });
              }),
        ],
      )),
    );
  }
}
