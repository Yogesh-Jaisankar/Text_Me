import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';


class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Uint8List? _image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var users = snapshot.data?.docs;
          var currentUserPhoneNumber = _auth.currentUser?.phoneNumber;

          return ListView.builder(
            itemCount: users?.length,
            itemBuilder: (context, index) {
              var user = users?[index].data() as Map<String, dynamic>;
              String name = user['name'] ?? 'Unknown';
              String phoneNumber = user['phone'] ?? '';
              String imageUrl = user['image link'] ?? '';

              if (currentUserPhoneNumber == phoneNumber) {
                // Skip displaying the current user
                return SizedBox.shrink();
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                        radius: 65,
                        backgroundImage: MemoryImage(_image!),
                      )
                          : CircleAvatar(
                        radius: 65,
                        backgroundImage: imageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(imageUrl)
                            : AssetImage('assets/man1.png') as ImageProvider,
                      ),
                    ],
                  ),
                  title: Text(name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: UserListPage()));
}
