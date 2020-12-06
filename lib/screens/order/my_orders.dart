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

class MyOrders extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyOrders();
}

class _MyOrders extends BaseState<MyOrders> {
  final DatabaseService _databaseService = DatabaseService("orders");

  get getOrders => Preferences.getString(PrefKeys.EMAIL) == "raghuveer.ameta92@gmail.com"?_databaseService.find(orderBy: ["created DESC"], relationsDepth: 2,related: ["orderItems","orderItems.item","address"]):_databaseService.find(query: "userId='${Preferences.getString(PrefKeys.USER_ID)}'",orderBy: ["created DESC"], relationsDepth: 3,related: ["orderItems","orderItems.item","address"]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        elevation: 5.0,
      ),
      body: FutureBuilder(
        future: getOrders,
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          }
          print("stream.data: ${stream.data}");
          List querySnapshot = stream.data;
          if (querySnapshot.length == 0) {
            return Center(
              child: Text(
                "No Orders added yet",
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context,index){
              return Container(color: AppColors.lightLineColor, height: 1,);
            },
            itemCount: querySnapshot.length,
            itemBuilder: (context, index) {
              Map document = querySnapshot[index];
              String image;
              StringBuffer stringBuffer = new StringBuffer();
              List items = document["orderItems"];
              items.forEach((element) {
                if (image == null) {
                  image = element["item"]["mainImage"];
                }
                stringBuffer.write("${element["item"]["name"]}, ");
              });
              return ListTile(
                contentPadding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),
                tileColor: getColor(document["orderStatus"]),
                onTap: (){
                  Navigator.pushNamed(context, "/orderDetails", arguments: document["objectId"]).then((value) {
                    if(value == true){
                      setState(() {
                      });
                    }
                  });
                },
                leading: ImageView(
                  imageUrl: '$image',
                  height: 74,
                  width: 74,
                ),
                title: TitleText(
                  "${stringBuffer.toString().trim()}",
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubTitle(
                      "Address: ${document["address"]["name"]} (${document["address"]["fullAddress"]}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    SubTitle("Placed On: ${document["created"]}"),
                    SubTitle("OrderStatus: ${document["orderStatus"]}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  getColor(String orderStatus) {
    if(orderStatus!=null){
      switch(orderStatus){
        case "WAITING":
          return Colors.orangeAccent[100];
        case "PLACED":
        case "DISPATCHED":
          return Colors.green[100];
        case "REJECTED":
        case "CANCELLED":
        case "REJECTED_BY_USER":
          return Colors.red[100];
      }
    }
    return Colors.white;
  }
}
