import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({Key? key, required this.onPickImage})
      : super(key: key);

  final void Function(File pickedImage) onPickImage;

  @override
  State<StatefulWidget> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
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

  void _pickImage() async {
    final pickeImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 500,
    );

    if (pickeImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickeImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile != null
            ? FileImage(_pickedImageFile!) as ImageProvider<Object>?
            : (_userImageUrl != null
              ? NetworkImage(_userImageUrl!) as ImageProvider<Object>?
              : null),
        ),
        Positioned(
          bottom: -7,
          right: 177,
          child: IconButton(
            onPressed: _pickImage,
            icon: Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
