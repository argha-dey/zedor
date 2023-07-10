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
import '../custom_pin_screen/pin_authentication.dart';
import '../custom_pin_screen/pin_code_field.dart';
import '../custom_pin_screen/theme.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';

class SetConfirmPasscodePageDemo extends StatefulWidget {
  const SetConfirmPasscodePageDemo({Key? key}) : super(key: key);

  @override
  State<SetConfirmPasscodePageDemo> createState() =>
      _SetConfirmPasscodePageDemoState();
}

class _SetConfirmPasscodePageDemoState
    extends State<SetConfirmPasscodePageDemo> {
  late final Box box;
  String pin = "";
  bool isNewPasscodeSet = false;
  String setPasscodeTextValue = "Set Your Passcode";

  bool? isPinValueSuccess = false;

  int tryWrongPassword = 0;
  final TextEditingController _myController = TextEditingController();
  @override
  void initState() {
    super.initState();
    box = Hive.box('zedorDataSave');

    isNewPasscodeSet = box.get(PrefKeys.USER_IS_SET_PASSCODE) == null
        ? false
        : box.get(PrefKeys.USER_IS_SET_PASSCODE);

    if (isNewPasscodeSet) {
      setPasscodeTextValue = "Enter Your Passcode";
    } else {
      setPasscodeTextValue = "Set Your Passcode";
    }
  }

  OtpFieldController otpFieldController = OtpFieldController();
  String pinValue = '';
  String partnerToken = 'gac.290e73cf22534cc6aee8c6f3d8ac83d2a65ad87f4fc24f';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(),
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
                              color: Colors.transparent,
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
                                height: 20,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 25, right: 25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int i = 0; i < 4; i++)
                                      MyPinCodeField(
                                        key: Key('pinField$i'),
                                        pin: pin,
                                        pinCodeFieldIndex: i,
                                        onChanged: (String val) {
                                          pin = pin + val;
                                          print("Pin value : " + pin);
                                        },
                                        theme: PinTheme(
                                          shape: PinCodeFieldShape.underline,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          backgroundColor: Colors.white,
                                          keysColor: Colors.black,
                                          activeFillColor: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              /*      Container(
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
                                  },
                                ),
                              ),*/
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                              ),
                              InkWell(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 45, right: 45),
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
                                onTap: () {},
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                              ),
                              Divider(
                                height: 2,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              NumPad(
                                buttonSize: 60,
                                buttonColor: Colors.transparent,
                                iconColor: Colors.black,
                                controller: _myController,
                                delete: () {
                                  _myController.text = _myController.text
                                      .substring(
                                          0, _myController.text.length - 1);
                                },
                                // do something with the input numbers
                                onSubmit: () {
                                  debugPrint(
                                      'Your code: ${_myController.text}');
                                },
                                numberClick: () {},
                              ),
                            ],
                          ),
                        ))
                      ],
                    ),
                  ],
                ))));
  }
}

class NumPad extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;
  final Function numberClick;
  const NumPad({
    Key? key,
    this.buttonSize = 70,
    this.buttonColor = Colors.indigo,
    this.iconColor = Colors.amber,
    required this.delete,
    required this.onSubmit,
    required this.controller,
    required this.numberClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // implement the number keys (from 0 to 9) with the NumberButton widget
            // the NumberButton widget is defined in the bottom of this file
            children: [
              NumberButton(
                number: 1,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 2,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 3,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 4,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 5,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 6,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 7,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 8,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 9,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // this button is used to delete the last number
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.done_rounded,
                  color: Colors.transparent,
                ),
                iconSize: buttonSize,
              ),
              NumberButton(
                number: 0,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),

              OutlinedButton(
                onPressed: () {},
                child: IconButton(
                  onPressed: () => delete(),
                  icon: Icon(
                    Icons.backspace,
                    color: iconColor,
                  ),
                  iconSize: 22,
                ),
                style: OutlinedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(6),
                ),
              ),

              // this button is used to submit the entered value
/*              IconButton(
                onPressed: () => onSubmit(),
                icon: Icon(
                  Icons.done_rounded,
                  color: iconColor,
                ),
                iconSize: buttonSize,
              ),*/
            ],
          ),
        ],
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final TextEditingController controller;

  const NumberButton({
    Key? key,
    required this.number,
    required this.size,
    required this.color,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: new BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
        onPressed: () {
          controller.text += number.toString();
        },
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),
          ),
        ),
      ),
    );
  }
}
