import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendProfile extends StatefulWidget {
  static String id = 'friend_profile';

  const FriendProfile({super.key});

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
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
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
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    }
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
          title: const Text('Delete Friend'),
          content: Text(
              'Are you sure you want to delete ${friendInfoSnapshot.data?['name']} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
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
          const CircleAvatar(
            maxRadius: 100,
            backgroundColor: Colors.transparent, // Set background color
            child: Icon(Icons.person_outline,
                color: Colors.black26, size: 100), // Icon and its color
          ),
          const SizedBox(height: 10),
          Text(
            '${receivedData['friendInfoSnapshot'].data?['name']}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 60),
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
                    icon: const Icon(
                      Icons.person_remove_outlined,
                    ),
                  ),
                  const Text('Delete Friend')
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
