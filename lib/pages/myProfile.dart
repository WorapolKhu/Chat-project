import 'package:flutter/material.dart';
// import 'package:chatty/pages/setting.dart';
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
        final displayName = user.displayName;
        final email = user.email;
        final phoneNumber = user.phoneNumber;

        userData = {
          'uid': uid,
          'displayName': displayName,
          'email': email,
          'phoneNumber': phoneNumber,
        };

        setState(() => {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pushNamed(context, SettingPage.id);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Username: ${userData['displayName']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${userData['email']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone Number: ${userData['phoneNumber']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
