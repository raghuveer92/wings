import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wings/custom_views/title_text.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/widgets/cart.dart';
import 'package:wings/widgets/image_loader.dart';

class ItemsDetails extends StatefulWidget {
  final String itemId;

  const ItemsDetails({Key key, this.itemId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ItemsDetailsState();
}

class _ItemsDetailsState extends BaseState<ItemsDetails> {
  DatabaseService _databaseService = DatabaseService("items");
  Map selectedColor;
  @override
  void initState() {
    super.initState();
    _databaseService.saveLocalObject(widget.itemId, related: ["colors"], key: widget.itemId);
  }

  @override
  void dispose() {
    super.dispose();
    _databaseService.close();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _databaseService.openBox(key: widget.itemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return ValueListenableBuilder(
            valueListenable: _databaseService.box.listenable(),
            builder: (context, Box _, __) {
              if (_databaseService.box.isEmpty) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              Map itemData = _databaseService.box.getAt(0);
              List colors = itemData["colors"];
              return Scaffold(
                appBar: AppBar(
                  title: Text("${itemData['name']}"),
                  elevation: 5.0,
                  actions: [
                    Cart(false),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            height: 200,
                            width: double.maxFinite,
                            color: Colors.grey[400],
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, "/fullImage", arguments: selectedColor != null ? selectedColor["image"] : '${itemData['mainImage']}');
                              },
                              child: ImageView(
                                imageUrl: selectedColor != null ? selectedColor["image"] : '${itemData['mainImage']}',
                                height: 200,
                              ),
                            ),
                          ),
                          colors != null && colors.isNotEmpty
                              ? Container(
                            margin: EdgeInsets.only(top: 10),
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: colors.length,
                              itemBuilder: (context, index) {
                                var color = colors[index];
                                return Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, "/fullImage", arguments: color["image"]);
                                        },
                                        child: ImageView(
                                          height: 60,
                                          imageUrl: color["image"],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TitleText("${color["name"]}"),
                                      Checkbox(
                                        value: selectedColor != null && selectedColor["objectId"] == color["objectId"],
                                        onChanged: (value) {
                                          if (value) {
                                            selectedColor = color;
                                          } else {
                                            selectedColor = null;
                                          }
                                          setState(() {});
                                        },
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${itemData['name']}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "${itemData['description']}",
                                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  children: [
                                    TitleText(
                                      "Price:",
                                      textSize: 16,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    TitleText(
                                      "₹${itemData['currentPrice']}",
                                      textSize: 16,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("₹${itemData['marketPrice']}",
                                        style: TextStyle(fontSize: 14, color: Colors.grey[500], decoration: TextDecoration.lineThrough), maxLines: 1),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: RaisedButton(
                              padding: EdgeInsets.only(top: 12, bottom: 12),
                              child: TitleText(
                                "Add To Cart",
                                color: Colors.white,
                              ),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                showProgress();
                                addProduct(itemData).then((value) {
                                  hideProgress();
                                }).catchError((e) {
                                  hideProgress();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  Future addProduct(Map itemData) async {
    DatabaseService databaseService = new DatabaseService("cartItems");
    Map<String, dynamic> data = Map();
    data["itemId"] = itemData["objectId"];
    data["userId"] = await Backendless.userService.loggedInUser();
    var response = await databaseService.save(data);
    await databaseService.addRelation(response.data["objectId"], "item", [itemData["objectId"]]);
    if (selectedColor != null) {
      await databaseService.addRelation(response.data["objectId"], "color", [selectedColor["objectId"]]);
    }
    showToast("Added successfully...!");
    DatabaseService.updateCart();
  }
}
