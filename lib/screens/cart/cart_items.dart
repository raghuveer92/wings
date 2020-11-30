import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:wings/custom_views/loader.dart';
import 'package:wings/custom_views/title_text.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/cart/place_order.dart';
import 'package:wings/screens/customviews/input/text_inout_layout.dart';
import 'package:wings/screens/enums/order_status.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/colors.dart';
import 'package:wings/utils/preferences.dart';
import 'package:wings/widgets/image_loader.dart';

class CartItems extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CartItems();
}

class _CartItems extends BaseState<CartItems> {
  final _databaseService = DatabaseService('cartItems');
  final TextEditingController _addressController = new TextEditingController();
  Map addressSnapshot;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        elevation: 5.0,
      ),
      body: FutureBuilder(
        future: _databaseService.find(query: "userId = '${Preferences.getString(PrefKeys.USER_ID)}'", related: ["item", "color"]),
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          }
          List querySnapshot = stream.data;
          if (querySnapshot.length == 0) {
            return Center(
              child: Text(
                "No items added in cart",
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          double totalAmount = 0;
          querySnapshot.forEach((element) {
            totalAmount = totalAmount + element["item"]["currentPrice"];
          });
          var deliveryCharges = totalAmount > 249 ? 0 : 30;
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Container(
                      color: AppColors.lightLineColor,
                      height: 1,
                    );
                  },
                  itemCount: querySnapshot.length,
                  itemBuilder: (context, index) {
                    Map document = querySnapshot[index];
                    return ListTile(
                      leading: Container(
                        height: 32,
                        width: 32,
                        color: Colors.grey[400],
                        child: ImageView(
                          imageUrl: '${document["item"]["mainImage"]}',
                          height: 32,
                          width: 32,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: new TitleText("${document["item"]["name"]}${document["color"] != null ? " (${document["color"]["name"]})" : ""}"),
                          ),
                          Expanded(
                            flex: 0,
                            child: new TitleText("₹${document["item"]["currentPrice"]}"),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          deleteCartItem(document);
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  color: Colors.purple[100],
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: new TitleText("Payment:"),
                        ),
                        Expanded(
                          flex: 0,
                          child: new TitleText("Cash On Delivery"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleText("Delivery Charges:"),
                            SubTitle("Free delivery if order grater then ₹249",textSize: 12,)
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: TitleText("₹${deliveryCharges}"),
                      ),
                    ],
                  ),
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
                          "${totalAmount+deliveryCharges}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        child: Text(
                          "Place Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async{
                          if (addressSnapshot == null) {
                            addressSnapshot = await changeScreenForResult(PlaceOrder());
                            print("addressSnapshot: $addressSnapshot");
                          }
                          if (addressSnapshot == null) {
                            return;
                          }
                          showProgress();
                          placeOrder(querySnapshot, totalAmount, deliveryCharges).then((value) {
                            hideProgress();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future deleteCartItem(Map document) async {
    showProgress();
    try {
      await Backendless.data.of('cartItems').remove(entity: document);
    } catch (e) {
      print(e);
    }
    DatabaseService.updateCart();
    hideProgress();
    setState(() {});
  }

  Future placeOrder(List cartItems, totalAmount, deliveryCharges) async {
    Map<String, dynamic> data = Map();
    data["userId"] = Preferences.getString(PrefKeys.USER_ID);
    data["addressId"] = addressSnapshot["objectId"];
    data["orderStatus"] = OrderStatus.WAITING.toString().split('.').last;
    data["subTotalAmount"] = totalAmount;
    data["deliverCharges"] = deliveryCharges;
    data["totalAmount"] = totalAmount + deliveryCharges;
    data["paymentMode"] = "Cash On Delivery";
    try {
      var orderDatabaseService = DatabaseService('orders');
      var response = await orderDatabaseService.save(data);
      if (response.responseType == ResponseType.SUCCESS) {
        List<String> items = [];
        for (var element in cartItems) {
          Map<String, dynamic> data = Map();
          data["itemId"] = element["item"]["objectId"];
          if (element["color"] != null) {
            data["colorId"] = element["color"]["objectId"];
          }
          var databaseService = DatabaseService("orderItems");
          var response = await databaseService.save(data);
          await databaseService.addRelation(response.data["objectId"], "item", [element["item"]["objectId"]]);
          if (element["color"] != null) {
            await databaseService.addRelation(response.data["objectId"], "color", [element["color"]["objectId"]]);
          }
          items.add(response.data["objectId"]);
        }
        await orderDatabaseService.addRelation(response.data["objectId"], "orderItems", items);
        await orderDatabaseService.addRelation(response.data["objectId"], "address", [addressSnapshot["objectId"]]);
        await orderDatabaseService.addRelation(response.data["objectId"], "user", [Preferences.getString(PrefKeys.USER_ID)]);
        List querySnapshot = await _databaseService.find(query: "userId = '${Preferences.getString(PrefKeys.USER_ID)}'");
        for (var element in querySnapshot) {
          await _databaseService.delete(element);
        }
        DatabaseService.updateCart();
        showToast("Order Placed..!");
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
    } catch (e) {
      print(e);
    }
  }
}
