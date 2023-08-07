import 'package:snapchat_clone/login_screen.dart';
import 'package:snapchat_clone/main.dart';
import 'package:flutter/material.dart';

class authservice{
  void logOutUser(context)async{
    await auth.signOut();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (C)=>LoginPage()), (route) => false);
  }
}