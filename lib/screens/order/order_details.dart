import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wings/custom_views/sub_title_text.dart';
import 'package:wings/custom_views/title_text.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/enums/order_status.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/colors.dart';
import 'package:wings/utils/preferences.dart';
import 'package:wings/widgets/image_loader.dart';

class OrderDetails extends StatefulWidget {
  final String orderId;

  const OrderDetails({Key key, this.orderId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends BaseState<OrderDetails> {
  final DatabaseService _databaseService = DatabaseService("orders");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        elevation: 5.0,
      ),
      body: FutureBuilder(
        future: DatabaseService("orders").get(widget.orderId, relationsDepth: 2, related: ["orderItems","address"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          Map document = snapshot.data;
          List items = document["orderItems"];
          double totalAmount = 0;
          items.forEach((element) {
            totalAmount = totalAmount + element["item"]["currentPrice"];
          });

          return Column(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleText("Order Take By:"),
                            SubTitle("${document["address"]["name"]}"),
                            SizedBox(height: 10),
                            TitleText("Address:"),
                            SubTitle("${document["address"]["fullAddress"]}"),
                            SizedBox(height: 10),
                            TitleText("Placed On:"),
                            SubTitle("${document["created"]}"),
                            SizedBox(height: 10),
                            TitleText("OrderStatus:"),
                            SubTitle("${document["orderStatus"]}"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ListView.separated(
                        separatorBuilder: (context,index){
                          return Container(color: AppColors.lightLineColor, height: 1,);
                        },
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var doc = items[index];
                          var color = doc["color"];
                          return ListTile(
                            leading: Container(
                              height: 32,
                              width: 32,
                              color: Colors.grey[400],
                              child:ImageView(
                                imageUrl: color!=null?color["image"]:'${doc['item']['mainImage']}',
                                height: 32,
                                width: 32,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: new Text("${doc['item']['name']}${color!=null?" (${color["name"]})":""}"),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: new Text("₹${doc['item']['currentPrice']}"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  color: Colors.blueGrey[300],
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Total Amount: ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: Text(
                          "$totalAmount",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              "raghuveer.ameta92@gmail.com" == Preferences.getString(PrefKeys.EMAIL)?Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: getActionButtons(document),
                  ),
                )
                ,
              ):
              Expanded(
                flex: 0,
                child: Visibility(
                  visible: "WAITING" == document["orderStatus"],
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(
                            "Cancel Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            delete(document);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  getActionButtons(Map document) {
    List<Widget> buttons = [];
    switch (document["orderStatus"]) {
      case "WAITING":
        buttons.add(getButton("Reject Order", "REJECTED", document["objectId"]));
        buttons.add(getButton("Accept Order", "PLACED", document["objectId"]));
        break;
      case "PLACED":
        buttons.add(getButton("Reject Order", "REJECTED", document["objectId"]));
        buttons.add(getButton("Dispatch Order", "DISPATCHED", document["objectId"]));
        break;
      case "DISPATCHED":
        buttons.add(getButton("Rejected By User", "REJECTED_BY_USER", document["objectId"]));
        buttons.add(getButton("Delivered", "DELIVERED", document["objectId"]));
        break;
    }
    return buttons;
  }

  getButton(String title, String status, String documentId) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Row(
          children: [
            Expanded(
                child: RaisedButton(
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Map<String, dynamic> data = Map();
                    data["orderStatus"] = status;
                    showProgress();
                    _databaseService.save(data, documentId: documentId).then((value) {
                      hideProgress();
                      setResult(true, context);
                    }).catchError((e) {
                      hideProgress();
                    });
                  },
                ))
          ],
        ),
      ),
    );
  }
  Future delete(Map document) async{
    Map<String, dynamic> data = Map();
    data["orderStatus"] = OrderStatus.CANCELLED.toString().split('.').last;
    await _databaseService.save(data,documentId: document["objectId"]);
    showToast("Cancelled...!");
    setResult(true, context);
  }
}
