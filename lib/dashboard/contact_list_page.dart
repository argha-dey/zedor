import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global/global.dart';
import '../model/get_user_list.dart';
import '../sqlflite/SqliteService.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  TextEditingController _searchContactPersonTextController =
      new TextEditingController();
  bool isSearching = false;

  List<Contact> contactsList = [];
  List<Contact> contactsFiltered = [];

  final DatabaseService _databaseService = DatabaseService();
  @override
  initState() {
    _searchContactPersonTextController.addListener(_filterContactList);
    super.initState();
  }

  Future<List<Contact>> _fetchContactListListItems() async {
    List<Contact> contactsListTemp = await ContactsService.getContacts(
        withThumbnails: false, photoHighResolution: false);
    contactsListTemp = contactsListTemp
        .where((contact) => (contact.phones!.length != 0))
        .toList();

    return contactsListTemp;
  }

  Future<void> _onSave(Contact _contact) async {
    print(_contact.phones![0].value.toString());
    bool isExist =
        await _databaseService.checkValue(_contact.phones![0].value.toString());
    print(isExist);

    if (isExist) {
      showSnackBarShowError(context,
          _contact.displayName.toString() + "Already added to your chat list");
    } else {
      await _databaseService.insertContact(GetUserListModel(
          name: _contact.displayName.toString(),
          phone_number: _contact.phones![0].value
              .toString()
              .replaceAll(RegExp('[^0-9]'), '')
              .replaceAll(RegExp('^0+(?=.)'), ''),
          addStatus: "1"));
      showSnackBarShowSuccess(
          context,
          _contact.displayName.toString() +
              " Successfully add to your chat list");
    }
  }

  _filterContactList() {
    List<Contact> _contactsList = [];
    _contactsList.addAll(contactsList);
    if (_searchContactPersonTextController.text.isNotEmpty) {
      isSearching = true;
      _contactsList.retainWhere((contact) {
        String searchName =
            _searchContactPersonTextController.text.toUpperCase();
        String displayName = contact.displayName.toString().toUpperCase();
        bool nameMatches = displayName.contains(searchName);
        return nameMatches == true ? true : false;
      });
      setState(() {
        contactsFiltered = _contactsList;
      });
    } else {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    InkWell(
                      child: Container(
                        child: Icon(Icons.arrow_back_outlined),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Contact List",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 25, right: 25, top: 20),
              height: 40,
              child: TextField(
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.left,
                maxLines: 1,
                autofocus: false,
                controller: _searchContactPersonTextController,
                decoration: InputDecoration(
                  labelText: "search contact",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontFamily: 'HelveticaLight',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 25,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.black26)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
                // controller: _controller,
              ),
            ),
            FutureBuilder<List<Contact>>(
                future: _fetchContactListListItems(),
                builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    contactsList =
                        isSearching ? contactsFiltered : snapshot.data!;
                    return Expanded(
                        child: ListView.builder(
                            itemCount: contactsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Uint8List? image = contactsList[index].avatar;

                              return InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, top: 10, bottom: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            (contactsList[index]
                                                        .avatar!
                                                        .length ==
                                                    0)
                                                ? /*CircleAvatar(
                                                    radius: 22,
                                                    backgroundImage: NetworkImage(
                                                        "https://ui-avatars.com/api/?name=AD" +
                                                            contactsList[index]
                                                                .displayName
                                                                .toString()
                                                                .toUpperCase()),
                                                  )*/
                                                CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    radius: 24,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      radius: 23,
                                                      backgroundImage: AssetImage(
                                                          "images/profile.png"),
                                                    ))
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    radius: 24,
                                                    child: CircleAvatar(
                                                      radius: 23,
                                                      backgroundImage:
                                                          MemoryImage(
                                                              contactsList[
                                                                      index]
                                                                  .avatar!),
                                                    )),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    contactsList[index]
                                                                .displayName ==
                                                            null
                                                        ? Text(
                                                            "Unknown",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : Text(
                                                            contactsList[index]
                                                                .displayName
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      contactsList[index]
                                                          .phones![0]
                                                          .value
                                                          .toString()
                                                          .replaceAll(
                                                              RegExp('[^0-9]'),
                                                              '')
                                                          .replaceAll(
                                                              RegExp(
                                                                  '^0+(?=.)'),
                                                              ''),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: Text(
                                                "+",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                    fontSize: 28),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          _onSave(contactsList[index]);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }));
                  }
                })
          ],
        ),
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarShowError(
    BuildContext context, String title) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Text(
        title,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
    showSnackBarShowSuccess(BuildContext context, String title) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      content: Text(
        title,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
