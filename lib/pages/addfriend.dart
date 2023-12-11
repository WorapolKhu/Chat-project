import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);
  static String id = 'Addfriend';

  @override
  State<AddFriendPage> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriendPage> {
  String enteredText = '';
  List<Map<String, String>> filteredResults = [];

//This function searches for users by their email address.
  // Retrieve the current user using FirebaseAuth
  // if there's current user and matches the current user's email
  // Query Firestore for documents in the 'users' collection matching the provided email
  // Map the retrieved documents to a list of maps containing 'name' and 'email' fields
  // if there's no current user and the provided email not matches the current user's email.
  //Returns an empty list
  Future<List<Map<String, String>>> searchUsersByEmail(String email) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && email.toLowerCase() != currentUser.email) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      return querySnapshot.docs.map((DocumentSnapshot doc) {
        return {
          'name': doc['name'].toString(),
          'email': doc['email'].toString(),
        };
      }).toList();
    } else {
      return [];
    }
  }

  final _store = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

//Updates the logged-in user when changes occur in the authentication state.
  Future<void> getCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(top: 40),
          alignment: Alignment.center,
          child: const Text(
            'Add Friend',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[600], size: 20),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.all(2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      onChanged: (value) async {
                        setState(() {
                          enteredText = value;
                        });

                        if (enteredText.isNotEmpty) {
                          List<Map<String, String>> results =
                              await searchUsersByEmail(enteredText);
                          setState(() {
                            filteredResults = results;
                          });
                        } else {
                          setState(() {
                            filteredResults = [];
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                for (Map<String, String> result in filteredResults)
                  ListTile(
                      leading: const CircleAvatar(),
                      title: Text(result["name"]!),
                      subtitle: Text(result["email"]!),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, size: 28),
                        //When you click icon add-friend
                        // Fetches the current user's email using FirebaseAuth
                        // Retrieves user data from Firestore based on email
                        // Retrieves data of another user (result["email"]) from Firestore
                        // Checks if the queried user exists
                        // Creates a reference to the 'friends' collection for the current user
                        // Checks if the queried user is not already a friend
                        // Creates a reference to the 'friends' collection
                        // Adds the current user as a friends
                        onPressed: () async {
                          String? email =
                              FirebaseAuth.instance.currentUser?.email;

                          QuerySnapshot querySnapshotUser = await _store
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .limit(1)
                              .get();

                          QuerySnapshot querySnapshot = await _store
                              .collection('users')
                              .where('email', isEqualTo: result["email"]!)
                              .limit(1)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            String friendDocId = querySnapshot.docs.first.id;
                            String userDocId = querySnapshotUser.docs.first.id;

                            CollectionReference friendsCollection = _store
                                .collection('users')
                                .doc(userDocId)
                                .collection('friends');

                            var existingFriend = await friendsCollection
                                .where('DocIdUser', isEqualTo: friendDocId)
                                .limit(1)
                                .get();

                            if (existingFriend.docs.isEmpty) {
                              await friendsCollection.add({
                                'DocIdUser': friendDocId,
                              });
                              CollectionReference friendFriendsCollection =
                                  _store
                                      .collection('users')
                                      .doc(friendDocId)
                                      .collection('friends');

                              var myDocId = querySnapshotUser.docs.first.id;
                              await friendFriendsCollection.add({
                                'DocIdUser': myDocId,
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Friend added successfully!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              );
                              //TODO: add chat room
                              String currentUser = email ?? '';
                              String otherUser = result['email'] ?? '';
                              CollectionReference collectionReference =
                                  FirebaseFirestore.instance
                                      .collection('chatList');
                              List<String> userArray = [
                                currentUser,
                                otherUser,
                              ];
                              collectionReference.add({
                                'users': userArray,
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'User is already your friend!',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
