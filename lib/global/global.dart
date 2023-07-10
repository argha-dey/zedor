import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../localizations/app_localizations.dart';
import '../localizations/language_model.dart';

import 'PrefKeys.dart';

class global {
  void showLoader(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
            ),
          ],
        ));
      },
    );
  }

  void hideLoader(BuildContext context) {
    Navigator.pop(context);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarShowError(BuildContext context, String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          title,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarShowSuccess(BuildContext context, String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          title,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
