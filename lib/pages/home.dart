import 'package:chatty/pages/chat_list.dart';
import 'package:flutter/material.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'page 1'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'page 2'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'page 3'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'page 4'),
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
          Text('Page 1 '),
          Text('Page 2'),
          ChatList(),
          Text('Page 4')
        ],
      )),
    );
  }
}
