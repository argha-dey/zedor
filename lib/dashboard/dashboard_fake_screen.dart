import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class DashboardFakeScreen extends StatefulWidget {
  const DashboardFakeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardFakeScreen> createState() => _DashboardFakeScreenState();
}

class _DashboardFakeScreenState extends State<DashboardFakeScreen>
    with WidgetsBindingObserver {
  TextEditingController _searchPersonTextController = TextEditingController();

  late Box _box;
  @override
  initState() {
    _box = Hive.box('zedorDataSave');
    _box.put(PrefKeys.SET_FAKE_PASSCODE_PAGE_VISIBLE, true);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
                        <PopupMenuEntry<int>>[],
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 25, right: 25, top: 20),
                height: 40,
                child: TextField(
                  autofocus: false,
                  enabled: false,
                  enableInteractiveSelection: false,
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
            ],
          ),
        ),
      ),
      onWillPop: _onWillPop,
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
              onPressed: () {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              },
              child: new Text('Yes'),
            ),
          ],
        ),
      )) ??
      false;
}
