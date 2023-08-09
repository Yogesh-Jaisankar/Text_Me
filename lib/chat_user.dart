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
        title: Text('Add friend'),
      ),
      body: Stack(
        children:[ StreamBuilder(
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
                return customListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(imageUrl)
                            : AssetImage('assets/man1.png') as ImageProvider,
                      ),
                    ],
                  ),
                  title: name,
                 );
                },
            );
           },
          ),
          // Positioned(
          //     left: 0,
          //     right: 0,
          //     bottom: 0,
          //     child:Container(
          //       //color: Colors.grey[200],
          //       padding: EdgeInsets.symmetric(vertical: 8),
          //       child: Center(
          //         child: Text(
          //           "Made with 💜 in India",
          //           style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 14,
          //           ),
          //         ),
          //       ),
          //     )
          //   )
        ]
      ),
    );
  }
}

Widget customListTile({
  required Widget leading,
  required String title,
}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.teal, // Adjust the color as needed
              width: 2, // Adjust the border width as needed
            ),
          ),
          child: leading,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}


void main() {
  runApp(MaterialApp(home: UserListPage()));
}
