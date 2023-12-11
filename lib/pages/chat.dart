import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _store = FirebaseFirestore.instance;
User? loggedInUser;
late var refId;
String? otherUser;
String? otherUserName;

class ChatPage extends StatefulWidget {
  static String id = 'chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  final fieldController = TextEditingController();
  late String textMessage;
  // get current user and other user name that is in the chat room
  Future<void> getCurrentUser() async {
    loggedInUser = await _auth.authStateChanges().first;
    await _store.collection('chatList').doc(refId).get().then((value) {
      final usersInChat = value.data() as Map<String, dynamic>;
      usersInChat.forEach((key, value) {
        if (value is List) {
          for (var user in value) {
            if (user != loggedInUser?.email) {
              otherUser = user;
            }
          }
        }
      });
    });
    QuerySnapshot otherUserInfo = await _store
        .collection('users')
        .where('email', isEqualTo: otherUser)
        .get();
    Map<String, dynamic> otherUserInfoData =
        otherUserInfo.docs[0].data() as Map<String, dynamic>;
    otherUserName = otherUserInfoData['name'];
    return;
  }

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      refId = route.settings.arguments;
      refId = refId.id;
    }
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: FutureBuilder(
                future: getCurrentUser(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Text(otherUserName ?? '');
                })),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MessagesStream(),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: fieldController,
                    onChanged: (value) {
                      textMessage = value;
                    },
                    decoration: InputDecoration(
                        hintText: 'Aa',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 3.0))),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      if (textMessage.isNotEmpty) {
                        _store
                            .collection('chatList')
                            .doc(refId)
                            .collection('message')
                            .add({
                          'sender': loggedInUser?.email,
                          'text': textMessage,
                          'created_at': DateTime.now().millisecondsSinceEpoch
                        });
                        fieldController.clear();
                        textMessage = '';
                      }
                    },
                    child: const Text('Send')),
              ]),
            ],
          ),
        ));
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _store
          .collection('chatList')
          .doc(refId)
          .collection('message')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
        if (snapshot.data == null || snapshot.data!.size == 0) {
          return const Column(
            children: [
              Text(
                'Let\'s start a new conversation.',
                style: TextStyle(fontSize: 20),
              ),
              Icon(
                Icons.send_outlined,
                size: 100,
                color: Color(0x2f000000),
              )
            ],
          );
        }
        if (snapshot.hasData) {
          return Expanded(
            child: ListView(
              reverse: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return MessageBubble(
                    sender: data['sender'],
                    text: data['text'],
                    isMe: loggedInUser?.email == data['sender']);
              }).toList(),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.isMe});
  final String sender;
  final String text;
  final bool isMe;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: widget.isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: widget.isMe ? Colors.blue : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
