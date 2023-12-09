import 'package:flutter/material.dart';

class FriendProfile extends StatelessWidget {
  static String id = 'friend_profile';
  Column buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.black,
          size: 50,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return MaterialApp(
      title: 'Proplie',
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*Wallpaper(),*/
            CircleAvatar(
              maxRadius: 100,
              child: Image(
                  image: AssetImage("assets/images/profilePic_symbol.png")),
            ),
            SizedBox(height: 10),
            Text(
              "name",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButtonColumn(color, Icons.chat, 'Chat'),
                buildButtonColumn(
                    color, Icons.person_add_disabled_outlined, 'Unfriend'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*Widget Wallpaper() {
  return DrawerHeader(
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/SE_wallpaper.jpg'))),
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 18,
        )
      ],
    ),
  );
}*/