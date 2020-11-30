import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:wings/utils/preferences.dart';
import 'package:toast/toast.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Preferences.init();
  }
  void showProgress() {
    Loader.show(context,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        themeData: Theme.of(context).copyWith(accentColor: Theme.of(context).primaryColor));
  }

  void hideProgress() {
    Loader.hide();
  }

  Future<void> showToast(String message) async {
    Toast.show(message, context, duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
  }

  void finishScreen() {
    Navigator.pop(context);
  }

  void changeScreen(Widget screen, {bool animation, String screenName}) {
    var router = MaterialPageRoute(
      builder: (context) {
        return screen;
      },
      settings: RouteSettings(name: screenName ?? screen.toString()),
    );
//    if (animation == true) {
//      var router = SlideTopRoute(page: screen,);
//      Navigator.push(context, router);
//      return;
//    }
    Navigator.push(context, router);
    if (screenName != null) {
      setCurrentScreen(screenName);
    }
  }

  void finishAndChangeScreen(screen, {bool animation, String screenName}) {
    var materialPageRoute = MaterialPageRoute(
      builder: (context) {
        return screen;
      },
      settings: RouteSettings(name: screenName ?? screen.toString()),
    );
//    if (animation == true) {
//      var router = SlideTopRoute(page: screen);
//      Navigator.pushReplacement(context, router);
//      return;
//    }
    Navigator.pushReplacement(context, materialPageRoute);
    if (screenName != null) {
      setCurrentScreen(screenName);
    }
  }

  Future<void> setCurrentScreen(String screenName) async {
    // await PatientApp.analytics.setCurrentScreen(
    //   screenName: screenName,
    // );
  }

  void changeScreenAndPop(Widget screen, {bool animation, String screenName}) {
    Navigator.pop(context);
    changeScreen(screen, animation: animation, screenName: screenName);
  }

  Future<T> changeScreenForResult<T>(Widget screen, {bool animation, String screenName}) async {
    var route = MaterialPageRoute<T>(
      builder: (BuildContext context) {
        return screen;
      },
      settings: RouteSettings(name: screenName ?? screen.toString()),
    );
    return await Navigator.of(context).push(route);
  }

  setResult<T>(T value, BuildContext context) {
    return Navigator.of(context).pop(value);
  }

  showAlertDialog(BuildContext context, String title, String subTitle, Function onPress) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: finishScreen,
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        finishScreen();
        onPress();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(subTitle),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
