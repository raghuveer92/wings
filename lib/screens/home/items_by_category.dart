import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wings/custom_views/sub_title_text.dart';
import 'package:wings/custom_views/title_text.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/colors.dart';
import 'package:wings/widgets/cart.dart';
import 'package:wings/widgets/image_loader.dart';

class ItemsByCategory extends StatefulWidget {
  final String categoryId;

  const ItemsByCategory({Key key, this.categoryId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ItemsByCategoryState();
}

class _ItemsByCategoryState extends BaseState<ItemsByCategory> {
  DatabaseService _databaseService = DatabaseService("items");

  @override
  void initState() {
    super.initState();
    _databaseService.saveLocalList(query: "categoryId='${widget.categoryId}'", key: widget.categoryId);
  }
  @override
  void dispose() {
    super.dispose();
    _databaseService.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        elevation: 5.0,
        actions: [
          Cart(false),
        ],
      ),
      body: FutureBuilder(
        future: _databaseService.openBox(key: widget.categoryId),
        builder: (context, spanshot) {
          if (spanshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (spanshot.hasError) {
            return Center(child: Text(spanshot.error.toString()));
          }
          return ValueListenableBuilder(valueListenable: _databaseService.box.listenable(), builder: (context, Box _, __) {
            if (spanshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (spanshot.hasError) {
              return Center(child: Text(spanshot.error.toString()));
            }
            if (_databaseService.box.length == 0) {
              return Center(
                child: TitleText(
                  "Coming Soon...",
                ),
              );
            }
            return ListView.builder(
              itemCount: _databaseService.box.length,
              itemBuilder: (context, index) {
                Map document = _databaseService.box.getAt(index);
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/product", arguments: document["objectId"]);
                  },
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        height: 200,
                        width: double.maxFinite,
                        color: Colors.grey[400],
                        child: ImageView(
                          imageUrl: '${document['mainImage']}',
                          height: 200,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: AppColors.transparentBlack,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleText("${document['name']}", textSize: 16, color: Colors.white),
                                  SubTitle(
                                    "${document['description']}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SubTitle("₹${document['marketPrice']}", maxLines: 1, color: Colors.white, decoration: TextDecoration.lineThrough,),
                                  TitleText("₹${document['currentPrice']}", color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
