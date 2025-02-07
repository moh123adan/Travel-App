import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileImage extends StatefulWidget {
  const UserProfileImage({Key? key}) : super(key: key);

  @override
  _UserProfileImageState createState() => _UserProfileImageState();
}

class _UserProfileImageState extends State<UserProfileImage> {
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _getUserImageUrl();
  }

  void _getUserImageUrl() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userEmail = currentUser.email!;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userEmail);
    final userData = await userDoc.get();
    final userMap = userData.data(); // Get the document fields as a Map

    if (userMap != null && userMap.containsKey('profile')) {
      setState(() {
        _userImageUrl = userMap['profile'];
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return _userImageUrl != null
        ? ClipOval(        
          child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(_userImageUrl!),
              
            ),
        )
        : CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            backgroundImage: AssetImage('assets/images/profile.png'),
          );
  }
}