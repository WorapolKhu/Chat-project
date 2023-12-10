import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendProfile extends StatefulWidget {
  static String id = 'friend_profile';

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  final store = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;
  User? loggedInUser;
  Future<Map> getUser() async {
    loggedInUser = await auth.authStateChanges().first;
    var tmp = await store
        .collection('users')
        .where('email', isEqualTo: loggedInUser!.email)
        .get();
    Map userInfo = tmp.docs[0].data();
    return userInfo;
  }

  Future deleteFriendFunction(
      String userRef, String friendDocId, String friendEmail) async {
    await store
        .collection('users')
        .doc(userRef)
        .collection('friends')
        .where('DocIdUser', isEqualTo: friendDocId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    var friendSnapshot = await store
        .collection('users')
        .doc(friendDocId)
        .collection('friends')
        .where('DocIdUser', isEqualTo: userRef)
        .get();

    if (friendSnapshot.docs.isNotEmpty) {
      await store
          .collection('users')
          .doc(friendDocId)
          .collection('friends')
          .where('DocIdUser', isEqualTo: userRef)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    }
    // TODO: also delete chat room
    await getUser();
    await store
        .collection('chatList')
        .where('users', arrayContains: loggedInUser!.email)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        for (var user in doc.data()['users']) {
          if (user == friendEmail) {
            store.collection('chatList').doc(doc.id).delete();
          }
        }
      }
    });
  }

  void showDeleteConfirmation(
      BuildContext context,
      AsyncSnapshot friendInfoSnapshot,
      String userRef,
      List<dynamic> friendData,
      int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Friend'),
          content: Text(
              'Are you sure you want to delete ${friendInfoSnapshot.data?['name']} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var docId = friendData[index]['DocIdUser'] as String?;
                if (docId != null) {
                  await deleteFriendFunction(
                      userRef, docId, friendInfoSnapshot.data?['email']);
                }
                Navigator.of(context).pop();

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Column buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.black,
          size: 50,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> receivedData = {};
    var route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      receivedData = route.settings.arguments as Map<String, dynamic>;
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            maxRadius: 100,
            child: Image(image: AssetImage("assets/profilePic_symbol.png")),
          ),
          SizedBox(height: 10),
          Text(
            '${receivedData['friendInfoSnapshot'].data?['name']}',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      showDeleteConfirmation(
                        context,
                        receivedData['friendInfoSnapshot'],
                        receivedData['userRefSnapshot'],
                        receivedData['friendRefSnapshot'],
                        receivedData['index'],
                      );
                    },
                    icon: Icon(Icons.person_remove_outlined),
                  ),
                  Text('Delete Friend')
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
