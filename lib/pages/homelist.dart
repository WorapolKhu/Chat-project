import 'package:chatty/pages/chat.dart';
import 'package:chatty/pages/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:chatty/pages/myProfile.dart';

class HomeList extends StatelessWidget {
  const HomeList({super.key});

  @override
  Widget build(BuildContext context) {
    var avatar_color = Color(0xffdeebff);
    var icon_color = Colors.black;
    return Scaffold(
      appBar: AppBar(
          title: Container(
            padding: EdgeInsets.only(top: 40),
            alignment: Alignment.topLeft,
            child: Text('Name',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)),
          ),
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              padding: EdgeInsets.only(right: 30),
              icon: Icon(Icons.person, size: 40.0),
              onPressed: () {
                //Navigator.pushNamed(context, MyProfilePage.id);
              },
            )
          ]),
      body: SafeArea(
          child: ListView(children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.all(2),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade100))),
            // prefixIcon: Icon(Icons.search),
            // border: OutlineInputBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topLeft,
            child: Column(children: [
              Text("Friends"),
            ])),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatar_color,
              child: Icon(
                Icons.person_2_outlined,
                //size: 30.0,
                color: icon_color,
              )),
          title: Text("Friend 1"),
          // onTap: () {
          //   Navigator.pushNamed(context, ChatPage.id);
          // }
          subtitle: Text("ด่วนโทรมา ไม่ต้องทัก"),
          //trailing: arrow_icon,
        ),
        ListTile(
            leading: CircleAvatar(
                backgroundColor: avatar_color,
                child: Icon(
                  Icons.person_2_outlined,
                  color: icon_color,
                )),
            title: Text('Friend 2')
            //subtitle: Text('Chat history, theme, wallpapers'),
            // trailing: arrow_icon,
            ),
        ListTile(
            leading: CircleAvatar(
                backgroundColor: avatar_color,
                child: Icon(
                  Icons.person_2_outlined,
                  color: icon_color,
                )),
            title: Text('Friend 3')
            // subtitle: Text('Messages, group and others'),
            // trailing: arrow_icon,
            ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatar_color,
              child: Icon(
                Icons.person_2_outlined,
                color: icon_color,
              )),
          title: Text('Friend 4'),
          // subtitle: Text('Delete friend'),
          // trailing: arrow_icon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatar_color,
              child: Icon(
                Icons.person_2_outlined,
                color: icon_color,
              )),
          title: Text('Friend 5'),
          // subtitle: Text('Help center, contact us, privacy policy'),
          // trailing: arrow_icon,
        ),
      ])),
    );
  }
}
