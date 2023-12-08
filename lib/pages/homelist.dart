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
