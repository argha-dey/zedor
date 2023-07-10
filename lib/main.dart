import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zedor/dashboard/dashboard_screen.dart';
import 'package:zedor/splash_page.dart';

import 'message_overlay/MessangerChatHead.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  print(directory.path.toString());
  await Hive.openBox('zedorDataSave');
  runApp(MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MessangerChatHead(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Closes all Hive boxes
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter GetX State Management Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        debugPrint('ScaleFactor => : ${data.textScaleFactor.toString()}');

        return MediaQuery(
          data: data.copyWith(
              textScaleFactor:
                  data.textScaleFactor > 1.0 ? 1.0 : data.textScaleFactor),
          child: child!,
        );
      },
    );
  }
}
