import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSearchDelegate extends SearchDelegate<Contact> {
  final List<Contact> contacts;
  final List<String> firebaseContactNumbers;
  List<bool> _contactIcons = [];

  ContactSearchDelegate(this.contacts, this.firebaseContactNumbers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final trimmedQuery = query.trim(); // Trim trailing spaces
    final searchResults = contacts.where((contact) =>
        contact.displayName!.toLowerCase().contains(trimmedQuery.toLowerCase()));

    _contactIcons = List.generate(searchResults.length, (_) => false);

    for (int i = 0; i < searchResults.length; i++) {
      Contact contact = searchResults.elementAt(i);
      String phoneNumber = '';

      if (contact.phones != null && contact.phones!.isNotEmpty) {
        phoneNumber = contact.phones!.first.value ?? '';
      }

      bool isInFirebase =
      isContactInFirebase(phoneNumber, firebaseContactNumbers);
      _contactIcons[i] = isInFirebase;
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        Contact contact = searchResults.elementAt(index);

        return ListTile(
          title: Text(contact.displayName ?? ''),
          trailing: _contactIcons[index]
              ? IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // Handle chat action
            },
          )
              : ElevatedButton(
            onPressed: () async {
              final contact = searchResults.elementAt(index); // Use 'contact' from the respective method
              final phoneNumber = contact.phones?.first.value ?? '';
              final message = 'Join the app'; // Customize your message here

              final url = 'sms:$phoneNumber?body=${Uri.encodeComponent(message)}';

              if (await canLaunch(url)) {
                await launch(url);
              } else {
                // Handle error, maybe show a snackbar or dialog
                print('Could not launch SMS app');
              }
            },
            child: const Text("Invite"),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final trimmedQuery = query.trim(); // Trim trailing spaces
    final suggestionList = contacts.where((contact) =>
        contact.displayName!.toLowerCase().contains(trimmedQuery.toLowerCase()));

    _contactIcons = List.generate(suggestionList.length, (_) => false);

    for (int i = 0; i < suggestionList.length; i++) {
      Contact contact = suggestionList.elementAt(i);
      String phoneNumber = '';

      if (contact.phones != null && contact.phones!.isNotEmpty) {
        phoneNumber = contact.phones!.first.value ?? '';
      }

      bool isInFirebase =
      isContactInFirebase(phoneNumber, firebaseContactNumbers);
      _contactIcons[i] = isInFirebase;
    }

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        Contact contact = suggestionList.elementAt(index);

        return ListTile(
          title: Text(contact.displayName ?? ''),
          trailing: _contactIcons[index]
              ? IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // Handle chat action
            },
          )
              : ElevatedButton(
            onPressed: () async {
              final contact = suggestionList.elementAt(index); // Use 'searchResults' or 'suggestionList' accordingly
              final phoneNumber = contact.phones?.first.value ?? '';

              final message = 'Join the app'; // Customize your message here

              final url = 'sms:$phoneNumber?body=${Uri.encodeComponent(message)}';

              if (await canLaunch(url)) {
                await launch(url);
              } else {
                // Handle error, maybe show a snackbar or dialog
                print('Could not launch SMS app');
              }
            },
            child: const Text("Invite"),
          ),
        );
      },
    );
  }

  static bool isContactInFirebase(
      String contactNumber, List<String> firebaseContactNumbers) {
    return firebaseContactNumbers.contains(contactNumber);
  }
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  List<String> _firebaseContactNumbers = [];
  bool _loadingContacts = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getContacts();
    _loadContacts();
    _getFirebaseContactNumbers();
  }

  Future<void> _loadContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
      _loadingContacts = false;
    });
  }

  Future<void> _getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
    });
  }

  Future<void> _getFirebaseContactNumbers() async {
    QuerySnapshot snapshot = await _firestore.collection("user").get();
    List<String> contactNumbers = [];
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String phoneNumber = doc["phone"];
      contactNumbers.add(phoneNumber);
    }
    setState(() {
      _firebaseContactNumbers = contactNumbers;
    });
  }


  Future<void> _refreshContacts() async {
    try {
      setState(() {
        _loadingContacts = true;
      });
      await _getContacts();
      await _getFirebaseContactNumbers();
      setState(() {
        _loadingContacts = false;
      });

      // Show a snackbar for successful refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contacts refreshed successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      // Show a snackbar for refresh failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh contacts. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Contact> contactsInDatabase = [];
    List<Contact> contactsNotInDatabase = [];

    for (var contact in _contacts) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        String phoneNumber = contact.phones!.first.value ?? '';
        if (_firebaseContactNumbers.contains(phoneNumber)) {
          contactsInDatabase.add(contact);
        } else {
          contactsNotInDatabase.add(contact);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          if (!_loadingContacts) // Only show search icon if contacts are loaded
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).unfocus();
                showSearch(
                  context: context,
                  delegate: ContactSearchDelegate(_contacts, _firebaseContactNumbers),
                );
              },
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Refresh'),
                value: 'refresh',
              ),
              // Add more menu items here
            ],
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'refresh') {
                _refreshContacts();
              }
              // Handle other menu items if needed
            },
          ),
        ],
      ),
      body: _loadingContacts
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/loading.json',
              // Replace with your Lottie animation file path
              width: 500,
              height: 500,
            ),
            SizedBox(height: 16),
            Text(
              "Hang on, we are working on to load your contacts",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Users on text me',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.teal),
              ),
            ),
            contactsInDatabase.isEmpty
                ? Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No contacts are in text me. Invite them to chat',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: contactsInDatabase.length,
              itemBuilder: (context, index) {
                Contact contact = contactsInDatabase[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones!.first.value ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      // Handle chat action
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Invite others',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.teal),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: contactsNotInDatabase.length,
              itemBuilder: (context, index) {
                Contact contact = contactsNotInDatabase[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones!.first.value ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final phoneNumber = contact.phones?.first.value ?? '';
                      final message = 'Hey! Try out Text Me™. Download it from ....'; // Customize your message here
                      final url = 'sms:$phoneNumber?body=${Uri.encodeComponent(
                          message)}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        // Handle error, maybe show a snackbar or dialog
                        print('Could not launch SMS app');
                      }
                    },
                    child: const Text("Invite"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
