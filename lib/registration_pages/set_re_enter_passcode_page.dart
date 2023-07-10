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
import 'package:zedor/dashboard/dashboard_screen.dart';
import 'package:zedor/registration_pages/scan_qr_code.dart';
import 'package:http/http.dart' as http;
import '../custom_pin_screen/pin_authentication.dart';
import '../custom_pin_screen/theme.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';

class SetReEnterPasscodePage extends StatefulWidget {
  const SetReEnterPasscodePage({Key? key}) : super(key: key);

  @override
  State<SetReEnterPasscodePage> createState() => _SetReEnterPasscodePageState();
}

class _SetReEnterPasscodePageState extends State<SetReEnterPasscodePage> {
  late final Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('zedorDataSave');
  }

  OtpFieldController otpFieldController = OtpFieldController();
  String pinValue = '';

/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          height: 90,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(),
                            Image.asset(
                              "images/zedor_logo.png",
                              width: 120,
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
                          height: 70,
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
                                  child: Text("Enter Confirm Passcode",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                height: 45,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.185,
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
                                        pinValue.toString()) {
                                      Get.off(() => ScanQrCodePage());
                                    } else {
                                      global().showSnackBarShowError(
                                          Get.context!,
                                          "You have enter wrong passcode!");
                                    }
                                  } else {
                                    global().showSnackBarShowError(
                                        context, "Kindly Set 4-digit Pin");
                                  }
                                },
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ],
                ))));
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
            height: 90,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              Image.asset(
                "images/zedor_logo.png",
                width: 120,
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
            height: 70,
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
                      height: 30,
                    ),
                    Container(
                        child: Text("Enter Confirm Passcode",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold))),
                    SizedBox(
                      height: 45,
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
                      height: MediaQuery.of(context).size.height * 0.185,
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
                              pinValue.toString()) {
                            Get.off(() => ScanQrCodePage());
                          } else {
                            global().showSnackBarShowError(
                                Get.context!, "You have enter wrong passcode!");
                          }
                        } else {
                          global().showSnackBarShowError(
                              context, "Kindly Set 4-digit Pin");
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
    );
  }
}
