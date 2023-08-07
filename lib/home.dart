import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:snapchat_clone/helper/helper.dart';
import 'package:snapchat_clone/search.dart';



class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Future<bool> _onWillPop() async {
    //   return false; //<-- SEE HERE
    // }
    authservice authService = authservice();
    return  WillPopScope(
      //onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(), // Add your custom drawer content here
        body: Center(
          child: Text("Your app content goes here"),
        ),
      ),
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
        return shouldPop!;
      },
    );
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(60); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    authservice authService = authservice();
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text("Text Me™",
          style: TextStyle(color:HexColor("#BB8FCE"),
              fontFamily: 'Poppins',
          )),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/man1.png'),
          ),
        ),
        SizedBox(width: 10), // Add spacing between the avatar and the icon
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundColor: Colors.black12,
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black54,
              ),
              onPressed: () {
                // Add search functionality here
                showSearch(context: context, delegate: Search());
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black12, //<-- SEE HERE
            child: IconButton(
              icon: Icon(
                Icons.person_add,
                color: Colors.black54,
              ),
              onPressed: () {},
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black12, //<-- SEE HERE
            child:PopupMenuButton<String>(
              enableFeedback: true,
                itemBuilder: (BuildContext context){
                  return [
                    PopupMenuItem(child: Text("FAQ's"),onTap: (){
                      //_launchUrlfaq();
                    },),
                    PopupMenuItem(child: Text("Help"),onTap: (){
                      //_launchUrlhelp();
                    },),
                    PopupMenuItem(child: Text("Log Out"),onTap: (){
                      authservice AuthService = authservice();
                      authService.logOutUser(context);
                    },)
                    ,
                  ];
                })
          ),
        ),
      ],
      elevation: 3, // Remove the shadow below the AppBar
    );
  }
}
