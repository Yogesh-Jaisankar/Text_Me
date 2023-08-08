import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:snapchat_clone/home.dart';
import 'package:snapchat_clone/profile.dart';

class OtpPage extends StatefulWidget {
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {

  bool _isVerified = false;

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _fourthController = TextEditingController();
  final TextEditingController _fifthController = TextEditingController();
  final TextEditingController _sixthController = TextEditingController();
  String? otpCode;
  final String verificationId = Get.arguments[0];
  FirebaseAuth auth = FirebaseAuth.instance;



  @override
  void initState() {
    super.initState();

    // Listen for changes in the otpCode variable
    otpCode = "";
    _listenForOtpChanges();
  }

  void _listenForOtpChanges() {
    final otpControllers = [
      _firstController,
      _secondController,
      _thirdController,
      _fourthController,
      _fifthController,
      _sixthController,
    ];

    for (final controller in otpControllers) {
      controller.addListener(() {
        String newOtp = "";
        for (final c in otpControllers) {
          newOtp += c.text;
        }
        setState(() {
          otpCode = newOtp;
        });

        // Verify OTP automatically when all characters are entered
        if (newOtp.length == 6) {
          verifyOtp(verificationId, newOtp); // Trigger automatic verification
        }
      });
    }
  }

  void verifyOtp(String verificationId, String userOtp) async {
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User? user = (await auth.signInWithCredential(creds)).user;
      if (user != null) {
        setState(() {
          _isVerified = true;
        });
        // Delay navigation to simulate progress
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (C)=>Profile()), (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        e.message.toString(),
        "Failed",
        colorText: Colors.black54,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    _fourthController.dispose();
    _fifthController.dispose();
    _sixthController.dispose();
    super.dispose();
  }




  void _manualVerify() async{
    if (otpCode != null && otpCode!.length == 6) {
      // Show a dialog to request notification permission
      bool permissionGranted = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Notification Permission"),
            content: Text(
              "This app requires notification permission to send you alerts. "
                  "Do you want to grant notification permission?",
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false
                },
              ),
              TextButton(
                child: Text("Grant"),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the permission dialog
                  bool agreed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Terms and Conditions"),
                        content: Text(
                          "By clicking 'Agree,' you confirm that you have read and agree to our terms and conditions.",
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Deny"),
                            onPressed: () {
                              Navigator.of(context).pop(false); // Return false
                            },
                          ),
                          TextButton(
                            child: Text("Agree"),
                            onPressed: () {
                              Navigator.of(context).pop(true); // Return true
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (agreed == true) {
                    var status = await Permission.notification.request();
                    if (status.isPermanentlyDenied) {
                      await openAppSettings();
                    }
                    verifyOtp(verificationId, otpCode!);
                  }
                },
              ),
            ],
          );
        },
      );

      if (permissionGranted == true) {
        verifyOtp(verificationId, otpCode!);
      }
    } else {
      // Show an error message if OTP is not complete
      Get.snackbar(
        "Enter 6-Digit code",
        "Failed to verify",
        colorText: Colors.black54,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  _buildSocialLogo(file) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          file,
          height: 38.5,
        ),
      ],
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

  Widget buildText(String text) => Center(
    child: Text(
      text,
      style: TextStyle(fontSize: 24, color: Colors.white),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        // backgroundColor: Color(0xff215D5F),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100),
              Text('Enter 6 digit OTP',style: TextStyle(color: Colors.teal,fontSize: 30),textAlign: TextAlign.center,), Text('sent to your number',style: TextStyle(color: Colors.teal,fontSize: 30),textAlign: TextAlign.center,),
                SizedBox(height: 50),
                Lottie.asset("assets/lottie/otp.json",
                  width: 200,
                  height: 200,
                  //fit: BoxFit.fill,
                ),
                SizedBox(height: 50),
                Center(
                  child: _isVerified?CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      Colors.teal
                    )
                  ):Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xff2C474A),
                        ),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                    onCompleted: (value) {
                      setState(() {
                        otpCode = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                    style: style,
                    onPressed: _manualVerify,
                    child: const Text(
                      'Verify OTP',
                      style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold),
                    )),
                const SizedBox(height: 80),
                const Text(
                  "Didn't receive any code?",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Resend new code",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
