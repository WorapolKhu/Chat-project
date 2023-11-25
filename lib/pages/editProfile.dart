import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  static String id = 'EditProfile';

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> userData = {};

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
        final uid = user.uid;
        final displayName = user.displayName ?? 'N/A';
        final email = user.email ?? 'N/A';
        final picture = user.photoURL ?? '';

        userData = {
          'uid': uid,
          'displayName': displayName,
          'email': email,
          'picture': picture,
        };

        fullNameController.text = userData['displayName'];
        emailController.text = userData['email'];

        setState(() {});
      }
    });
  }

  void saveChanges() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Update the user's display name and email
        await user.updateDisplayName(fullNameController.text);
        await user.updateEmail(emailController.text);
        // Reload the user to get the updated information
        await user.reload();
        user = _auth.currentUser;
        // Update the local userData with the latest information
        userData['displayName'] = user!.displayName ?? '';
        userData['email'] = user.email;
        // Print a message or perform any other post-save actions
        print("Changes saved successfully");
      }
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
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            userData['picture'] ?? '',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Colors.blue),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              buildTextField("Full Name", fullNameController, false),
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
                  FilledButton(
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
