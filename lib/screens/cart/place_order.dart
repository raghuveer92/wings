import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/custom_views/title_text.dart';
import 'package:wings/models/user.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/colors.dart';
import 'package:wings/utils/preferences.dart';
import 'package:provider/provider.dart';


class PlaceOrder extends StatefulWidget {
  const PlaceOrder({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends BaseState<PlaceOrder> {
  final DatabaseService _databaseService = DatabaseService("addresses");
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _fullAddressController = new TextEditingController();
  final TextEditingController _mobileNumberController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  Map addressSnapshot;
  String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Place Order"),
        elevation: 10.0,
      ),
      body: Form(
        key: _fromKey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            FutureBuilder(
                future: DatabaseService('addresses').find(query: "userId='${Preferences.getString(PrefKeys.USER_ID)}'"),
                builder: (context, stream) {
                  if (stream.connectionState == ConnectionState.waiting) {
                    return Center(child: Container(height: 20, width: 20, child: CircularProgressIndicator()));
                  }
                  if (stream.hasError) {
                    return Container();
                  }
                  List<Map<dynamic, dynamic>> querySnapshot = stream.data;
                  if (querySnapshot.length == 0) {
                    return Container();
                  }
                  return Row(
                    children: [
                      Expanded(child: TitleText("Select Address:")),
                      DropdownButton<Map>(
                        underline: Container(
                          height: 2,
                          color: AppColors.primaryColor,
                        ),
                        onChanged: (Map data) {
                          addressSnapshot = data;
                          updateAddress();
                        },
                        items: querySnapshot.map<DropdownMenuItem<Map>>((Map value) {
                          return DropdownMenuItem<Map>(
                            value: value,
                            child: Container(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value["name"]??"",
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    value["fullAddress"]??"",
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    value["mobileNumber"]??"",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),
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
            Container(
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(8.0),
              child: TitleText(
                "Order will be deliver in only Udaipur, Rajasthan.",
                alignment: Alignment.centerLeft,
                color: Colors.red,
                overflow: TextOverflow.visible,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      "Place Order",
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
                        var response = await _databaseService.save(data, documentId: addressSnapshot!=null?addressSnapshot["objectId"]:null);
                        hideProgress();
                        if (response.responseType == ResponseType.SUCCESS) {
                          setResult(response.data, context);
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

  void updateAddress() async {
      if (addressSnapshot != null) {
        _nameController.text = addressSnapshot["name"];
        _fullAddressController.text = addressSnapshot["fullAddress"];
        _mobileNumberController.text = addressSnapshot["mobileNumber"];
      }
  }
}
