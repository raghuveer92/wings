import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/models/user.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';
import 'package:provider/provider.dart';


class AddAddress extends StatefulWidget {
  final String addressId;

  const AddAddress({Key key, this.addressId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAddressState();
}

class _AddAddressState extends BaseState<AddAddress> {
  final DatabaseService _databaseService = DatabaseService("addresses");
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _fullAddressController = new TextEditingController();
  final TextEditingController _mobileNumberController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  String error;

  @override
  void initState() {
    super.initState();
    updateScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.addressId == null ? 'Add' : 'Update'} Address"),
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
              inputType: TextInputType.text,
            ),
            SizedBox(
              height: 16,
            ),
            TextInputLayout(
              fieldName: "Full Address",
              labelText: "Full Address",
              controller: _fullAddressController,
              inputType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
            ),
            SizedBox(
              height: 16,
            ),
            TextInputLayout(
              fieldName: "Mobile Number",
              labelText: "Mobile Number",
              controller: _mobileNumberController,
              inputType: TextInputType.phone,
              textInputAction: TextInputAction.newline,
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
                      "${widget.addressId == null ? 'Add' : 'Update'} Address",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      setState(() {
                        error = null;
                      });
                      if (_fromKey.currentState.validate()) {
                        Map<String, dynamic> data = Map();
                        data["userId"] = Preferences.getString(PrefKeys.USER_ID);
                        data["name"] = _nameController.text;
                        data["fullAddress"] = _fullAddressController.text;
                        data["mobileNumber"] = _mobileNumberController.text;

                        showProgress();
                        var response = await _databaseService.save(data, documentId: widget.addressId);
                        hideProgress();
                        if (response.responseType == ResponseType.SUCCESS) {
                          showToast("${widget.addressId == null ? 'Add' : 'Update'} successfully");
                          finishScreen();
                        } else {
                          setState(() {
                            error = response.data;
                          });
                        }
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

  void updateScore() async {
    if (widget.addressId != null) {
      var documentSnapshot = await _databaseService.get(widget.addressId);
      if (documentSnapshot != null) {
        _nameController.text = documentSnapshot["name"];
        _fullAddressController.text = documentSnapshot["fullAddress"];
        _mobileNumberController.text = documentSnapshot["mobileNumber"];
      }
    }
  }
}
