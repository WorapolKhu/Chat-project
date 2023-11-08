import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  static String id = 'chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  late String? loggedInUser;
  String message = '';
  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedInUser = user.email;
        print(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              message = value;
            },
          ),
          TextButton(
              onPressed: () {
                getCurrentUser();
                print(loggedInUser);
              },
              child: Text('Send message'))
        ],
      ),
    ));
  }
}
