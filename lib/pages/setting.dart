import 'package:chatty/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatty/pages/editProfile.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  static String id = 'Setting';

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut(BuildContext context) {
    _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    var avatarColor = const Color(0xffdeebff);
    var iconColor = Colors.black;
    var arrowIcon = const Icon(Icons.arrow_forward_ios);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(top: 40),
          alignment: Alignment.center,
          child: Text(
            'Setting',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: ListView(children: [
        SizedBox(
          height: 20,
        ),
        ListTile(
          leading: CircleAvatar(radius: 30, backgroundColor: avatarColor),
          title: Text("Profile"),
          trailing: arrowIcon,
          onTap: () {
            Navigator.pushNamed(
              context,
              EditProfilePage.id,
            );
          },
        ),
        Divider(
          thickness: 1.5,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.key_outlined,
                color: iconColor,
              )),
          title: Text("Account"),
          subtitle: Text("Privacy, security, change number"),
          trailing: arrowIcon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.chat_bubble_outline,
                color: iconColor,
              )),
          title: Text('Chat'),
          subtitle: Text('Chat history, theme, wallpapers'),
          trailing: arrowIcon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.notification_add_outlined,
                color: iconColor,
              )),
          title: Text('Notifications'),
          subtitle: Text('Messages, group and others'),
          trailing: arrowIcon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.person_2_outlined,
                color: iconColor,
              )),
          title: Text('Friends'),
          subtitle: Text('Delete friend'),
          trailing: arrowIcon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.question_mark_outlined,
                color: iconColor,
              )),
          title: Text('Help'),
          subtitle: Text('Help center, contact us, privacy policy'),
          trailing: arrowIcon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.storage_outlined,
                color: iconColor,
              )),
          title: Text('Storage and data'),
          subtitle: Text('Network usage, storage usage'),
          trailing: arrowIcon,
        ),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(
                Icons.logout_outlined,
                color: iconColor,
              )),
          title: Text('Logout'),
          subtitle: Text('Logout from your account'),
          trailing: arrowIcon,
          onTap: () {
            signOut(context);
          },
        )
      ])),
    );
  }
}
