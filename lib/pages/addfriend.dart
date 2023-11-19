import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .get();

    return querySnapshot.docs.map((DocumentSnapshot doc) {
      return {
        'name': doc['name'].toString(),
        'email': doc['email'].toString(),
        'profileImage': doc['profileImage']?.toString() ?? '',
      };
    }).toList();
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
                    trailing: Icon(Icons.person_add, size: 28),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
