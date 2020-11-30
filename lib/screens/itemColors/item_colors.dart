import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/widgets/image_loader.dart';

class ItemColors extends StatefulWidget {
  final String itemId;

  const ItemColors({Key key, this.itemId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ItemsColorsState();
}

class _ItemsColorsState extends BaseState<ItemColors> {
  var databaseService = DatabaseService('itemColors');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Colors"),
        elevation: 5.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/addProductColor").then((value) {
                DatabaseService('items').addRelation(widget.itemId, "colors", [value]);
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: DatabaseService("items").get(widget.itemId, related: ["colors"]),
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          }
          Map data = stream.data;
          List querySnapshot = data["colors"];
          return ListView.builder(
            itemCount: querySnapshot.length,
            itemBuilder: (context, index) {
              Map document = querySnapshot[index];
              return Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: ListTile(
                    leading: Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[400],
                      child: ImageView(
                        imageUrl: '${document['image']}',
                        height: 60,
                        width: 60,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("${document['name']}"),
                        ),
                        Expanded(
                          flex: 0,
                          child: PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'Update Color':
                                  Navigator.pushNamed(context, "/updateProductColor", arguments: document["objectId"]).then((value){
                                    setState(() {});
                                  });
                                  break;
                                case 'Delete Color':
                                  showProgress();
                                  try {
                                    await databaseService.delete(document);
                                  } catch (e) {
                                    print(e);
                                  }
                                  hideProgress();
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'Update Color', 'Delete Color'}.map((String choice) {
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
