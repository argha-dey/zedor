import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

import '../registration_pages/set_passcode_page.dart';
import 'intro_page_two.dart';

class IntroPages extends StatefulWidget {
  const IntroPages({Key? key}) : super(key: key);

  @override
  State<IntroPages> createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages> {
  // bool isCheckRequestPermission = false;
  @override
  initState() {
/*    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isCheckRequestPermission = checkAndRequestCameraPermissions();
      });
    });*/

    super.initState();
  }

  checkAndRequestCameraPermissions() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            height: 300,
            width: 300,
            margin: EdgeInsets.only(left: 35, right: 35),
            alignment: Alignment.center,
            child: Image.asset(
              'images/intro_one.png',
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text("Chat Someone",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold))),
              ),
              Expanded(
                  flex: 2,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.arrow_forward_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IntroPageTwo()));

                      /*            if (isCheckRequestPermission) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IntroPageTwo()));
                      } else {
                        setState(() {
                          isCheckRequestPermission =
                              checkAndRequestCameraPermissions();
                        });
                      }*/
                    },
                  ))
            ],
          ),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 35),
              child: Text("Chat with the people you want during anytime!",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal))),
          InkWell(
            child: Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                child: Text("Skip ",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold))),
            onTap: () {
              Get.off(() => SetPasscodePage());
            },
          )
        ],
      ),
    );
  }
}
