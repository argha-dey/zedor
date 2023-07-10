import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool statusLanguage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 25,
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 5, left: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);

                /*  Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: HomePage(),
                          ),
                        );*/
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Container(
                  /*   decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 3.0,
                                ),
                              ]),*/
                  child: const Icon(
                    Icons.keyboard_backspace,
                    color: Colors.black54,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: Colors.black12,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 45, top: 50),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: Colors.white),
                  child: Container(
                    width: 14,
                    height: 8,
                    margin: EdgeInsets.all(7),
                    child: Image.asset(
                      "images/camera.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Divider(
            color: Colors.grey,
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "Passcode",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'HelveticaNeueMedium',
                      fontSize: 19,
                      color: Colors.black54),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 20, top: 10),
                child: FlutterSwitch(
                  width: 48,
                  height: 25,
                  activeText: "",
                  inactiveText: "",
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  toggleColor: Colors.orange,
                  toggleSize: 20,
                  value: statusLanguage,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      statusLanguage = val;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Divider(
            color: Colors.grey,
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left: 20, top: 18),
            child: Text(
              "Name",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: 'HelveticaNeueMedium',
                  fontSize: 19,
                  color: Colors.black54),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "lorem ipsum",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'HelveticaNeueMedium',
                      fontSize: 19,
                      color: Colors.black54),
                ),
              ),
              Container(
                width: 14,
                height: 18,
                margin: EdgeInsets.only(right: 20, top: 15),
                child: Image.asset(
                  "images/edit.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.grey,
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left: 20, top: 18),
            child: Text(
              "About",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: 'HelveticaNeueMedium',
                  fontSize: 19,
                  color: Colors.black54),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "lorem ipsum ipsumip",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'HelveticaNeueMedium',
                      fontSize: 19,
                      color: Colors.black54),
                ),
              ),
              Container(
                width: 14,
                height: 18,
                margin: EdgeInsets.only(right: 20, top: 15),
                child: Image.asset(
                  "images/edit.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
