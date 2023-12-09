import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class HomeList extends StatelessWidget {
  const HomeList({super.key});

  @override
  Widget build(BuildContext context) {
    var avatarColor = Color(0xffdeebff);
    var iconColor = Colors.black;
    User? loggedInUser;
    final store = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    Future<Map> getUser() async {
      loggedInUser = await auth.authStateChanges().first;
      var tmp = await store
          .collection('users')
          .where('email', isEqualTo: loggedInUser!.email)
          .get();
      Map userInfo = tmp.docs[0].data();
      return userInfo;
    }

    Future<String> getRefId() async {
      loggedInUser = await auth.authStateChanges().first;
      var userInfo = await store
          .collection('users')
          .where('email', isEqualTo: loggedInUser!.email)
          .get();
      return userInfo.docs.first.id;
    }

    Future<Map<String, dynamic>?> getUserFromRef(String ref) async {
      var tmp = await store.collection('users').doc(ref).get();
      Map<String, dynamic>? userInfo = tmp.data();
      return userInfo;
    }

    Future getFriend(String userRef) async {
      var tmp = await store
          .collection('users')
          .doc(userRef)
          .collection('friends')
          .get();

      return tmp.docs;
    }

    Future deleteFriendFunction(String userRef, String friendDocId) async {
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
                onPressed: () {
                  var docId = friendData[index]['DocIdUser'] as String?;
                  if (docId != null) {
                    deleteFriendFunction(userRef, docId);
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Container(
            padding: EdgeInsets.only(top: 40),
            alignment: Alignment.topLeft,
            child: FutureBuilder(
                future: getUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('');
                  }
                  return Text(snapshot.data!['name'] ?? '',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w400));
                }),
          ),
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 40.0, 30.0, 0.0),
              child: Icon(
                Icons.person,
                size: 40.0,
              ),
            )
          ]),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 0.0),
            child: Text('Friends'),
          ),
          FutureBuilder(
              future: getRefId(),
              builder: (context, userRefSnapshot) {
                if (userRefSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return FutureBuilder(
                    future: getFriend(userRefSnapshot.data!),
                    builder: ((context, friendRefSnapshot) {
                      if (friendRefSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (friendRefSnapshot.hasError)
                        return Text('Error = ${friendRefSnapshot.error}');
                      if (friendRefSnapshot.data?.length > 0) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: friendRefSnapshot.data?.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: getUserFromRef(friendRefSnapshot
                                      .data?[index]['DocIdUser']),
                                  builder: ((context, friendInfoSnapshot) {
                                    return ListTile(
                                      onLongPress: () {
                                        showDeleteConfirmation(
                                          context,
                                          friendInfoSnapshot,
                                          userRefSnapshot.data!,
                                          friendRefSnapshot.data!,
                                          index,
                                        );
                                      },
                                      leading: CircleAvatar(
                                          backgroundColor: avatarColor,
                                          child: Icon(
                                            Icons.person_2_outlined,
                                            color: iconColor,
                                          )),
                                      title: Text(
                                          friendInfoSnapshot.data?['name'] ??
                                              ''),
                                    );
                                  }));
                            });
                      } else {
                        return Center(
                            child: Text('You do not have any friends'));
                      }
                    }));
              }),
        ],
      )),
    );
  }
}
