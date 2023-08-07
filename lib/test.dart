import 'package:flutter/material.dart';

void main() => runApp(test());

class test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),
        drawer: Drawer(), // Add your custom drawer content here
        body: Center(
          child: Text("Your app content goes here"),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56.0); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text("Snapchat+",style: TextStyle(color: Colors.black87,),),
      actions: [
        IconButton(
          icon: Icon(Icons.search,color: Colors.black87,),
          onPressed: () {
            // Add your search functionality here
          },
        ),
        IconButton(
          icon: Icon(Icons.add,color: Colors.black87,),
          onPressed: () {
            // Add your "Add Contact" functionality here
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.menu,color: Colors.black87,),
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Open the side drawer
        },
      ),
      centerTitle: true,
      elevation: 0, // Remove the shadow below the AppBar
    );
  }
}
