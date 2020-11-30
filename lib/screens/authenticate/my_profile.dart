import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class MyProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyProfileState();
}

class _MyProfileState extends BaseState<MyProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  String error = null;

  @override
  void initState() {
    super.initState();
    _nameController.text  = Preferences.getString(PrefKeys.NAME);
    _emailController.text = Preferences.getString(PrefKeys.EMAIL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        elevation: 10.0,
      ),
      body: Form(
        key: _fromKey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            TextInputLayout(
              fieldName: "Full name",
              labelText: "Full name",
              controller: _nameController,
              inputType: TextInputType.text,
            ),
            TextInputLayout(
              fieldName: "Email-Id",
              labelText: "Email-Id",
              controller: _emailController,
              inputType: TextInputType.text,
              enable: false,
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
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  child: Text("Update",style: TextStyle(color: Colors.white),),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    setState(() {
                      error = null;
                    });
                    if(_fromKey.currentState.validate()){
                      showProgress();
                      var backendlessUser = await Backendless.userService.currentUser();
                      backendlessUser.setProperty("name", _nameController.text);
                      Backendless.userService.update(backendlessUser).then((value){
                        hideProgress();
                        showToast("Updated successfully");
                        finishScreen();
                      }).catchError((e){
                        hideProgress();
                      });
                    }
                  },
                ),),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
