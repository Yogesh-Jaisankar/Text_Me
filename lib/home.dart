import 'package:flutter/material.dart';
import 'package:snapchat_clone/helper/helper.dart';
import 'package:snapchat_clone/screens/contacts_page.dart';
import 'package:snapchat_clone/screens/edit_profile.dart';
import 'package:snapchat_clone/search.dart';
import 'package:get/get.dart';



class Home extends StatefulWidget {
  final String userName;
  const Home({super.key, required this.userName});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();

    // Show a welcome snack bar with the user's name
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 500,),
            content: Text("Welcome, ${widget.userName}!")),
      );
    });
  }

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
          style: TextStyle(color: Colors.teal,
              fontFamily: 'Poppins',
          )),
      actions: [
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
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) =>ContactsPage()));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black12,
            child:PopupMenuButton<String>(
              enableFeedback: true,
                itemBuilder: (BuildContext context){
                  return [
                    PopupMenuItem(child: Text("Settings"),onTap: () => Future(
                          () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => Edit_Profile()),
                      ),
                    )
                    ),
                    // PopupMenuItem(child: Text("Help"),onTap: (){
                    //   //_launchUrlhelp();
                    // },),
                    PopupMenuItem(child: Text("Log Out"),onTap: (){
                      Get.snackbar(
                        "Logged Out Successfully",
                        "Login to countinue using Text Me™",
                        colorText: Colors.black54,
                        snackPosition: SnackPosition.BOTTOM,
                      );
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
