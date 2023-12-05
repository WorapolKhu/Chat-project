import 'package:chatty/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  static String id = 'Setting';

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currIndex = 0;
  final PageController _controller = PageController();
  void _onTabTapped(int index) {
    _controller.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

void signOut(BuildContext context) {
    _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    var avatar_color = Color(0xffdeebff);
    var icon_color = Colors.black;
    var arrow_icon = Icon(Icons.arrow_forward_ios);
    return Scaffold(
      appBar:AppBar(automaticallyImplyLeading: false,backgroundColor: Color(0xff4BA7FB), title: Center(child: Text("Setting",style: (TextStyle(color: Colors.black)),),)),
      body: SafeArea(
        child: ListView(
        children: [
          SizedBox(height: 20,),ListTile(
          leading: CircleAvatar(radius: 30, backgroundColor: avatar_color), title: Text("Profile"), trailing: arrow_icon,)
          ,Divider(thickness: 1.5,),ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.key_outlined, color: icon_color,)),title: Text("Account"),subtitle: Text("Privacy, security, change number"), trailing: arrow_icon,)
        ,ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.chat_bubble_outline, color: icon_color,)),title: Text('Chat'),subtitle: Text('Chat history, theme, wallpapers'), trailing: arrow_icon,)
        ,ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.notification_add_outlined, color: icon_color,)),title: Text('Notifications'),subtitle: Text('Messages, group and others'), trailing: arrow_icon,)
        ,ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.person_2_outlined, color: icon_color,)),title: Text('Friends'),subtitle: Text('Delete friend'), trailing: arrow_icon,)
        ,ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.question_mark_outlined, color: icon_color,)),title: Text('Help'),subtitle: Text('Help center, contact us, privacy policy'),trailing: arrow_icon,)
        ,ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.storage_outlined, color: icon_color,)),title: Text('Storage and data'),subtitle: Text('Network usage, storage usage'),trailing: arrow_icon,)
        ,ListTile(leading: CircleAvatar(backgroundColor: avatar_color, child: Icon(Icons.logout_outlined, color: icon_color,)),title: Text('Logout'),subtitle: Text('Logout from your account'),trailing: arrow_icon, onTap: () {signOut(context);},)
        ]
        )
      ),
    );
  }
}
