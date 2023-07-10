import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zedor/registration_pages/scan_qr_code.dart';
import 'package:http/http.dart' as http;
import 'package:zedor/registration_pages/set_confirm_passcode_page.dart';
import 'package:zedor/registration_pages/set_re_enter_passcode_page.dart';
import '../custom_pin_screen/pin_authentication.dart';
import '../custom_pin_screen/theme.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

class SetPasscodePage extends StatefulWidget {
  const SetPasscodePage({Key? key}) : super(key: key);

  @override
  State<SetPasscodePage> createState() => _SetPasscodePageState();
}

class _SetPasscodePageState extends State<SetPasscodePage> {
  late final Box box;

  bool isNewPasscodeSet = false;
  String setPasscodeTextValue = "Set Your Passcode";

  bool? isPinValueSuccess = false;

  Timer? countdownTimer;
  Duration myDuration = Duration(seconds: 0);
  int number_of_enter_wrong_passcode = 0;

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

  @override
  void initState() {
    super.initState();
    box = Hive.box('zedorDataSave');

    // Set passcode from
    box.put(PrefKeys.SET_CONFIRM_PASSCODE_VIS, false);
    box.put(PrefKeys.SET_FAKE_PASSCODE_PAGE_VISIBLE, false);

    isNewPasscodeSet = box.get(PrefKeys.USER_IS_SET_PASSCODE) == null
        ? false
        : box.get(PrefKeys.USER_IS_SET_PASSCODE);

    box.put(
        PrefKeys.USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE,
        box.get(PrefKeys.USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE) == null
            ? false
            : box.get(PrefKeys.USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE));

    if (isNewPasscodeSet) {
      setPasscodeTextValue = "Enter Your Passcode";
    } else {
      setPasscodeTextValue = "Set Your Passcode";
    }
  }

  OtpFieldController otpFieldController = OtpFieldController();
  String pinValue = '';
  String partnerToken = 'gac.290e73cf22534cc6aee8c6f3d8ac83d2a65ad87f4fc24f';

  Future<void> createNewInstance() async {
    try {
      FocusScope.of(context).requestFocus(FocusNode());
      global().showLoader(context);
      final uri = Uri.parse(
          "https://api.green-api.com/partner/createInstance/" + partnerToken);

      debugPrint("admin group list url: $uri");

      var requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var requestBody = {
        "webhookUrl": "https://py-zedor.developerconsole.xyz/webhook",
        "webhookUrlToken": "",
        "delaySendMessagesMilliseconds": 100,
        "markIncomingMessagesReaded": "yes",
        "markIncomingMessagesReadedOnReply": "yes",
        "outgoingWebhook": "yes",
        "outgoingMessageWebhook": "yes",
        "outgoingAPIMessageWebhook": "yes",
        "incomingWebhook": "yes",
        "deviceWebhook": "yes",
        "stateWebhook": "yes",
        "enableMessagesHistory": "yes",
        "keepOnlineStatus": "yes"
      };

      debugPrint("group Detail url: $requestHeaders");

      final response = await http.post(uri,
          body: jsonEncode(requestBody), headers: requestHeaders);

      debugPrint("response : " + json.decode(response.body).toString());

      global().hideLoader(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("success ");

        //  responseJson = json.decode(response.body);
        Map<String, dynamic> map = json.decode(response.body);
        var idInstance = map["idInstance"];
        var apiTokenInstance = map["apiTokenInstance"];
        var typeInstance = map["typeInstance"];
        box.put(PrefKeys.USER_GREEN_API_INSTANCE_ID, idInstance.toString());
        box.put(PrefKeys.USER_GREEN_API_TOKEN_INSTANCE,
            apiTokenInstance.toString());
        box.put(PrefKeys.USER_GREEN_API_TYPE_INSTANCE, typeInstance.toString());
        box.put(PrefKeys.USER_IS_CREATE_INSTANCE, true);
        box.put(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE, true);

        Get.off(() => SetReEnterPasscodePage());
      } else {
        global().showSnackBarShowError(
            context, "Data parsing error!.Try after some time.");
      }
    } catch (e) {
      global().hideLoader(context);
      global().showSnackBarShowError(
          context, "Data parsing error!.Try after some time.");
    }
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
                            height: 70,
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
                                    child: Text(setPasscodeTextValue,
                                        style: TextStyle(
                                            fontSize: 19,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold))),
                                SizedBox(
                                  height: 30,
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
                                  height: 40,
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
                                                    top: 10,
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
                                            if (isNewPasscodeSet) {
                                              if (box
                                                      .get(PrefKeys
                                                          .USER_SET_PASSCODE_VALUE)
                                                      .toString() ==
                                                  pinValue.trim().toString()) {
                                                Get.off(() => ScanQrCodePage());
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
                                              box.put(
                                                  PrefKeys.USER_IS_SET_PASSCODE,
                                                  true);

                                              bool isNewInstantCreated = box
                                                          .get(PrefKeys
                                                              .USER_IS_CREATE_INSTANCE) ==
                                                      null
                                                  ? false
                                                  : box.get(PrefKeys
                                                      .USER_IS_CREATE_INSTANCE);
                                              if (!isNewInstantCreated) {
                                                box.put(
                                                    PrefKeys
                                                        .USER_SET_PASSCODE_VALUE,
                                                    pinValue.trim().toString());
                                                createNewInstance();
                                              } else {
                                                Get.off(() => ScanQrCodePage());
                                              }
                                            }
                                          } else {
                                            setState(() {
                                              number_of_enter_wrong_passcode =
                                                  0;
                                            });
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
                          child: Text(setPasscodeTextValue,
                              style: TextStyle(
                                  fontSize: 19,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 50,
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
                        height: MediaQuery.of(context).size.height * 0.150,
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
                                  if (isNewPasscodeSet) {
                                    if (box
                                            .get(PrefKeys
                                                .USER_SET_PASSCODE_VALUE)
                                            .toString() ==
                                        pinValue.trim().toString()) {
                                      Get.off(() => ScanQrCodePage());
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
                                    box.put(
                                        PrefKeys.USER_IS_SET_PASSCODE, true);

                                    bool isNewInstantCreated = box.get(PrefKeys
                                                .USER_IS_CREATE_INSTANCE) ==
                                            null
                                        ? false
                                        : box.get(
                                            PrefKeys.USER_IS_CREATE_INSTANCE);
                                    if (!isNewInstantCreated) {
                                      box.put(PrefKeys.USER_SET_PASSCODE_VALUE,
                                          pinValue.trim().toString());
                                      createNewInstance();
                                    } else {
                                      Get.off(() => ScanQrCodePage());
                                    }
                                  }
                                } else {
                                  setState(() {
                                    number_of_enter_wrong_passcode = 0;
                                  });
                                  global().showSnackBarShowError(
                                      context, "Kindly Set 4-digit Pin");
                                }
                              },
                            )
                          : Container(),
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
