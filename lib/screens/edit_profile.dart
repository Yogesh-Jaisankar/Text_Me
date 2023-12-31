  import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
  import 'package:photo_view/photo_view.dart';
  import 'package:snapchat_clone/home.dart';
  import 'package:snapchat_clone/resource/add_data.dart';
  import 'package:snapchat_clone/helper/utils.dart';


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


    bool _isOnline = false;
    bool _isNetworkAvailable = true;

    bool changesMade = false;

    @override
    void initState() {
      super.initState();
      // Initialize network connectivity status
      _checkConnectivity();
      // Start listening for connectivity changes
      InternetConnectionChecker().onStatusChange.listen((status) {
        setState(() {
          _isOnline = status == InternetConnectionStatus.connected;
          _isNetworkAvailable = _isOnline;
        });
      });
      // Fetch user data
      fetchUserData();
    }


    Future<void> _checkConnectivity() async {
      _isOnline = await InternetConnectionChecker().hasConnection;
      setState(() {});
    }

    void _showTermsAndConditionsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Terms and Conditions"),
            content: SingleChildScrollView(
              child: Text(
                "We value your privacy and are committed to maintaining the confidentiality of your personal data. When using our chat app developed with Flutter, please be assured that any collection and storage of photos are treated with the utmost respect for your privacy.\n\n"
                    "Privacy Commitment:\n\n"
                    "• Private Storage: Any photos shared or uploaded within the app are stored securely within our encrypted database. Access to these photos is restricted to authorized personnel only and is subject to stringent security measures.\n\n"
                    "• No Misuse: We guarantee that your photos will not be misused, shared, or sold to any third parties for marketing or any other purposes. Your photos remain entirely your property, and we do not claim any rights over them.\n\n"
                    "• Data Encryption: All photos stored in our database are encrypted to prevent unauthorized access. This adds an extra layer of protection to your sensitive visual data.\n\n"
                    "• Limited Access: Our team has limited access to the stored photos and strictly adheres to a policy of non-disclosure. Only necessary technical and support personnel will have controlled access to ensure smooth functioning and troubleshooting.\n\n"
                    "• User Control: You have complete control over the photos you share within the app. You can delete or remove them at any time, and they will be permanently deleted from our servers.\n\n"
                    "• Continuous Monitoring: We continually monitor and update our security measures to adapt to the evolving privacy landscape and ensure that your data remains secure.\n\n"
                    "By using our chat app, you acknowledge and agree that any photos shared and stored within the app are subject to this privacy commitment. Please take a moment to review our full Privacy Policy to understand how we collect, process, and protect your data.\n\n"
                    " If you have any concerns or questions regarding your privacy, please feel free to contact our support team at support@email.com.\n\n"
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
        changesMade = true;
      });

    }


    void _saveProfile() async {
      FocusScope.of(context).unfocus();
      bool _isNetworkAvailable = await InternetConnectionChecker().hasConnection;
      if (!_isNetworkAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No internet connection. Update failed.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (_isButtonDisabled) return;

      setState(() {
        _isButtonDisabled = true;
        _showProgressIndicator = true;
        changesMade = false;
      });

      String name = nameControl.text;
      String phoneNumber = auth.currentUser!.phoneNumber!;
      phoneNumber = '+91 ' + phoneNumber.substring(3, 8) + ' ' + phoneNumber.substring(8);

      try {
        QuerySnapshot snapshot = await firestore
            .collection("user")
            .where("phone", isEqualTo: phoneNumber)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = snapshot.docs.first;
          if (_image != null) {
            // If a new image is selected, upload it and update the existing document
            String imageName = '${auth.currentUser!.uid}-$name'; // Use the same logic as in Profile widget
            String imageUrl = await StoreData().uploadImageToStorage(imageName, _image!);
            await userSnapshot.reference.update({
              "name": name,
              "image link": imageUrl,
            });
          } else {
            // If no new image is selected, update the name only
            await userSnapshot.reference.update({
              "name": name,
            });
          }
        } else {
          // Create new user's profile
          if (_image != null) {
            // If a new image is selected, upload it and create a new document
            String imageName = '${auth.currentUser!.uid}-$name'; // Use the same logic as in Profile widget
            String imageUrl = await StoreData().uploadImageToStorage(imageName, _image!);
            await firestore.collection("user").add({
              "phone": phoneNumber,
              "name": name,
              "image link": imageUrl,
            });
          } else {
            // If no new image is selected, create a new document without the image
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

        // Show a success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 500,),
            content: Text('Profile updated successfully!'),
          ),
        );

        // Navigate to the home page after successful saving
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => Home()),
        //       (route) => false,
        // );
      } catch (error) {
        print("Error: $error");
        setState(() {
          _showProgressIndicator = false;
          _isButtonDisabled = false;
        });

        // Show an error Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }



    late String _currentName = '';
    late String _currentImageUrl = '';



    Future<void> fetchUserData() async {
      try {
        String phoneNumber = auth.currentUser!.phoneNumber!;
        String formattedPhoneNumber = '+91 ' + phoneNumber.substring(3, 8) + ' ' + phoneNumber.substring(8);

        QuerySnapshot snapshot = await firestore
            .collection("user")
            .where("phone", isEqualTo: formattedPhoneNumber)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = snapshot.docs.first;
          setState(() {
            _currentName = userSnapshot["name"];
            _currentImageUrl = userSnapshot["image link"];
            nameControl.text = _currentName;
          });
        }
      } catch (error) {
        print("Error fetching user data: $error");
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
        _isNameFieldEmpty = text.isEmpty && _currentName.isEmpty;
        changesMade = true;
      });
    }

    // Add this method to show the image in full-screen
    void _showImageFullScreen(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: _image != null
                  ? PhotoView(
                imageProvider: MemoryImage(_image!),
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
              )
                  : _currentImageUrl.isNotEmpty
                  ? PhotoView(
                imageProvider: NetworkImage(_currentImageUrl),
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
              )
                  : PhotoView(
                imageProvider: AssetImage('assets/man1.png'),
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
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

      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;

      return  Scaffold(
          appBar: AppBar(
            title: Text("Profile"),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  GestureDetector(
                    onTap: () {
                      _showImageFullScreen(context);
                    },
                    child: Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                          radius: 65,
                          backgroundImage: MemoryImage(_image!),
                        )
                            : CircleAvatar(
                          radius: 65,
                          backgroundImage: _currentImageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(_currentImageUrl)
                              : AssetImage('assets/man1.png') as ImageProvider,
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
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  GestureDetector(
                    //onTap: _selectImage,
                    child: Center(
                      child: Text(
                        "Change Profile Picture",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: TextField(
                      controller: nameControl,
                      onChanged: _updateNameField,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // Remove the errorText property
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Center(
                    child: Text(
                      "Change name",
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: ElevatedButton(
                      style: style,
                      onPressed: (_isButtonDisabled || (!_isNetworkAvailable && (_isNameFieldEmpty && _image == null)) || !changesMade) // Update this condition
                          ? null
                          : _saveProfile,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _showProgressIndicator ? CircularProgressIndicator() : SizedBox(),
                          SizedBox(
                            width: _showProgressIndicator ? 10 : 0,
                          ),
                          Text(
                            _showProgressIndicator ? 'Saving...' : 'Update',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Text(
                      _isOnline
                          ? 'You are online'
                          : 'You are offline. Profile cannot be updated.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
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
