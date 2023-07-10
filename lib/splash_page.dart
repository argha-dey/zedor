import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:zedor/dashboard/dashboard_screen.dart';
import 'package:zedor/intro_pages/intro_page.dart';
import 'package:zedor/registration_pages/scan_qr_code.dart';
import 'package:zedor/registration_pages/set_confirm_passcode_page_demo.dart';
import 'package:zedor/registration_pages/set_passcode_page.dart';
import '../global/PrefKeys.dart';
import '../global/global.dart';
import 'account_pages/account_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Box box;
  @override
  void initState() {
    // TODO: implement initState

    box = Hive.box('zedorDataSave');
    Timer(const Duration(seconds: 3), navigateUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Center(
          child: SizedBox(
            width: 380,
            height: 380,
            child: Image.asset(
              'images/splash_page_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void navigateUser() {
//    Get.off(() => SetConfirmPasscodePage());

    bool isNewPasscodeSet = box.get(PrefKeys.USER_IS_SET_PASSCODE) == null
        ? false
        : box.get(PrefKeys.USER_IS_SET_PASSCODE);

    if (isNewPasscodeSet) {
      bool isPasscodeSetEnableDisable =
          box.get(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE) == null
              ? false
              : box.get(PrefKeys.USER_IS_SET_PASSCODE_ENABLE_DISABLE);
      if (isNewPasscodeSet && !isPasscodeSetEnableDisable) {
        Get.off(() => ScanQrCodePage());

        //   Get.off(() => DashboardScreen());
      } else {
        Get.off(() => SetPasscodePage());
        //  Get.off(() => SetConfirmPasscodePage());
        //  Get.off(() => DashboardScreen());
      }
    } else {
      Get.off(() => IntroPages());

      //   Get.off(() => DashboardScreen());
    }

/*    Navigator.push(
        context, MaterialPageRoute(builder: (context) => IntroScreen()));*/

/*    bool isRegister = PrefObj.preferences!.get(PrefKeys.IS_LOGIN_STATUS) == null
        ? false
        : PrefObj.preferences!.get(PrefKeys.IS_LOGIN_STATUS);*/
  }
}
