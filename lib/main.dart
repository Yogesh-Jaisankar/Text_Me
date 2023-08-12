import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchat_clone/home.dart';
import 'package:snapchat_clone/screens/login_screen.dart';
import 'package:snapchat_clone/screens/profile.dart';

final auth = FirebaseAuth.instance;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isProfileComplete = prefs.getBool('profile_complete') ?? false;
  bool isProfileSaved = prefs.getBool('profile_saved') ?? false;
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(isProfileComplete: isProfileComplete, isProfileSaved: isProfileSaved, prefs: prefs,));
}

class MyApp extends StatelessWidget {
  final bool isProfileComplete;
  final bool isProfileSaved;
  final SharedPreferences prefs;

  const MyApp({super.key, required this.isProfileComplete,required this.isProfileSaved, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Text Me™',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading while checking authentication state
          } else if (snapshot.hasData && snapshot.data != null) {
            // User is authenticated
            if (!isProfileSaved || prefs.containsKey('profile_saving')) {
              return Profile(); // Navigate to Profile if profile not saved or saving in progress
            } else if (isProfileComplete) {
              return Home(userName: '');
            } else {
              return Profile();
            }
          } else {
            // User is not authenticated
            return LoginPage();
          }
        },
      ),
    );
  }
}
