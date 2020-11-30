import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/widgets/image.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/services/database.dart';

class AddItem extends StatefulWidget {
  final String itemId;

  const AddItem({Key key, this.itemId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddItemState();
}

class _AddItemState extends BaseState<AddItem> {
  final DatabaseService _databaseService = DatabaseService("items");
  final TextEditingController _categoryController = new TextEditingController();
  final TextEditingController _snoController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _descriptionController = new TextEditingController();
  final TextEditingController _marketPrizeController = new TextEditingController();
  final TextEditingController _currentPrizeController = new TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> categoryData;
  final Map<String, dynamic> image = Map();

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
        title: Text("${widget.itemId==null?'Add':'Update'} Product"),
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
              fieldName: "Category",
              labelText: "Category",
              controller: _categoryController,
              inputType: TextInputType.text,
              focusable: false,
              suffixIcon:  FutureBuilder(
                future: DatabaseService('categories').find(orderBy: ["score ASC"]),
                builder: (context, stream) {
                  if (stream.connectionState == ConnectionState.waiting) {
                    return Container(child: CircularProgressIndicator());
                  }
                  if (stream.hasError) {
                    return Container();
                  }
                  List<Map> querySnapshot = stream.data;
                  return DropdownButton<Map>(
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (Map data) {
                      setState(() {
                        categoryData = data;
                        _categoryController.text = data["name"];
                      });
                    },
                    items: querySnapshot.map<DropdownMenuItem<Map>>((Map value) {
                      return DropdownMenuItem<Map>(
                        value: value,
                        child: Text(value["name"]),
                      );
                    }).toList(),
                  );
                }
              ),
            ),
            SizedBox(
              height: 8,
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
                SizedBox(width: 8,),
                Expanded(
                  child: TextInputLayout(
                    fieldName: "Product Name",
                    labelText: "Product Name",
                    controller: _nameController,
                    inputType: TextInputType.text,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            TextInputLayout(
              fieldName: "Description",
              labelText: "Description",
              controller: _descriptionController,
              inputType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
            ),
            SizedBox(
              height: 16,
            ),
            TextInputLayout(
              fieldName: "Market Price",
              labelText: "Market Price",
              controller: _marketPrizeController,
              inputType: TextInputType.number,
              textInputAction: TextInputAction.newline,
            ),
            SizedBox(
              height: 16,
            ),
            TextInputLayout(
              fieldName: "Current Price",
              labelText: "Current Price",
              controller: _currentPrizeController,
              inputType: TextInputType.number,
              textInputAction: TextInputAction.newline,
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
                  child: Text("${widget.itemId==null?'Add':'Update'} Product",style: TextStyle(color: Colors.white),),
                  color: Theme.of(context).primaryColor,
                  onPressed: submit,
                ),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateScore() async{
    if(widget.itemId != null){
      Map documentSnapshot = await _databaseService.get(widget.itemId, related: ["category"]);
      if(documentSnapshot!=null){
        _snoController.text = "${documentSnapshot["score"]}";
        _nameController.text = documentSnapshot["name"];
        _descriptionController.text = documentSnapshot["description"];
        _marketPrizeController.text = "${documentSnapshot["marketPrice"]}";
        _currentPrizeController.text = "${documentSnapshot["currentPrice"]}";
        categoryData = documentSnapshot["category"];
        setState(() {
          image["image"] = documentSnapshot["mainImage"];
        });
      }
    }else{
      var document = await _databaseService.getLastDocument();
      if(document!=null){
        _snoController.text = "${document.data()["score"] + 1}";
      }
    }
    if(_snoController.text.isEmpty){
      _snoController.text = "1";
    }
  }

  void submit() async{
    setState(() {
      error = null;
    });
    if(_fromKey.currentState.validate()){
      Map<String,dynamic> data = Map();
      data["categoryId"] = categoryData["objectId"];
      data["score"] = int.parse(_snoController.text);
      data["mainImage"] = image["image"];
      data["name"] = _nameController.text;
      data["description"] = _descriptionController.text;
      data["marketPrice"] = double.parse(_marketPrizeController.text);
      data["currentPrice"] = double.parse(_currentPrizeController.text);
      showProgress();
      var response = await _databaseService.save(data, documentId: widget.itemId);
      await _databaseService.addRelation(response.data["objectId"], "category", [categoryData["objectId"]]);
      hideProgress();
      print(response);
      if(response.responseType == ResponseType.SUCCESS){
        showToast("${widget.itemId==null?'Add':'Update'} successfully");
        finishScreen();
      }else{
        setState(() {
          error = response.data;
        });
      }
    }
  }
}
