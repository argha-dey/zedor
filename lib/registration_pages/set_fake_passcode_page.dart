import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zedor/registration_pages/scan_qr_code.dart';
import 'package:http/http.dart' as http;
import '../custom_pin_screen/pin_authentication.dart';
import '../custom_pin_screen/theme.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';

class SetFakePasscodePage extends StatefulWidget {
  const SetFakePasscodePage({Key? key}) : super(key: key);

  @override
  State<SetFakePasscodePage> createState() => _SetFakePasscodePageState();
}

class _SetFakePasscodePageState extends State<SetFakePasscodePage> {
  late final Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('zedorDataSave');
  }

  OtpFieldController otpFieldController = OtpFieldController();
  String pinValue = '';

  @override
  void dispose() {
    super.dispose();
  }

/*
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          body: SingleChildScrollView(
              child: Container(
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
                                width: 110,
                                height: 90,
                              ),
                              SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: 30,
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
                            height: 65,
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
                                  height: 25,
                                ),
                                Container(
                                    child: Text("Set Fake Passcode",
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold))),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Text(
                                        "Fake passcode must be different from your original passcode",
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold))),
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 25, right: 25),
                                  child: OTPTextField(
                                    controller: otpFieldController,
                                    keyboardType: TextInputType.phone,
                                    length: 4,
                                    width: MediaQuery.of(context).size.width,
                                    fieldWidth: 50,
                                    otpFieldStyle: OtpFieldStyle(
                                        disabledBorderColor: Colors.black26,
                                        enabledBorderColor: Colors.black26),
                                    style: TextStyle(fontSize: 17),
                                    textFieldAlignment:
                                        MainAxisAlignment.spaceAround,
                                    fieldStyle: FieldStyle.underline,
                                    onCompleted: (pin) {
                                      pinValue = pin;
                                      print("Completed: " + pinValue);
                                    },
                                    onChanged: (pin) {
                                      print("check : " + pin);
                                      pinValue = pin;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.180,
                                ),
                                InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 35, right: 35),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            'images/button_background.png',
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(
                                              top: 14,
                                            ),
                                            child: Text(
                                              "Continue",
                                              // textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            )),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if (pinValue.trim().length == 4) {
                                      if (box
                                              .get(PrefKeys
                                                  .USER_SET_PASSCODE_VALUE)
                                              .toString() ==
                                          pinValue.trim().toString()) {
                                        _onAlert(
                                            "Kindly set your fake passcode must be different from your original passcode");
                                      } else {
                                        box.put(
                                            PrefKeys
                                                .USER_SET_FAKE_PASSCODE_VALUE,
                                            pinValue.trim().toString());
                                        box.put(
                                            PrefKeys
                                                .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
                                            true);
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      _onAlert("Kindly Set 4-digit Pin");
                                    }
                                  },
                                )
                              ],
                            ),
                          ))
                        ],
                      ),
                    ],
                  )))),
      onWillPop: _onWillPop,
    );
  }
*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ScaffoldGradientBackground(
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
                  width: 110,
                  height: 90,
                ),
                SizedBox(),
              ],
            ),
            SizedBox(
              height: 30,
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
              height: 65,
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
                  //Your SingleChildScrollView Widget
                  child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                          child: Text("Set Fake Passcode",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                              "Fake passcode must be different from your original passcode",
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 25, right: 25),
                        child: OTPTextField(
                          controller: otpFieldController,
                          keyboardType: TextInputType.phone,
                          length: 4,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 50,
                          otpFieldStyle: OtpFieldStyle(
                              disabledBorderColor: Colors.black26,
                              enabledBorderColor: Colors.black26),
                          style: TextStyle(fontSize: 17),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.underline,
                          onCompleted: (pin) {
                            pinValue = pin;
                            print("Completed: " + pinValue);
                          },
                          onChanged: (pin) {
                            print("check : " + pin);
                            pinValue = pin;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.180,
                      ),
                      InkWell(
                        child: Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 35, right: 35),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'images/button_background.png',
                                ),
                              ),
                              Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                    top: 14,
                                  ),
                                  child: Text(
                                    "Continue",
                                    // textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  )),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (pinValue.trim().length == 4) {
                            if (box
                                    .get(PrefKeys.USER_SET_PASSCODE_VALUE)
                                    .toString() ==
                                pinValue.trim().toString()) {
                              _onAlert(
                                  "Kindly set your fake passcode must be different from your original passcode");
                            } else {
                              box.put(PrefKeys.USER_SET_FAKE_PASSCODE_VALUE,
                                  pinValue.trim().toString());
                              box.put(
                                  PrefKeys
                                      .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
                                  true);
                              Navigator.pop(context);
                            }
                          } else {
                            _onAlert("Kindly Set 4-digit Pin");
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  _onAlert(String meg) async {
    await showDialog(
      context: Get.context!,
      builder: (context) => new AlertDialog(
        title: new Text(
          'Alert!',
          style: TextStyle(color: Colors.red),
        ),
        content: new Text(
          meg,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }
}
