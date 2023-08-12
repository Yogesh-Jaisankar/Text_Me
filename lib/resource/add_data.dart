
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snapchat_clone/home.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

class StoreData{

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    String uid = auth.currentUser!.uid;
    String imageName = '$uid-$childName'; // Create a unique image name
    Reference ref = _storage.ref().child(imageName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> SaveData({
    required String name,
    required Uint8List file,
    required BuildContext context,
  }) async {
    String resp = "Some Error Occurred";
    try {
      if (name.isNotEmpty) {
        String imageName = '${auth.currentUser!.uid}-$name'; // Construct image name
        String imageUrl = await uploadImageToStorage(imageName, file); // Use consistent image name

        // Delete the old image if it exists
        String oldImageName = '${auth.currentUser!.uid}-$name'; // Construct old image name
        Reference oldImageRef = _storage.ref().child(oldImageName);
        try {
          await oldImageRef.delete();
        } catch (deleteError) {
          print("Error deleting old image: $deleteError");
        }

        firestore.collection("user").add({
          "uid": auth.currentUser!.uid,
          "name": name,
          "image link": imageUrl,
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (C) => Home(userName: '',)),
              (route) => false,
        );
        resp = "Success";
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
