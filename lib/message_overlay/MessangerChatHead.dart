import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:app_launcher/app_launcher.dart';
import '../main.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  BoxShape shape = BoxShape.circle;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      print("click");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () async {
          print("@@@>>GestureDetector click");

          await AppLauncher.openApp(
            androidApplicationId: "com.zedor.zedor",
          );
        },
        child: Container(
          height: 20,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: shape,
              border: Border.all(color: Colors.orange, width: 2)),
          child: Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Image(image: new AssetImage("images/zedor_logo.png")),
                ]),
          ),
        ),
      ),
    );
  }
}
