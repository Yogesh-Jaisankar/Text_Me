import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:snapchat_clone/chat_screen.dart';


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
                  onTap: () {
                    // Handle the chat action here
                    print('Chat with $name');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          userName: name,
                          userImageUrl: imageUrl,
                        ),
                      ),
                    );
                    // You can open a chat screen or perform any other action
                  },
                 );
                },
            );
           },
          ),
        ]
      ),
    );
  }
}

Widget customListTile({
  required Widget leading,
  required String title,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.teal,
                width: 2,
              ),
            ),
            child: leading,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                Icon(
                  Icons.chat,  // Add the chat icon
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


void main() {
  runApp(MaterialApp(home: UserListPage()));
}
