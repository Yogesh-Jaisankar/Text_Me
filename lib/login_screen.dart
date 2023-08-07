import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController phoneController = TextEditingController();

  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        // authentication successful, do something
        setState(() {
          _isLoading = false; // Hide progress indicator
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false; // Hide progress indicator
        });
        // authentication failed, do something
      },
      codeSent: (String verificationId, int? resendToken) async {
        // code sent to phone number, save verificationId for later use
        String smsCode = ''; // get sms code from user
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        Get.to(OtpPage(), arguments: [verificationId]);
        await auth.signInWithCredential(credential);
        // authentication successful, do something
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _isLoading = false; // Hide progress indicator when timeout occurs
        });
      },
    );
  }

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  void _userLogin() async {
    String mobile = phoneController.text;
    if (mobile == "") {
      Get.snackbar(
        "Please enter the mobile number!",
        "Login Failed",
        colorText: Colors.black54,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      setState(() {
        _isLoading = true; // Show progress indicator
      });
      signInWithPhoneNumber("+${selectedCountry.phoneCode}$mobile");
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
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
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: Color(0xff215D5F),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 100),
              Text('Hey! Login',style: TextStyle(color: Colors.teal,fontSize: 30),),
              SizedBox(height: 50),
              Lottie.asset("assets/lottie/sec1.json",
                width: 200,
                height: 200,
                //fit: BoxFit.fill,
              ),
              SizedBox(height: 50),
              Text('Please confirm your country code and enter your mobile number!',style: TextStyle(color: Colors.black54,fontSize: 15),textAlign: TextAlign.center,),
              SizedBox(height: 50),
              Container(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black,
                  controller: phoneController,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Mobile number",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.black38)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.white, width: 2.0)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.black38, width: 2.0)),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                bottomSheetHeight: 550,
                              ),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: style,
                onPressed: _isLoading ? null : _userLogin, // Disable button while loading
                child: _isLoading
                    ? CircularProgressIndicator() // Show progress indicator
                    : const Text(
                  'GET OTP',
                  style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                ),),
              SizedBox(height: 80),

            ],
          ),
        ),
      ),
    );
  }
}
