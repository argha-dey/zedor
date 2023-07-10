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
import 'package:zedor/dashboard/dashboard_fake_screen.dart';
import 'package:zedor/registration_pages/scan_qr_code.dart';
import 'package:http/http.dart' as http;
import '../custom_pin_screen/pin_authentication.dart';
import '../custom_pin_screen/theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';

class SetConfirmPasscodePage extends StatefulWidget {
  const SetConfirmPasscodePage({Key? key}) : super(key: key);

  @override
  State<SetConfirmPasscodePage> createState() => _SetConfirmPasscodePageState();
}

class _SetConfirmPasscodePageState extends State<SetConfirmPasscodePage> {
  late final Box box;
  Timer? countdownTimer;
  Duration myDuration = Duration(seconds: 0);
  int number_of_enter_wrong_passcode = 0;

  @override
  void initState() {
    super.initState();
    box = Hive.box('zedorDataSave');
    box.put(PrefKeys.SET_CONFIRM_PASSCODE_VIS, true);
  }

  OtpFieldController otpFieldController = OtpFieldController();
  String pinValue = '';

  void startTimer() {
    myDuration = Duration(seconds: 60);
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  // Step 4
  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  // Step 5
  void resetTimer() {
    number_of_enter_wrong_passcode = 0;
    stopTimer();
    setState(() => myDuration = Duration(seconds: 60));
  }

  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;

      if (seconds == 0) {
        pinValue = "";
        otpFieldController.clear();
        number_of_enter_wrong_passcode = 0;
      }

      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

/*  @override
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
                            height: 80,
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
                                    child: Text("Enter Passcode",
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold))),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    child: Text("Enter passcode to unlock",
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
                                (myDuration.inSeconds == 60 ||
                                        myDuration.inSeconds == 0)
                                    ? Container()
                                    : Container(
                                        child: Text(
                                            "Zedor interface blocked for " +
                                                "${myDuration.inSeconds} sec",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.red,
                                                fontWeight:
                                                    FontWeight.normal))),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.180,
                                ),
                                (myDuration.inSeconds == 60 ||
                                        myDuration.inSeconds == 0)
                                    ? InkWell(
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
                                              var idInstance = box.get(PrefKeys
                                                  .USER_GREEN_API_INSTANCE_ID);
                                              var apiTokenInstance = box.get(
                                                  PrefKeys
                                                      .USER_GREEN_API_TOKEN_INSTANCE);
                                              var wid = "";

                                              box.put(
                                                  PrefKeys
                                                      .SET_CONFIRM_PASSCODE_VIS,
                                                  false);

                                              Navigator.pop(context);

                                              Navigator.of(Get.context!).push(
                                                  MaterialPageRoute(
                                                      builder: (_) => DashboardScreen(
                                                          idInstance: idInstance
                                                              .toString(),
                                                          apiTokenInstance:
                                                              apiTokenInstance
                                                                  .toString(),
                                                          wid:
                                                              wid.toString())));
                                            } else if (box.get(PrefKeys
                                                .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE)) {
                                              if (box
                                                      .get(PrefKeys
                                                          .USER_SET_FAKE_PASSCODE_VALUE)
                                                      .toString() ==
                                                  pinValue.trim().toString()) {
                                                box.put(
                                                    PrefKeys
                                                        .SET_CONFIRM_PASSCODE_VIS,
                                                    false);

                                                Navigator.pop(context);

                                                Navigator.of(Get.context!).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            DashboardFakeScreen()));
                                              } else {
                                                number_of_enter_wrong_passcode =
                                                    number_of_enter_wrong_passcode +
                                                        1;
                                                if (number_of_enter_wrong_passcode >=
                                                    3) {
                                                  startTimer();
                                                } else {
                                                  showDialog(
                                                    context: Get.context!,
                                                    builder: (context) =>
                                                        new AlertDialog(
                                                      title: new Text(
                                                        'Alert!',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      content: new Text(
                                                        'You have enter wrong passcode!.\nIf you enter wrong passcode more then 3 times the Zedor account will be block for 1 min.',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true),
                                                          child: new Text('OK'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              }
                                            } else {
                                              number_of_enter_wrong_passcode =
                                                  number_of_enter_wrong_passcode +
                                                      1;
                                              if (number_of_enter_wrong_passcode >=
                                                  3) {
                                                startTimer();
                                              } else {
                                                showDialog(
                                                  context: Get.context!,
                                                  builder: (context) =>
                                                      new AlertDialog(
                                                    title: new Text(
                                                      'Alert!',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    content: new Text(
                                                      'You have enter wrong passcode!.\nIf you enter wrong passcode more then 3 times the Zedor account will be block for 1 min.',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: new Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            }
                                          } else {
                                            global().showSnackBarShowError(
                                                context,
                                                "Kindly Set 4-digit Pin");
                                          }
                                        },
                                      )
                                    : Container()
                              ],
                            ),
                          ))
                        ],
                      ),
                    ],
                  )))),
      onWillPop: _onWillPop,
    );
  }*/

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
              height: 80,
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
                          child: Text("Enter Passcode",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          child: Text("Enter passcode to unlock",
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
                      (myDuration.inSeconds == 60 || myDuration.inSeconds == 0)
                          ? Container()
                          : Container(
                              child: Text(
                                  "Zedor interface blocked for " +
                                      "${myDuration.inSeconds} sec",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.normal))),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.180,
                      ),
                      (myDuration.inSeconds == 60 || myDuration.inSeconds == 0)
                          ? InkWell(
                              child: Container(
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 35, right: 35),
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
                                          .get(PrefKeys.USER_SET_PASSCODE_VALUE)
                                          .toString() ==
                                      pinValue.toString()) {
                                    var idInstance = box.get(
                                        PrefKeys.USER_GREEN_API_INSTANCE_ID);
                                    var apiTokenInstance = box.get(
                                        PrefKeys.USER_GREEN_API_TOKEN_INSTANCE);
                                    var wid = "";

                                    box.put(PrefKeys.SET_CONFIRM_PASSCODE_VIS,
                                        false);

                                    Navigator.pop(context);

                                    Navigator.of(Get.context!).push(
                                        MaterialPageRoute(
                                            builder: (_) => DashboardScreen(
                                                idInstance:
                                                    idInstance.toString(),
                                                apiTokenInstance:
                                                    apiTokenInstance.toString(),
                                                wid: wid.toString())));
                                  } else if (box.get(PrefKeys
                                      .USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE)) {
                                    if (box
                                            .get(PrefKeys
                                                .USER_SET_FAKE_PASSCODE_VALUE)
                                            .toString() ==
                                        pinValue.trim().toString()) {
                                      box.put(PrefKeys.SET_CONFIRM_PASSCODE_VIS,
                                          false);

                                      Navigator.pop(context);

                                      Navigator.of(Get.context!).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  DashboardFakeScreen()));
                                    } else {
                                      number_of_enter_wrong_passcode =
                                          number_of_enter_wrong_passcode + 1;
                                      if (number_of_enter_wrong_passcode >= 3) {
                                        startTimer();
                                      } else {
                                        showDialog(
                                          context: Get.context!,
                                          builder: (context) => new AlertDialog(
                                            title: new Text(
                                              'Alert!',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            content: new Text(
                                              'You have enter wrong passcode!.\nIf you enter wrong passcode more then 3 times the Zedor account will be block for 1 min.',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: new Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    number_of_enter_wrong_passcode =
                                        number_of_enter_wrong_passcode + 1;
                                    if (number_of_enter_wrong_passcode >= 3) {
                                      startTimer();
                                    } else {
                                      showDialog(
                                        context: Get.context!,
                                        builder: (context) => new AlertDialog(
                                          title: new Text(
                                            'Alert!',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          content: new Text(
                                            'You have enter wrong passcode!.\nIf you enter wrong passcode more then 3 times the Zedor account will be block for 1 min.',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: new Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  global().showSnackBarShowError(
                                      context, "Kindly Set 4-digit Pin");
                                }
                              },
                            )
                          : Container()
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

  Future<bool> _onWillPop() async {
    return false;
  }
}

/*  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: Get.context!,
          builder: (context) => new AlertDialog(
            title: new Text(
              'Alert!',
              style: TextStyle(color: Colors.red),
            ),
            content: new Text(
              'Kindly enter passcode to unlock!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )) ??
        false;
  }*/
