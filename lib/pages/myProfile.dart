import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});
  static String id = 'myProfile';

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> userData = {};

  void getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        final uid = user.uid;
        final displayName = user.displayName ?? 'Null';
        final email = user.email ?? 'Null';
        final picture = user.photoURL ?? '';

        userData = {
          'uid': uid,
          'displayName': displayName,
          'email': email,
          'picture': picture,
        };

        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    var bgColor = Colors.white;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: const Color(0xff4BA7FB),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage(userData['picture'] ?? const Color(0xffdeebff)),
            ),
            const SizedBox(height: 30),
            const Text(
              'Username',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${userData['displayName']}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${userData['email']}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
