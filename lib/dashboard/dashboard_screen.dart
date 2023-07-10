import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zedor/setting_pages/SettingsUI.dart';

import '../account_pages/account_page.dart';
import '../chat/single_chat_screen.dart';
import '../custom_pin_screen/pin_authentication.dart';
import '../custom_pin_screen/theme.dart';
import '../future_builder/enhanced_future_builder_base.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';
import '../global/global_socket_connection.dart';
import '../model/get_instance_list_model.dart';
import '../model/get_user_list.dart';
import '../registration_pages/set_confirm_passcode_page.dart';
import '../sqlflite/SqliteService.dart';
import 'contact_list_page.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DashboardScreen extends StatefulWidget {
  final String? idInstance;
  final String? apiTokenInstance;
  final String? wid;
  const DashboardScreen(
      {Key? key, this.idInstance, this.apiTokenInstance, this.wid})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  TextEditingController _searchPersonTextController = TextEditingController();
  int? _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;
  String partnerToken = 'gac.290e73cf22534cc6aee8c6f3d8ac83d2a65ad87f4fc24f';

  bool isInstanceIdActive = true;
  bool isInstanceDeleted = true;
  late IO.Socket _socket;
  List<GetInstanceListModel> getInstanceList = [];
  List<GetUserListModel> getUserList = [];
  final DatabaseService _databaseService = DatabaseService();
  bool isSearching = false;
  late var timerGetAllContactList;
  late var timerConnectWebSocket;

  final lastKnownStateKey = 'lastKnownStateKey';
  final backgroundedTimeKey = 'backgroundedTimeKey';
  final pinLockMillis = 10000;

  late Box _box;

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(builder: (context) {
          return ContactListScreen();
        }),
      ).then((value) => getAllContactList());
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      global().showSnackBarShowError(
          Get.context!, "You have permanently Denied this Permission.");
      openAppSettings();
    }
  }

  Future<void> checkValidInstanceList() async {
    try {
      final uri = Uri.parse(
          "https://api.green-api.com/partner/getInstances/" + partnerToken);

      debugPrint("admin group list url: $uri");

      var requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      debugPrint("group Detail url: $requestHeaders");

      final response = await http.get(uri, headers: requestHeaders);

      debugPrint("response : " + json.decode(response.body).toString());

      dynamic responseJson;
      if (response.statusCode == 200) {
        debugPrint("success ");
        setState(() {
          responseJson = json.decode(response.body);
          getInstanceList = (responseJson as List)
              .map((data) => new GetInstanceListModel.fromJson(data))
              .toList();

          for (GetInstanceListModel getInstance in getInstanceList) {
            if (getInstance.idInstance.toString() ==
                    widget.idInstance.toString() &&
                getInstance.apiTokenInstance.toString() ==
                    widget.apiTokenInstance.toString()) {
              isInstanceIdActive = getInstance.isExpired!;
              isInstanceDeleted = getInstance.deleted!;

              if (isInstanceIdActive) {
                showSnackBarShowError(
                    Get.context!, "Your Instance Not Activate!");
              }

              if (isInstanceDeleted) {
                showSnackBarShowError(Get.context!, "Your Instance is Delete!");
              }

              break;
            }
          }
        });
      } else {
        showSnackBarShowError(
            Get.context!, "Your Instance is Delete or Not Activate!");
      }
    } catch (e) {
      showSnackBarShowError(
          Get.context!, "Your Instance is Delete or Not Activate!");
    }
  }

  @override
  initState() {
    _searchPersonTextController.addListener(_filterContactList);
    _box = Hive.box('zedorDataSave');

    WidgetsBinding.instance.addObserver(this);

    timerGetAllContactList =
        Future.delayed(const Duration(milliseconds: 700), () {
      getAllContactList();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      checkValidInstanceList();
    });

    super.initState();
  }

  Future<void> _checkWidget() async {
    bool? checkStatus = await FlutterOverlayWindow.isPermissionGranted();

    var isSetFloatingWidgetEnable =
        _box.get(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE) == null
            ? false
            : _box.get(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE);

    if (checkStatus) {
      if (isSetFloatingWidgetEnable) {
        await FlutterOverlayWindow.closeOverlay();

        _box.put(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE, true);

        await FlutterOverlayWindow.showOverlay(
          height: 150,
          width: 150,
          enableDrag: true,
          flag: OverlayFlag.defaultFlag,
          alignment: OverlayAlignment.centerLeft,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
        );
      }
    }
  }

  _filterContactList() {
    if (_searchPersonTextController.text.isNotEmpty) {
      setState(() {
        isSearching = true;
        searchContact();
      });
    } else {
      setState(() {
        isSearching = false;
        getAllContactList();
      });
    }
  }

  @override
  void dispose() {
    timerGetAllContactList.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _resumed();
        break;
      case AppLifecycleState.paused:
        _paused();
        break;
      case AppLifecycleState.inactive:
        _inactive();
        break;
      default:
        break;
    }
  }

  Future _paused() async {
    final sp = await SharedPreferences.getInstance();
    sp.setInt(lastKnownStateKey, AppLifecycleState.paused.index);
  }

  Future _inactive() async {
    final sp = await SharedPreferences.getInstance();
    final prevState = sp.getInt(lastKnownStateKey);
    final prevStateIsNotPaused = prevState != null &&
        AppLifecycleState.values[prevState] != AppLifecycleState.paused;
    if (prevStateIsNotPaused) {
      // save App backgrounded time to Shared preferences
      sp.setInt(backgroundedTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
// update previous state as inactive
    sp.setInt(lastKnownStateKey, AppLifecycleState.inactive.index);
  }

  Future _resumed() async {
    final sp = await SharedPreferences.getInstance();
    final bgTime = sp.getInt(backgroundedTimeKey) ?? 0;
    final allowedBackgroundTime = bgTime + pinLockMillis;

    final shouldShowPIN =
        DateTime.now().millisecondsSinceEpoch > allowedBackgroundTime;
    bool isSetPasswordEnable =
        _box.get(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE) == null
            ? false
            : _box.get(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE);

    bool isSetConfirmPasscodePageVis =
        _box.get(PrefKeys.SET_CONFIRM_PASSCODE_VIS) == null
            ? false
            : _box.get(PrefKeys.SET_CONFIRM_PASSCODE_VIS);

    if (isSetPasswordEnable) {
      if (shouldShowPIN) {
        if (!isSetConfirmPasscodePageVis) {
          Navigator.of(Get.context!).push(
              MaterialPageRoute(builder: (_) => SetConfirmPasscodePage()));
        }
      }
    }
    sp.remove(backgroundedTimeKey); // clean
    sp.setInt(
        lastKnownStateKey, AppLifecycleState.resumed.index); // previous state
  }

  _connectSocket() async {
    //   _socket = await GlobalSocketConnection().connectSocket();
    //   _socket.onConnect((data) => print('Connection established Successfully'));
    //  _socket.onConnectError((data) => print('Connect Error: $data'));
    //  _socket.on('message', (data) => print(' rec_message : $data'));
  }

  getAllContactList() async {
    print("Contact List  ");
    getUserList = await _databaseService.getAllContactNames();
    setState(() {});
  }

  deleteContactFromList(BuildContext context, String phone_number) async {
    if (await _databaseService.isDeleteContact(phone_number)) {
      print(" Contact Delete from List  ");
      getUserList.clear();
      getAllContactList();
      showSnackBarShowSuccess(context, "Successfully delete");
    } else {
      showSnackBarShowError(context, "Some thing wrong!");
    }
  }

  searchContact() async {
    print("Contact List search " + _searchPersonTextController.text.trim());
    getUserList = await _databaseService
        .getSearchContactByNames(_searchPersonTextController.text.trim());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        new TextEditingController().clear();
      },
      child: WillPopScope(
        child: Scaffold(
          body: Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 32,
                          child: CircleAvatar(
                            radius: 22,
                            child: ClipOval(
                              child: Image.asset("images/zedor_logo.png",
                                  fit: BoxFit.contain),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 1,
                        ),
                        Text(
                          "ZEDOR SECURE COMMUNICATION",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    PopupMenuButton<int>(
                      // Callback that sets the selected popup menu item.

                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<int>>[
                        PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: [
                              Image.asset(
                                'images/add_user.png',
                                height: 19,
                                width: 19,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                child: Text('Invite Friend'),
                                onTap: () {
                                  /*      Navigator.of(Get.context!)
                                    .push(MaterialPageRoute(
                                        builder: (_) => PinAuthentication(
                                              pinTheme: PinTheme(
                                                shape:
                                                    PinCodeFieldShape.underline,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                backgroundColor: Colors.white,
                                                keysColor: Colors.black,
                                                activeFillColor:
                                                    Colors.grey[600],
                                              ),
                                              action: "Enter Passcode",
                                              actionDescription:
                                                  "Enter passcode to unlock",
                                              onChanged: (v) {
                                                if (kDebugMode) {
                                                  print(v);
                                                }
                                              },
                                              isPinValueSuccess: false,
                                              onCompleted: (String? value) {
                                                if (kDebugMode) {
                                                  if (_box
                                                          .get(PrefKeys
                                                              .USER_SET_PASSCODE_VALUE)
                                                          .toString() ==
                                                      value) {
                                                    Navigator.pop(Get.context!);
                                                  } else {
                                                    global().showSnackBarShowError(
                                                        Get.context!,
                                                        "You have enter wrong passcode!");
                                                    print('Wrong: $value');
                                                  }
                                                }
                                              },
                                              maxLength: 4,
                                            )));*/
                                },
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                            value: 2,
                            child: InkWell(
                              child: Row(
                                children: [
                                  Icon(Icons.settings, size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    child: Text('Setting'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return SettingPage();
                                        }),
                                      );
                                    },
                                  )
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return SettingPage();
                                  }),
                                );
                              },
                            )),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 25, right: 25, top: 20),
                  height: 40,
                  child: TextField(
                    autofocus: false,
                    textAlignVertical: TextAlignVertical.top,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    controller: _searchPersonTextController,
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
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.grey,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: getUserList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = getUserList[index];
                    print("Contact List  " + item.name.toString());
                    //get your item data here ...
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return SingleChatScreen(
                              idInstance: widget.idInstance.toString(),
                              apiTokenInstance:
                                  widget.apiTokenInstance.toString(),
                              wid: "",
                              to_user_name: item.name.toString(),
                              phone_number: item.phone_number
                                  .toString()
                                  .replaceAll(RegExp('[^0-9]'), '')
                                  .replaceAll(RegExp('^0+(?=.)'), ''),
                              img: "",
                            );
                          }),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 10, bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 24,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 23,
                                        backgroundImage:
                                            AssetImage("images/profile.png"),
                                      )),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            item.name.toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            item.phone_number
                                                .toString()
                                                .replaceAll(
                                                    RegExp('[^0-9]'), '')
                                                .replaceAll(
                                                    RegExp('^0+(?=.)'), ''),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.normal),
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: Icon(
                                        Icons.delete,
                                        size: 24,
                                        color: Colors.red,
                                      )),
                                ],
                              ),
                              onTap: () {
                                showAlertDialogOkCancel(
                                    context, item.phone_number.toString());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
          floatingActionButton: new FloatingActionButton(
              elevation: 5,
              child: new Icon(Icons.add),
              backgroundColor: Colors.red,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                _searchPersonTextController.clear();
                //  new TextEditingController().clear();
                _askPermissions();
/*              final PermissionStatus permissionStatus = await _getPermission();
              if (permissionStatus == PermissionStatus.granted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ContactListScreen();
                  }),
                ).then((value) => getAllContactList());
              } else {
                global().showSnackBarShowSuccess(
                    context, "Permission " + permissionStatus.);
                await Permission.contacts.request();
              }*/
              }),
        ),
        onWillPop: _onWillPop,
      ),
    );
  }

  showAlertDialogOkCancel(BuildContext context, String phone_number) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed: () {
        Navigator.pop(context);
        deleteContactFromList(context, phone_number);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert!",
          style: TextStyle(
              fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
      content: Text("Would you want to delete this contact?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

/*  Future<bool> _handleWillPop(BuildContext context) async {
    final _currentTime = DateTime.now().millisecondsSinceEpoch;

    if (_lastTimeBackButtonWasTapped != null &&
        (_currentTime - _lastTimeBackButtonWasTapped!) < exitTimeInMillis) {
      return true;
    } else {
      _lastTimeBackButtonWasTapped = DateTime.now().millisecondsSinceEpoch;
      _getExitSnackBar(context);
      return false;
    }
  }*/

  SnackBar _getExitSnackBar(BuildContext context) {
    return SnackBar(
      content: Text(
        'Press BACK again to exit!',
        style: TextStyle(
            fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(
        seconds: 2,
      ),
      behavior: SnackBarBehavior.floating,
    );
  }
}

Future<bool> _onWillPop() async {
  return (await showDialog(
        context: Get.context!,
        builder: (context) => new AlertDialog(
          title: new Text('Alert!'),
          content: new Text('Do you want to exit from this app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('Yes'),
            ),
          ],
        ),
      )) ??
      false;
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
