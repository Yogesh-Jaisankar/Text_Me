import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String profileImage;

  ChatScreen({required this.userName, required this.profileImage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(widget.profileImage),
            ),
            const SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text("Chat messages interface here"), // Replace with actual chat messages UI
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                border: Border.all(
                  color: Colors.grey, // You can customize the border color here
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mood),
                    onPressed: () {
                      // Add mood functionality here
                      print("Mood button pressed");
                    },
                  ),
                  if (!_isTyping) ...[
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        // Add file attachment functionality here
                        print("File attachment button pressed");
                      },
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border:InputBorder.none,
                        hintText: 'Type your message...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,

                      onChanged: (text) {
                        setState(() {
                          _isTyping = text.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 2,right: 4,top: 2,bottom: 2),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black12,
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          // Add send functionality here
                          print("Sent to ${widget.userName}");
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
