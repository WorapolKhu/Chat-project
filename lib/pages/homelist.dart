import 'package:chatty/pages/friend_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeList extends StatefulWidget {
  const HomeList({super.key});

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  @override
  Widget build(BuildContext context) {
    Color avatarColor = const Color(0xffdeebff);
    Color iconColor = Colors.black;
    User? loggedInUser;
    final store = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // get current user and store it in loggedInUser
    // then query firebase firestore
    // return Map of userInfo from the query
    Future<Map> getUser() async {
      loggedInUser = await auth.authStateChanges().first;
      var tmp = await store
          .collection('users')
          .where('email', isEqualTo: loggedInUser!.email)
          .get();
      Map userInfo = tmp.docs[0].data();
      return userInfo;
    }

    // get document reference from firebase firestore
    // return refernce id as string on first match of the current user's email
    Future<String> getRefId() async {
      loggedInUser = await auth.authStateChanges().first;
      var userInfo = await store
          .collection('users')
          .where('email', isEqualTo: loggedInUser!.email)
          .get();
      return userInfo.docs.first.id;
    }

    // get user from given reference id
    // return Map of user info
    Future<Map<String, dynamic>?> getUserFromRef(String ref) async {
      var tmp = await store.collection('users').doc(ref).get();
      Map<String, dynamic>? userInfo = tmp.data();
      return userInfo;
    }

    // get friends of given reference id
    // return all documents in collection friends of the given reference id as a list
    Future<List> getFriend(String userRef) async {
      var tmp = await store
          .collection('users')
          .doc(userRef)
          .collection('friends')
          .get();

      return tmp.docs;
    }

    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.only(top: 40),
            alignment: Alignment.topLeft,
            child: FutureBuilder(
                future: getUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('');
                  }
                  return Text(snapshot.data!['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w400));
                }),
          ),
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          actions: const [
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 40.0, 30.0, 0.0),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 0.0),
            child: Text('Friends'),
          ),
          FutureBuilder(
              future: getRefId(),
              builder: (context, userRefSnapshot) {
                if (userRefSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return FutureBuilder(
                    future: getFriend(userRefSnapshot.data!),
                    builder: ((context, friendRefSnapshot) {
                      if (friendRefSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (friendRefSnapshot.hasError) {
                        return Text('Error = ${friendRefSnapshot.error}');
                      }
                      if (friendRefSnapshot.data!.isNotEmpty) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: friendRefSnapshot.data?.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: getUserFromRef(friendRefSnapshot
                                      .data?[index]['DocIdUser']),
                                  builder: ((context, friendInfoSnapshot) {
                                    return ListTile(
                                      onTap: () {
                                        Map<String, dynamic> userData = {
                                          'friendInfoSnapshot':
                                              friendInfoSnapshot,
                                          'userRefSnapshot':
                                              userRefSnapshot.data!,
                                          'friendRefSnapshot':
                                              friendRefSnapshot.data!,
                                          'index': index,
                                        };
                                        Navigator.pushNamed(
                                                context, FriendProfile.id,
                                                arguments: userData)
                                            .then((value) => setState(() {}));
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
                        return const Center(
                            child: Text('You do not have any friends'));
                      }
                    }));
              }),
        ],
      )),
    );
  }
}
