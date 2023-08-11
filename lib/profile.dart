import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapchat_clone/home.dart';
import 'package:snapchat_clone/resource/add_data.dart';
import 'package:snapchat_clone/utils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final TextEditingController nameControl = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  Uint8List? _image;

  bool _isButtonDisabled = false;
  bool _showProgressIndicator = false;
  bool _isNameFieldEmpty = true;

  void _showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Terms and Conditions"),
          content: SingleChildScrollView(
            child: Text(
              "We value your privacy and are committed to maintaining the confidentiality of your personal data. When using our chat app developed with Flutter, please be assured that any collection and storage of photos are treated with the utmost respect for your privacy.\n\n"
                  "Privacy Commitment:\n"
                  "• Private Storage: Any photos shared or uploaded within the app are stored securely within our encrypted database. Access to these photos is restricted to authorized personnel only and is subject to stringent security measures.\n"
                  "• No Misuse: We guarantee that your photos will not be misused, shared, or sold to any third parties for marketing or any other purposes. Your photos remain entirely your property, and we do not claim any rights over them.\n"
                  "• Data Encryption: All photos stored in our database are encrypted to prevent unauthorized access. This adds an extra layer of protection to your sensitive visual data.\n"
                  "• Limited Access: Our team has limited access to the stored photos and strictly adheres to a policy of non-disclosure. Only necessary technical and support personnel will have controlled access to ensure smooth functioning and troubleshooting.\n"
                  "• User Control: You have complete control over the photos you share within the app. You can delete or remove them at any time, and they will be permanently deleted from our servers.\n"
                  "• Continuous Monitoring: We continually monitor and update our security measures to adapt to the evolving privacy landscape and ensure that your data remains secure.\n"
                  "By using our chat app, you acknowledge and agree that any photos shared and stored within the app are subject to this privacy commitment. Please take a moment to review our full Privacy Policy to understand how we collect, process, and protect your data. If you have any concerns or questions regarding your privacy, please feel free to contact our support team at support@email.com.\n"
                  "Your trust is of utmost importance to us, and we are dedicated to providing you with a secure and enjoyable chatting experience.",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _selectImage()async{
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image=img;
    });

  }


  void _saveProfile() async {FocusScope.of(context).unfocus();
    if (_isButtonDisabled) return;

    setState(() {
      _isButtonDisabled = true;
      _showProgressIndicator = true;
    });

    String name = nameControl.text;
    String phoneNumber = auth.currentUser!.phoneNumber!;
    phoneNumber = '+91 ' + phoneNumber.substring(3, 8) + ' ' + phoneNumber.substring(8);


    try {
      QuerySnapshot snapshot = await firestore
          .collection("user")
          .where("phone", isEqualTo: phoneNumber)
          .get();

      if (_image != null) { // Check if an image is selected
        String imageName = '${auth.currentUser!.uid}-$name'; // Construct the image name
        String imageUrl = await StoreData().uploadImageToStorage(imageName, _image!);

        if (snapshot.docs.isNotEmpty) {
          // Update existing user's profile
          DocumentSnapshot userSnapshot = snapshot.docs.first;
          await userSnapshot.reference.update({
            "name": name,
            "image link": imageUrl,
          });
        } else {
          // Create new user's profile
          await firestore.collection("user").add({
            "phone": phoneNumber,
            "name": name,
            "image link": imageUrl,
          });
        }
      } else {
        if (snapshot.docs.isNotEmpty) {
          // Update existing user's profile without changing the image
          DocumentSnapshot userSnapshot = snapshot.docs.first;
          await userSnapshot.reference.update({
            "name": name,
          });
        } else {
          // Create new user's profile without an image
          await firestore.collection("user").add({
            "phone": phoneNumber,
            "name": name,
          });
        }
      }

      setState(() {
        _showProgressIndicator = false;
        _isButtonDisabled = false;
      });

      // Navigate to the home page after successful saving
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
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
                    icon: Icon(Icons.add_circle_rounded,color: Colors.teal,size: 30,),
                    onPressed:_selectImage,
                  ),
                    bottom: -11,
                    left: 90,
                  )
                ],
              ),
              SizedBox(height: 5),
              Center(
                child: Text(
                  "Profile pic can be changed later",
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
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextButton(
                  onPressed: _showTermsAndConditionsDialog,
                  child: Text(
                    "Terms and Conditions©",
                    style: TextStyle(
                      color: Colors.blue,
                      //decoration: TextDecoration.underline,
                    ),
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
