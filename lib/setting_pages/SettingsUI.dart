import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:zedor/registration_pages/set_fake_passcode_page.dart';

import '../global/PrefKeys.dart';
import '../global/global.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late Box _box;
  bool isSetPasswordEnable = true;
  bool isSetFakePasswordEnable = true;
  bool isSetFloatingWidgetEnable = false;

  @override
  void initState() {
    _box = Hive.box('zedorDataSave');

    isSetPasswordEnable =
        _box.get(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE) == null
            ? false
            : _box.get(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE);

    isSetFakePasswordEnable =
        _box.get(PrefKeys.USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE) == null
            ? false
            : _box.get(PrefKeys.USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE);

    isSetFloatingWidgetEnable =
        _box.get(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE) == null
            ? false
            : _box.get(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE);

/* if (isSetFloatingWidgetEnable) {
      _checkPermissions(isSetFloatingWidgetEnable);
    } else {
      _checkPermissions(isSetFloatingWidgetEnable);
    }
    */
  }

  Future<void> _checkPermissions(bool val) async {
    bool? checkStatus = await FlutterOverlayWindow.isPermissionGranted();
    if (!checkStatus) {
      // await FlutterOverlayWindow.requestPermission();
      final bool? status = await FlutterOverlayWindow.requestPermission();
      if (status!) {
        setState(() async {
          isSetFloatingWidgetEnable = val;

          _box.put(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE,
              isSetFloatingWidgetEnable);

          if (isSetFloatingWidgetEnable) {
            if (await FlutterOverlayWindow.isActive()) {
              print("@@Active already");
            } else {
              print("@@Active Now");
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
        });
      }
    } else {
      setState(() {
        isSetFloatingWidgetEnable = val;

        _box.put(PrefKeys.FLOATING_WIDGET_ENABLE_ENABLE_DISABLE,
            isSetFloatingWidgetEnable);
      });

      if (isSetFloatingWidgetEnable) {
        if (await FlutterOverlayWindow.isActive()) {
          print("@@Active already");
        } else {
          print("@@Active Now");
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
      } else {
        await FlutterOverlayWindow.closeOverlay();
      }
    }
  }

/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
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
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(),
                      Image.asset(
                        "images/zedor_logo.png",
                        width: 100,
                        height: 90,
                      ),
                      SizedBox(),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(),
                      Container(
                          child: Text("Welcome!",
                              style: TextStyle(
                                  fontSize: 21,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Expanded(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(65),
                            topRight: Radius.circular(65))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Text("Settings",
                                style: TextStyle(
                                    fontFamily: 'HelveticaNeueMedium',
                                    fontSize: 24,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 15, bottom: 1),
                                child: Text(
                                  "Passcode Enable",
                                  style: TextStyle(
                                      fontFamily: 'HelveticaNeueMedium',
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 18),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: FlutterSwitch(
                                    width: 60,
                                    height: 30,
                                    activeTextColor: Colors.white,
                                    inactiveTextColor: Colors.white,
                                    activeTextFontWeight: FontWeight.w400,
                                    inactiveTextFontWeight: FontWeight.w400,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.red,
                                    toggleSize: 29,
                                    activeText: '',
                                    inactiveText: '',
                                    value: isSetPasswordEnable,
                                    showOnOff: true,
                                    onToggle: (bool val) {
                                      setState(() {
                                        isSetPasswordEnable = val;
                                        _box.put(
                                            PrefKeys
                                                .USER_IS_SET_PASSCODE_ENABLE_DISABLE,
                                            isSetPasswordEnable);
                                      });
                                    }),
                              ),
                            ]),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 15, bottom: 1),
                                child: Text(
                                  "Fake Passcode Enable",
                                  style: TextStyle(
                                      fontFamily: 'HelveticaNeueMedium',
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 18),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: FlutterSwitch(
                                    width: 60,
                                    height: 30,
                                    activeTextColor: Colors.white,
                                    inactiveTextColor: Colors.white,
                                    activeTextFontWeight: FontWeight.w400,
                                    inactiveTextFontWeight: FontWeight.w400,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.red,
                                    toggleSize: 29,
                                    activeText: '',
                                    inactiveText: '',
                                    value: isSetFakePasswordEnable,
                                    showOnOff: true,
                                    onToggle: (bool val) {
                                      if (isSetPasswordEnable) {
                                        if (!isSetFakePasswordEnable) {
                                          Navigator.of(Get.context!)
                                              .push(MaterialPageRoute(
                                                  builder: (_) =>
                                                      SetFakePasscodePage()))
                                              .then((value) => {
                                                    setState(() {
                                                      bool isSetFakePassword = _box
                                                                  .get(PrefKeys
                                                                      .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE) ==
                                                              null
                                                          ? false
                                                          : _box.get(PrefKeys
                                                              .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE);

                                                      _box.put(
                                                          PrefKeys
                                                              .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
                                                          isSetFakePassword);

                                                      isSetFakePasswordEnable =
                                                          isSetFakePassword;
                                                    })
                                                  });
                                        } else {
                                          setState(() {
                                            isSetFakePasswordEnable = val;
                                            _box.put(
                                                PrefKeys
                                                    .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
                                                isSetFakePasswordEnable);
                                          });
                                        }
                                      } else {
                                        global().showSnackBarShowError(context,
                                            "Kindly enable passcode before enable fake passcode.");
                                      }
                                    }),
                              ),
                            ]),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 15, bottom: 1),
                                child: Text(
                                  "Floating Widget Enable",
                                  style: TextStyle(
                                      fontFamily: 'HelveticaNeueMedium',
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 18),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: FlutterSwitch(
                                    width: 60,
                                    height: 30,
                                    activeTextColor: Colors.white,
                                    inactiveTextColor: Colors.white,
                                    activeTextFontWeight: FontWeight.w400,
                                    inactiveTextFontWeight: FontWeight.w400,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.red,
                                    toggleSize: 29,
                                    activeText: '',
                                    inactiveText: '',
                                    value: isSetFloatingWidgetEnable,
                                    showOnOff: true,
                                    onToggle: (bool val) {
                                      _checkPermissions(val);
                                    }),
                              ),
                            ]),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            left: 15,
                          ),
                          child: Text(
                            "About",
                            style: TextStyle(
                                fontFamily: 'HelveticaNeueMedium',
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 19),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 15, top: 10),
                          child: Text(
                            "Chat applications allow you to stay connected with other people who may be using the application even on the other side of the world. In customer service, such applications are one of the most important communication channels",
                            style: TextStyle(
                                fontFamily: 'HelveticaNeueMedium',
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ],
          )),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFff1616),
          Color(0xfffcaf7a),
          Color(0xfffdf8e4),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 40,
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
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              Image.asset(
                "images/zedor_logo.png",
                width: 100,
                height: 90,
              ),
              SizedBox(),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              Container(
                  child: Text("Welcome!",
                      style: TextStyle(
                          fontSize: 21,
                          color: Colors.red,
                          fontWeight: FontWeight.bold))),
              SizedBox(),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Expanded(
              child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                      child: Text("Settings",
                          style: TextStyle(
                              fontFamily: 'HelveticaNeueMedium',
                              fontSize: 24,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold))),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 15, bottom: 1),
                          child: Text(
                            "Passcode Enable",
                            style: TextStyle(
                                fontFamily: 'HelveticaNeueMedium',
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: FlutterSwitch(
                              width: 60,
                              height: 30,
                              activeTextColor: Colors.white,
                              inactiveTextColor: Colors.white,
                              activeTextFontWeight: FontWeight.w400,
                              inactiveTextFontWeight: FontWeight.w400,
                              activeColor: Colors.green,
                              inactiveColor: Colors.red,
                              toggleSize: 29,
                              activeText: '',
                              inactiveText: '',
                              value: isSetPasswordEnable,
                              showOnOff: true,
                              onToggle: (bool val) {
                                setState(() {
                                  isSetPasswordEnable = val;
                                  _box.put(
                                      PrefKeys
                                          .USER_IS_SET_PASSCODE_ENABLE_DISABLE,
                                      isSetPasswordEnable);
                                });
                              }),
                        ),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 15, bottom: 1),
                          child: Text(
                            "Fake Passcode Enable",
                            style: TextStyle(
                                fontFamily: 'HelveticaNeueMedium',
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: FlutterSwitch(
                              width: 60,
                              height: 30,
                              activeTextColor: Colors.white,
                              inactiveTextColor: Colors.white,
                              activeTextFontWeight: FontWeight.w400,
                              inactiveTextFontWeight: FontWeight.w400,
                              activeColor: Colors.green,
                              inactiveColor: Colors.red,
                              toggleSize: 29,
                              activeText: '',
                              inactiveText: '',
                              value: isSetFakePasswordEnable,
                              showOnOff: true,
                              onToggle: (bool val) {
                                if (isSetPasswordEnable) {
                                  if (!isSetFakePasswordEnable) {
                                    Navigator.of(Get.context!)
                                        .push(MaterialPageRoute(
                                            builder: (_) =>
                                                SetFakePasscodePage()))
                                        .then((value) => {
                                              setState(() {
                                                bool isSetFakePassword = _box
                                                            .get(PrefKeys
                                                                .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE) ==
                                                        null
                                                    ? false
                                                    : _box.get(PrefKeys
                                                        .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE);

                                                _box.put(
                                                    PrefKeys
                                                        .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
                                                    isSetFakePassword);

                                                isSetFakePasswordEnable =
                                                    isSetFakePassword;
                                              })
                                            });
                                  } else {
                                    setState(() {
                                      isSetFakePasswordEnable = val;
                                      _box.put(
                                          PrefKeys
                                              .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
                                          isSetFakePasswordEnable);
                                    });
                                  }
                                } else {
                                  global().showSnackBarShowError(context,
                                      "Kindly enable passcode before enable fake passcode.");
                                }
                              }),
                        ),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 15, bottom: 1),
                          child: Text(
                            "Floating Widget Enable",
                            style: TextStyle(
                                fontFamily: 'HelveticaNeueMedium',
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: FlutterSwitch(
                              width: 60,
                              height: 30,
                              activeTextColor: Colors.white,
                              inactiveTextColor: Colors.white,
                              activeTextFontWeight: FontWeight.w400,
                              inactiveTextFontWeight: FontWeight.w400,
                              activeColor: Colors.green,
                              inactiveColor: Colors.red,
                              toggleSize: 29,
                              activeText: '',
                              inactiveText: '',
                              value: isSetFloatingWidgetEnable,
                              showOnOff: true,
                              onToggle: (bool val) {
                                _checkPermissions(val);
                              }),
                        ),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(
                      left: 15,
                    ),
                    child: Text(
                      "About",
                      style: TextStyle(
                          fontFamily: 'HelveticaNeueMedium',
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 19),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 15, top: 10),
                    child: Text(
                      "Chat applications allow you to stay connected with other people who may be using the application even on the other side of the world. In customer service, such applications are one of the most important communication channels",
                      style: TextStyle(
                          fontFamily: 'HelveticaNeueMedium',
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

/*  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }*/
}
