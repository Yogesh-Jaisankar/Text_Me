import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:lottie/lottie.dart';

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
            onPressed: () {
              // Handle invite action
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
            onPressed: () {
              // Handle invite action
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(_contacts, _firebaseContactNumbers),
              );
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
              'assets/lottie/loading.json', // Replace with your Lottie animation file path
              width: 100,
              height: 100,
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
          : ListView.builder(
        itemCount: contactsInDatabase.length + contactsNotInDatabase.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Users on text me title
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Users on text me',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else if (index == contactsInDatabase.length + 1) {
            // Invite others title
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Invite others',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else if (index <= contactsInDatabase.length) {
            // Users on text me contact item
            Contact contact = contactsInDatabase[index - 1];
            return ListTile(
              title: Text(contact.displayName ?? ''),
              subtitle: Text(contact.phones!.first.value ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.chat), // Chat icon for users on text me
                onPressed: () {
                  // Handle chat action
                },
              ),
            );
          } else {
            // Invite others contact item
            Contact contact = contactsNotInDatabase[index - contactsInDatabase.length - 2];
            return ListTile(
              title: Text(contact.displayName ?? ''),
              subtitle: Text(contact.phones!.first.value ?? ''),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle invite action
                },
                child: const Text("Invite"),
              ),
            );
          }
        },
      ),
    );
  }
}





