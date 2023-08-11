import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  FocusNode _textFieldFocusNode = FocusNode();
  bool _showEmoji = false;
  double _emojiPickerHeight = 0.0;

  final _textController = TextEditingController();

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _textFieldFocusNode.unfocus();
        _closeEmojiPicker();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                CachedNetworkImageProvider(widget.profileImage),
              ),
              const SizedBox(width: 10),
              Text(widget.userName),
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Text("Chat messages interface here"),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: IconButton(
                            icon: const Icon(Icons.mood),
                            onPressed: () {
                              _toggleEmojiPicker();
                            },
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: TextField(
                              cursorColor: Colors.teal,
                              focusNode: _textFieldFocusNode,
                              controller: _textController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type your message...',

                              ),
                              maxLines: 5,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              onChanged: (text) {
                                setState(() {
                                  _isTyping = text.isNotEmpty;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 2, right: 4, top: 2, bottom: 2),
                          child: CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                _closeEmojiPicker();
                                _textFieldFocusNode.unfocus();
                                print("Sent to ${widget.userName}");
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _showEmoji
            ? SizedBox(
          height: _emojiPickerHeight,
          child: EmojiPicker(
            textEditingController: _textController,
            config: Config(
              indicatorColor: Colors.teal,
              iconColorSelected: Colors.teal,
              columns: 7,
              initCategory: Category.SMILEYS,
              emojiSizeMax: 20 * (Platform.isAndroid ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
            ),
            onEmojiSelected: (emoji, category) {
              print("Selected emoji: $emoji");
            },
          ),
        )
            : null,
      ),
    );
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmoji = !_showEmoji;
      if (_showEmoji) {
        _textFieldFocusNode.unfocus();
      }
    });

    // Calculate the height of the EmojiPicker based on keyboard height
    if (_showEmoji) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      _emojiPickerHeight = keyboardHeight;
    } else {
      _emojiPickerHeight = 0.0;
    }
  }

  void _closeEmojiPicker() {
    if (_showEmoji) {
      setState(() {
        _showEmoji = false;
      });
    }
  }
}

