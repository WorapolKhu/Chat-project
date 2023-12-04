import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _store = FirebaseFirestore.instance;
late User loggedInUser;
late var refId;

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

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedInUser = user;
      }
    });
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
          title: Center(child: Text(loggedInUser.displayName as String)),
          automaticallyImplyLeading: false,
        ),
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
                  ),
                ),
                TextButton(
                    onPressed: () {
                      _store
                          .collection('chatList')
                          .doc(refId)
                          .collection('message')
                          .add({
                        'sender': loggedInUser.email,
                        'text': textMessage,
                        'created_at': DateTime.now().millisecondsSinceEpoch
                      });
                      fieldController.clear();
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
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
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
            color: isMe ? Colors.pinkAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
