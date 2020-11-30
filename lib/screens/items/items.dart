import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/widgets/image_loader.dart';

class Items extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ItemsState();
}

class _ItemsState extends BaseState<Items> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        elevation: 5.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/addProduct").then((value) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: DatabaseService('items').find(),
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          }
          List querySnapshot = stream.data;
          return ListView.builder(
            itemCount: querySnapshot.length,
            itemBuilder: (context, index) {
              Map document = querySnapshot[index];
              return ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  color: Colors.grey[400],
                  child: ImageView(
                    imageUrl: '${document['mainImage']}',
                    height: 60,
                    width: 60,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: new Text("${document['score']}. ${document['name']}"),
                    ),
                    Expanded(
                      flex: 0,
                      child: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'Colors':
                              Navigator.pushNamed(context, "/productColors", arguments: document["objectId"]);
                              break;
                            case 'Update Product':
                              Navigator.pushNamed(context, "/updateProduct", arguments: document["objectId"]);
                              break;
                            case 'Delete Product':
                              showProgress();
                              try {
                                await Backendless.data.of('items').remove(entity: document);
                              } catch (e) {
                                print(e);
                              }
                              hideProgress();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Colors', 'Update Product', 'Delete Product'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    )
                  ],
                ),
                subtitle: Text("${document['categoryName']}"),
              );
            },
          );
        },
      ),
    );
  }
}
