import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A page for editing user profile information.
// This page allows the user to edit their profile information.
// It is a stateful widget that extends [StatefulWidget] and provides a [createState] method to create the corresponding state object.
class EditProfilePage extends StatefulWidget {
  static String id = 'edit_profile';
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

// The state class for the EditProfilePage widget.
// This class manages the state of the EditProfilePage widget, including the current user, text editing controllers for the username and email fields, and methods for retrieving the current user's data and updating the profile.
// if updates are successful show a snackbar with a success message, otherwise show a snackbar with a failure message.
class EditProfilePageState extends State<EditProfilePage> {
  // Firebase authentication and Firestore instances
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  // The current user
  late User loggedInUser;

  // Text editing controllers for the username and email fields.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Initializes the state of the widget.
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // Retrieves the current user's data from Firestore based on their email address and updates the UI with that information.
  // If the user's email is not found, do nothing.
  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Retrieve user data from Firestore based on email
      QuerySnapshot userSnapshot = await _store
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      // If the user's email is found, update the UI with the user's data
      // Otherwise, do nothing
      if (userSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            userSnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          loggedInUser = user;
          _usernameController.text = userData['name'] ?? '-';
          _emailController.text = userData['email'] ?? '-';
        });
      }
    }
  }

  // Updates the user's profile information in Firebase authentication and Firestore.
  // Displays a snackbar with a success or failure message.
  void updateProfile() async {
    try {
      // Update the user's display name in Firebase authentication
      await loggedInUser.updateDisplayName(_usernameController.text);

      // Update user information in Firestore based on email
      // Get the document ID of the first document with the user's email
      // Update the document with the new name and email
      // If the user's email is not found, do nothing
      await _store
          .collection('users')
          .where('email', isEqualTo: loggedInUser.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var docId = querySnapshot.docs.first.id;
          _store.collection('users').doc(docId).update({
            'name': _usernameController.text,
            'email': _emailController.text,
          });
        }
      });

      // Show success message if updates are successful 2 seconds
      // Then show the updated profile information
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show failure message if updates are not successful 2 seconds
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Builds the UI for the EditProfilePage widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(top: 35),
          child: const Text(
            'Profile ',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),
        toolbarHeight: 80,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    offset: const Offset(0, 10),
                  )
                ],
                shape: BoxShape.circle,
              ),
              // Use CircleAvatar with an icon instead of Image.asset
              child: const CircleAvatar(
                backgroundColor: Colors.transparent, // Set background color
                child: Icon(Icons.person_outline,
                    color: Colors.black26, size: 100), // Icon and its color
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button - discard changes
                // Reset the text fields to the current user's data
                OutlinedButton(
                  onPressed: () {
                    // reset the text fields to the current user's data
                    getCurrentUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Changes discarded.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Cancel'),
                ),
                // Save button - update profile
                // Update the user's profile information in Firebase authentication and Firestore
                // Display a snackbar with a success or failure message
                // If updates are successful show a snackbar with a success message, otherwise show a snackbar with a failure message.
                // Then show the updated profile information
                ElevatedButton(
                  onPressed: updateProfile,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
