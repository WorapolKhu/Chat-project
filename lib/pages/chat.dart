import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _store = FirebaseFirestore.instance;
late User loggedInUser;

class ChatPage extends StatefulWidget {
  static String id = 'chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  late String textMessage;
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    getStream();
  }

  void getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedInUser = user;
      }
    });
  }

  void getStream() async {
    await for (var snapshot in _store
        .collection('message')
        .orderBy('created_at', descending: false)
        .snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data()['text']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MessagesStream(),
          Row(children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  textMessage = value;
                },
              ),
            ),
            TextButton(
                onPressed: () {
                  getCurrentUser();
                  _store.collection('message').add({
                    'sender': loggedInUser.email,
                    'text': textMessage,
                    'created_at': DateTime.now().millisecondsSinceEpoch
                  });
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
          .collection('message')
          .orderBy('created_at', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
        if (snapshot.hasData) {
          return Expanded(
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return MessageBubble(
                    sender: data['sender'],
                    text: data['text'],
                    isMe: loggedInUser.email == data['sender']);
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

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.isMe});
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.green : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
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
