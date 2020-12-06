import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/widgets/image_loader.dart';

class Categories extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CategoriesState();
}

class _CategoriesState extends BaseState<Categories> {
  var databaseService = DatabaseService("categories");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
        elevation: 5.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/addCategories").then((value) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: databaseService.find(),
        builder: (context, spanshot) {
          if (spanshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (spanshot.hasError) {
            return Center(child: Text(spanshot.error.toString()));
          }
          List<Map<dynamic, dynamic>> querySnapshot = spanshot.data;
          print("querySnapshot: ${querySnapshot.length}");
          return ListView.builder(
            itemCount: querySnapshot.length,
            itemBuilder: (context, index) {
              Map<dynamic, dynamic> document = querySnapshot[index];
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
                            case 'Update Product':
                              Navigator.pushNamed(context, "/updateCategories", arguments: document["objectId"]);
                              break;
                            case 'Delete Product':
                              showProgress();
                              try {
                                databaseService.delete(document);
                              } catch (e) {
                                print(e);
                              }
                              hideProgress();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Update Product', 'Delete Product'}.map((String choice) {
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
              );
            },
          );
        },
      ),
    );
  }
}
