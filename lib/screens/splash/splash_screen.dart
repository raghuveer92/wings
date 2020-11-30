import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends BaseState<SplashScreen> {
  startTime() {
    var duration = Duration(seconds: 2);
    return Timer(duration, () async {
      if(!Preferences.getBool(PrefKeys.LOGGED_IN, false)){
        await AuthService().loginAnon();
      }
      homeScreen();
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image(
          width: 200,
          height: 200,
          image: AssetImage('icons/app_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void loginScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void homeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }
}
