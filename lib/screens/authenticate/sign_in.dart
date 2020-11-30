import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wings/models/user.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends BaseState<SignIn> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  String error = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
        elevation: 10.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Form(
          key: _fromKey,
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              TextInputLayout(
                fieldName: "Email-Id",
                labelText: "Email-Id",
                controller: _emailController,
                inputType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 10,
              ),
              TextInputLayout(
                fieldName: "Password",
                labelText: "Password",
                controller: _passwordController,
                inputType: TextInputType.text,
                maxLines: 1,
                obscureText: true,
              ),
              SizedBox(
                height: 40,
              ),
              error != null ? Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(error,style: TextStyle(color: Colors.red),),
              ):Container(),
              Row(
                children: [
                  Expanded(child: RaisedButton(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text("Register",style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      Navigator.of(context).pushNamed("/signUp");
                    },
                  ),),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(child: RaisedButton(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text("Sign In",style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      if(_fromKey.currentState.validate()){
                        showProgress();
                        try {
                          Backendless.userService.login(_emailController.text, _passwordController.text, true).then( (loggedUser) {
                            Preferences.saveString(PrefKeys.USER_ID, loggedUser.getUserId());
                            Preferences.saveString(PrefKeys.NAME, loggedUser.getProperty("name"));
                            Preferences.saveString(PrefKeys.EMAIL, loggedUser.email);
                            Preferences.saveString(PrefKeys.ROLE, "USER");
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                            hideProgress();
                          }).catchError((exc){
                            hideProgress();
                            print("Exception: ${exc.message}");
                            setState(() {
                              error = exc.message;
                            });
                          });
                        } catch (exc) {
                          hideProgress();
                          print("~~~> Platform exception: ${exc.message}");
                          setState(() {
                            error = exc.message;
                          });
                        }
                      }
                    },
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
