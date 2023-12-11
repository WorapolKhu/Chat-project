import 'package:chatty/pages/home_list.dart';
import 'package:chatty/pages/setting.dart';
import 'package:chatty/pages/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:chatty/pages/addfriend.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String id = 'Home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currIndex = 0;
  final PageController _controller = PageController();
  void _onTabTapped(int index) {
    _controller.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1), label: 'Add friend'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      body: SafeArea(
          child: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currIndex = index;
          });
        },
        children: const [
          HomeList(),
          AddFriendPage(),
          ChatList(),
          SettingPage(),
        ],
      )),
    );
  }
}
