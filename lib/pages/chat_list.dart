import 'package:chatty/pages/chat.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, ChatPage.id);
              },
              child: Text('To chat page'))
        ],
      )),
    );
  }
}
