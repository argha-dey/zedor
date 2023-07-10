import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zedor/dashboard/dashboard_screen.dart';

import '../global/PrefKeys.dart';
import '../global/global.dart';

class ScanQrCodePage extends StatefulWidget {
  const ScanQrCodePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ScanQrCodePage> createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
  var idInstance = "";
  var apiTokenInstance = "";
  bool isLoading = true;
  Timer? _timer;
  GlobalKey? globalKey = new GlobalKey();
  String? _dataString = "";

  Uint8List? _bytesImage;
  late final Box box;
  @override
  void initState() {
    box = Hive.box('zedorDataSave');

    idInstance = box.get(PrefKeys.USER_GREEN_API_INSTANCE_ID);
    apiTokenInstance = box.get(PrefKeys.USER_GREEN_API_TOKEN_INSTANCE);

    Future.delayed(const Duration(milliseconds: 500), () {
      _connectWebSocket();
    });

    _timer = Timer(Duration(seconds: 125), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  _connectWebSocket() async {
    if (await hasNetwork()) {
      final channel = WebSocketChannel.connect(
        Uri.parse(
            'wss://api.green-api.com/waInstance${idInstance}/scanqrcode/${apiTokenInstance}'),
      );
      channel.stream.listen(
        (data) {
          print(data);

          var type = json.decode(data)['type'];

          if (type.toString() == 'qrCode') {
            _dataString = json.decode(data)['message'];
            print("Time : " + DateTime.now().toString());
            print("_dataString : ${_dataString}");

            // todo : Set scanning Time here
            var ms = (new DateTime.now()).millisecondsSinceEpoch;
            var sec = (ms / 1000).round();
            box.put(PrefKeys.SET_USER_SCANNING_TIME, sec);

            setState(() {
              _bytesImage = Base64Decoder().convert(_dataString!);
            });
          } else if (type.toString() == 'alreadyLogged') {
            var wid = json.decode(data)['wid'];
            print("wid : ${wid}");
            var message = json.decode(data)['message'];
            print("message : ${message}");
            isLoading = false;

            Get.off(() => DashboardScreen(
                idInstance: idInstance.toString(),
                apiTokenInstance: apiTokenInstance.toString(),
                wid: wid.toString()));
          } else if (type.toString() == 'accountData') {
            //	string	WhatsApp account ID
            var wid = json.decode(data)['wid'];
            print("wid : ${wid}");

            //	string	WhatsApp account name
            var pushname = json.decode(data)['pushname'];

            print("pushname : ${pushname}");

            //string	URL for receiving incoming notifications
            var webhookUrl = json.decode(data)['webhookUrl'];

            print("webhookUrl : ${webhookUrl}");
          } else if (type.toString() == 'timeoutExpired') {
            var message = json.decode(data)['message'];
            print("timeoutExpired message : ${message}");
            // global().showSnackBarShowError(context, message.toString());
            global().showSnackBarShowError(context,
                "Server response timeout occurs!. Please try again after some time.");
          } else if (type.toString() == 'error') {
            var message = json.decode(data)['message'];
            print("error: ${message}");
            //   global().showSnackBarShowError(context, message.toString());
            global().showSnackBarShowError(context,
                "Server not responding!. Please try again after some time.");
          }
        },
        onError: (error) {
          setState(() {
            isLoading = false;
          });
          //   global().showSnackBarShowError(context, error.toString());
          global().showSnackBarShowError(context,
              "Server not responding!. Please try again after some time.");
        },
      );
    } else {
      setState(() {
        isLoading = false;
      });
      global().showSnackBarShowError(context, "Network Connection Error!");
    }
  }

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
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(),
                            Image.asset(
                              "images/zedor_logo.png",
                              width: 110,
                              height: 110,
                            ),
                            SizedBox(),
                          ],
                        ),
                        SizedBox(
                          height: 14,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(),
                            Container(
                                child: Text("Welcome!",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold))),
                            SizedBox(),
                          ],
                        ),
                        SizedBox(
                          height: 80,
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
                                  child: Text("",
                                      style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold))),
                              _dataString == ""
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        isLoading
                                            ? CircularProgressIndicator()
                                            : SizedBox(
                                                height: 100,
                                              ),
                                        SizedBox(
                                          height: 100,
                                        ),
                                        isLoading
                                            ? Text(
                                                "Loading...Please wait for a min.")
                                            : Text(
                                                "Press the Re-load button to get QR",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                      ],
                                    )
                                  : Container(
                                      child: Image.memory(
                                        _bytesImage!,
                                        width: 230,
                                        height: 230,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                              SizedBox(
                                height: 50,
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
                                            top: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.refresh,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                'Re-load',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    isLoading = true;
                                    _dataString = "";
                                  });
                                  _connectWebSocket();
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
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              Image.asset(
                "images/zedor_logo.png",
                width: 110,
                height: 110,
              ),
              SizedBox(),
            ],
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              Container(
                  child: Text("Welcome!",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold))),
              SizedBox(),
            ],
          ),
          SizedBox(
            height: 80,
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
                        child: Text("",
                            style: TextStyle(
                                fontSize: 19,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold))),
                    _dataString == ""
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(
                                      height: 100,
                                    ),
                              SizedBox(
                                height: 100,
                              ),
                              isLoading
                                  ? Text("Loading...Please wait for a min.")
                                  : Text("Press the Re-load button to get QR",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Container(
                            child: Image.memory(
                              _bytesImage!,
                              width: 230,
                              height: 230,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                    SizedBox(
                      height: 50,
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
                                  top: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'Re-load',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isLoading = true;
                          _dataString = "";
                        });
                        _connectWebSocket();
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
