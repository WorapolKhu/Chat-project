import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  static String id = 'edit_profile';
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  late User loggedInUser;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Retrieve user data from Firestore
      DocumentSnapshot userSnapshot =
          await _store.collection('users').doc(user.uid).get();

      if (userSnapshot.exists) {
        // Extract user information from the Firestore document
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        setState(() {
          loggedInUser = user;
          _usernameController.text = userData['name'] ?? 'NA';
          _emailController.text = userData['email'] ?? 'NA';
        });
      }
    }
  }

  void updateProfile() async {
    try {
      await loggedInUser.updateDisplayName(_usernameController.text);

      await _store.collection('users').doc(loggedInUser.uid).update({
        'name': _usernameController.text,
        'email': _emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 10),
                  )
                ],
                shape: BoxShape.circle,
              ),
              // Use CircleAvatar with an icon instead of Image.asset
              child: CircleAvatar(
                backgroundColor: Colors.transparent, // Set background color
                child: Icon(Icons.person_outline,
                    color: Colors.black26, size: 100), // Icon and its color
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // reset the text fields to the current user's data
                    getCurrentUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Changes discarded.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: updateProfile,
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
