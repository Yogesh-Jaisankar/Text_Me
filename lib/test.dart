import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ViewProfilePage(),
  ));
}

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({Key? key}) : super(key: key);

  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  Uint8List? _image; // Replace this with your actual image data
  String _name = 'John Doe'; // Replace this with the user's actual name
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _name;
  }

  void _selectImage() async {
    // Implement image selection logic here
    // Set _image with the new image data
  }

  void _saveChanges() {
    setState(() {
      _name = _nameController.text;
    });
    // Save changes to the backend (update name and/or image)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _selectImage,
                child: Stack(
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
              ),
              SizedBox(height: 10),
              Text(
                'Tap the image to change profile picture',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
