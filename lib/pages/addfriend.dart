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
          padding: EdgeInsets.only(top: 40),
          alignment: Alignment.center,
          child: Text(
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
                  padding: EdgeInsets.only(top: 25, left: 16, right: 16),
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
                        contentPadding: EdgeInsets.all(2),
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
                      leading: CircleAvatar(),
                      title: Text(result["name"]!),
                      subtitle: Text(result["email"]!),
                      trailing: IconButton(
                        icon: Icon(Icons.person_add, size: 28),
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Friend added successfully!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
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
                                  content: Text(
                                    'User is already your friend!',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
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
