import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapchat_clone/home.dart';
import 'package:snapchat_clone/resource/add_data.dart';
import 'package:snapchat_clone/utils.dart';


class Edit_Profile extends StatefulWidget {
  const Edit_Profile({super.key});

  @override
  State<Edit_Profile> createState() => _Edit_ProfileState();
}

class _Edit_ProfileState extends State<Edit_Profile> {
  final TextEditingController nameControl = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  Uint8List? _image;

  bool _isButtonDisabled = false;
  bool _showProgressIndicator = false;
  bool _isNameFieldEmpty = true;

  void _selectImage()async{
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image=img;
    });

  }


  void _saveProfile() async {
    if (_isButtonDisabled) return;

    setState(() {
      _isButtonDisabled = true;
      _showProgressIndicator = true;
    });

    String name = nameControl.text;
    String phoneNumber = auth.currentUser!.phoneNumber!;

    try {
      QuerySnapshot snapshot = await firestore
          .collection("user")
          .where("phone", isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update existing user's profile
        DocumentSnapshot userSnapshot = snapshot.docs.first;
        await userSnapshot.reference.update({
          "name": name,
          "image link": await StoreData().uploadImageToStorage('ProfileImage', _image!),
        });
      } else {
        // Create new user's profile
        await firestore.collection("user").add({
          "phone": phoneNumber,
          "name": name,
          "image link": await StoreData().uploadImageToStorage('ProfileImage', _image!),
        });
      }

      setState(() {
        _showProgressIndicator = false;
        _isButtonDisabled = false;
      });

      // Navigate to the home page after successful saving
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()), // Replace 'Home()' with your home page widget
            (route) => false,
      );
    } catch (error) {
      print("Error: $error");
      setState(() {
        _showProgressIndicator = false;
        _isButtonDisabled = false;
      });
    }
  }



  Future<Uint8List> getDefaultProfileImage() async {
    // Load your default profile image asset and convert it to Uint8List
    // For example:
    final ByteData defaultImageByteData = await rootBundle.load('assets/man1.png');
    return defaultImageByteData.buffer.asUint8List();
  }

  void _updateNameField(String text) {
    setState(() {
      _isNameFieldEmpty = text.isEmpty; // Update the flag based on the text
    });
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
      minimumSize: Size(188, 48),
      backgroundColor: Colors.teal,
      elevation: 6,
      textStyle: const TextStyle(fontSize: 16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          )));

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 10 ),
                Stack(
                  children: [
                    _image !=null?
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: MemoryImage(_image!),
                    ):
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: AssetImage('assets/man1.png'),
                    ),
                    Positioned(child: IconButton(
                      icon: Icon(Icons.edit,color: Colors.black,),
                      onPressed:_selectImage,
                    ),
                      bottom: 10,
                      left: 80,
                    )
                  ],
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    "Change Profile Picture",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: TextField(
                    controller: nameControl,
                    onChanged: _updateNameField, // Add onChanged callback
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      errorText: _isNameFieldEmpty ? 'Name cannot be empty' : null, // Show error text if empty
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(
                    style: style,
                    onPressed: _isButtonDisabled || _isNameFieldEmpty
                        ? null
                        : _saveProfile,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showProgressIndicator
                            ? CircularProgressIndicator()
                            : SizedBox(),
                        SizedBox(
                          width: _showProgressIndicator ? 10 : 0,
                        ),
                        Text(
                          _showProgressIndicator ? 'Saving...' : 'Continue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        )
    );
  }
}
