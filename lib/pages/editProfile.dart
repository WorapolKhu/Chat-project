import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);
  static String id = 'EditProfile';

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _userDoc;
  late Map<String, dynamic> userData = {}; // Initialize userData here

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _user = user;
        _userDoc = _firestore.collection('users').doc(_user.uid);

        _userDoc.get().then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            // Populate data from Firestore
            userData = documentSnapshot.data() as Map<String, dynamic>;
            fullNameController.text = userData['displayName'];
            emailController.text = userData['email'];
          }
        });

        setState(() {});
      }
    });
  }

  void saveChanges() async {
    try {
      // Update user data in Firestore
      await _userDoc.set({
        'uid': _user.uid,
        'displayName': fullNameController.text,
        'email': emailController.text,
      });

      // Update the local user data
      setState(() {
        userData['displayName'] = fullNameController.text;
        userData['email'] = emailController.text;
      });

      // Print a message or perform any other post-save actions
      print("Changes saved successfully");
    } catch (e) {
      // Handle errors, e.g., display an error message
      print("Error saving changes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        elevation: 1,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: Stack(
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
                        backgroundColor:
                            Colors.transparent, // Set background color
                        child: Icon(Icons.person_outline,
                            color: Colors.black12,
                            size: 100), // Icon and its color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Text("Username",
                  style: TextStyle(fontWeight: FontWeight.w300)),
              buildTextField("Full Name", fullNameController, false),
              SizedBox(height: 15),
              Text("Email",
                  style: TextStyle(fontWeight: FontWeight.w300)),
              buildTextField("E-mail", emailController, false),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Button to cancel changes
                  OutlinedButton(
                    onPressed: () {
                      // discard any changes
                      // Reset text fields to initial values
                      fullNameController.text = userData['displayName'];
                      emailController.text = userData['email'];
                      print("Changes cancelled");
                    },
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Button to save changes
                  ElevatedButton(
                    onPressed: () {
                      // save the changes to Firebase
                      saveChanges();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,
      bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
      ),
    );
  }
}
