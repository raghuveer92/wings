import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/widgets/image.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/services/database.dart';


class AddColor extends StatefulWidget {
  final String colorId;

  const AddColor({Key key, this.colorId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddColorState();
}

class _AddColorState extends BaseState<AddColor> {
  final DatabaseService _databaseService = DatabaseService("itemColors");
  final TextEditingController _nameController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  String error;
  Map<String, dynamic> image = Map();

  @override
  void initState() {
    super.initState();
    updateScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.colorId == null ? 'Add' : 'Update'} Color"),
        elevation: 10.0,
      ),
      body: Form(
        key: _fromKey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            MainImage(
              imageMap: image,
            ),
            TextInputLayout(
              fieldName: "Color Name",
              labelText: "Color Name",
              controller: _nameController,
              inputType: TextInputType.text,
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
                      "${widget.colorId == null ? 'Add' : 'Update'} Color",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      setState(() {
                        error = null;
                      });
                      if (_fromKey.currentState.validate()) {
                        Map<String, dynamic> data = Map();
                        data["name"] = _nameController.text;
                        data["image"] = image["image"];
                        showProgress();
                        var response = await _databaseService.save(data, documentId: widget.colorId);
                        hideProgress();
                        if (response.responseType == ResponseType.SUCCESS) {
                          showToast("${widget.colorId == null ? 'Add' : 'Update'} successfully");
                          setResult(response.data["objectId"], context);
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
    if (widget.colorId != null) {
      var documentSnapshot = await _databaseService.get(widget.colorId);
      if (documentSnapshot != null) {
        _nameController.text = documentSnapshot["name"];
        setState(() {
          image["image"] = documentSnapshot["image"];
        });
      }
    }
  }
}
