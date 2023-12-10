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

  Future<void> getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedInUser = user;
      }
    });
  }

  Future<String> getDisplayName(String email) async {
    var tmp =
        await _store.collection('users').where('email', isEqualTo: email).get();
    Map<String, dynamic> otherUserInfoData = tmp.docs[0].data();

    return await otherUserInfoData['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(top: 40),
          alignment: Alignment.center,
          child: const Text(
            'Chat',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: Column(
        children: [
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
                                    title: FutureBuilder(
                                        future: getDisplayName(otherUserEmail),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('...');
                                          }
                                          return Text(snapshot.data ?? '');
                                        }),
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
                                  title: FutureBuilder(
                                      future: getDisplayName(otherUserEmail),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text('');
                                        }
                                        return Text(snapshot.data ?? '');
                                      }),
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
