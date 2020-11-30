import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/services/database.dart';

import '../../widgets/image.dart';

class AddCategory extends StatefulWidget {
  final String categoryId;

  const AddCategory({Key key, this.categoryId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddCategoryState();
}

class _AddCategoryState extends BaseState<AddCategory> {
  final DatabaseService _databaseService = DatabaseService("categories");
  final TextEditingController _snoController = new TextEditingController();
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
        title: Text("${widget.categoryId == null ? 'Add' : 'Update'} Category"),
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
            Row(
              children: [
                Container(
                  width: 100,
                  child: TextInputLayout(
                    fieldName: "S.no",
                    labelText: "S.no",
                    controller: _snoController,
                    inputType: TextInputType.text,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextInputLayout(
                    fieldName: "Category Name",
                    labelText: "Category Name",
                    controller: _nameController,
                    inputType: TextInputType.text,
                  ),
                ),
              ],
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
                      "${widget.categoryId == null ? 'Add' : 'Update'} Category",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      setState(() {
                        error = null;
                      });
                      if (_fromKey.currentState.validate()) {
                        Map<String, dynamic> data = Map();
                        data["score"] = _snoController.text;
                        data["name"] = _nameController.text;
                        data["mainImage"] = image["image"];
                        showProgress();
                        var response = await _databaseService.save(data, documentId: widget.categoryId);
                        hideProgress();
                        if (response.responseType == ResponseType.SUCCESS) {
                          showToast("${widget.categoryId == null ? 'Add' : 'Update'} successfully");
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
    if (widget.categoryId != null) {
      var documentSnapshot = await _databaseService.get(widget.categoryId);
      if (documentSnapshot != null) {
        _snoController.text = "${documentSnapshot["score"]}";
        _nameController.text = documentSnapshot["name"];
        setState(() {
          image["image"] = documentSnapshot["mainImage"];
        });
      }
    } else {
      var document = await _databaseService.getLastDocument();
      if (document != null) {
        _snoController.text = "${document["score"] + 1}";
      }
    }
  }
}
