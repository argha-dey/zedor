import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../registration_pages/set_passcode_page.dart';
import 'intro_page_three.dart';

class IntroPageTwo extends StatefulWidget {
  const IntroPageTwo({Key? key}) : super(key: key);

  @override
  State<IntroPageTwo> createState() => _IntroPageTwoState();
}

class _IntroPageTwoState extends State<IntroPageTwo> {
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
              'images/intro_two.png',
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
                    child: Text("Hangout",
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
                              builder: (context) => IntroPageThree()));
                    },
                  ))
            ],
          ),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 35),
              child: Text("You can personally meet the person after fight!",
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
          ),
        ],
      ),
    );
  }
}
