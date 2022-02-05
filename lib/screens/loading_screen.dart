import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/home_screens.dart';

class LoadingScreen extends StatefulWidget {
  final bool isAdmin;

  const LoadingScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()));
            } else {
              List<DocumentSnapshot> documents = snapshot.data!.docs;
              List<Map<String, dynamic>> subjects = <Map<String, dynamic>>[];
              for (int i = 0; i < documents.length; ++i) {
                subjects.add({
                  'reference': documents[i].reference.path,
                  'subject': documents[i]['subject'],
                  'chapters': documents[i]['chapters'],
                  'no_of_chapters': documents[i]['no_of_chapters'],
                });
              }
              return HomeScreen(subjects: subjects, isAdmin: widget.isAdmin);
            }
          }),
    );
  }
}
