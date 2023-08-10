import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String userName;
  final String userImageUrl;

  ChatScreen({required this.userName, required this.userImageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(userImageUrl),
            ),
            SizedBox(width: 10),
            Text(userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text("Chat messages interface here"), // Replace with actual chat messages UI
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Implement send message logic here
                    print("Sent to $userName");
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
