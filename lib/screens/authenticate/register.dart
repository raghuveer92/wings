import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends BaseState<Register> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  String error = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration"),
        elevation: 10.0,
      ),
      body: Form(
        key: _fromKey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            TextInputLayout(
              fieldName: "Name",
              labelText: "Name",
              controller: _nameController,
            ),
            TextInputLayout(
              fieldName: "Email-Id",
              labelText: "Email-Id",
              controller: _emailController,
              inputType: TextInputType.emailAddress,
            ),
            TextInputLayout(
              fieldName: "Password",
              labelText: "Password",
              controller: _passwordController,
              obscureText: true,
              maxLines: 1,
            ),
            SizedBox(
              height: 40,
            ),
            error != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Container(),
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      setState(() {
                        error = null;
                      });
                      if (_fromKey.currentState.validate()) {
                        final user = BackendlessUser()
                          ..email = _emailController.text
                          ..password = _passwordController.text
                          ..setProperty("name", _nameController.text);
                        showProgress();
                        Backendless.userService.register(user).then((_) {
                          hideProgress();
                          Backendless.userService.login(_emailController.text, _passwordController.text, true).then( (loggedUser) {
                            Preferences.saveString(PrefKeys.USER_ID, loggedUser.getUserId());
                            Preferences.saveString(PrefKeys.NAME, loggedUser.getProperty("name"));
                            Preferences.saveString(PrefKeys.EMAIL, loggedUser.email);
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                            hideProgress();
                          }).catchError((exc){
                            hideProgress();
                            print("Exception: ${exc.message}");
                            setState(() {
                              error = exc.message;
                            });
                          });
                        }).catchError((exc) {
                          hideProgress();
                          setState(() {
                            error = exc.message;
                          });
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
