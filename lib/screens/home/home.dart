import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/widgets/cart.dart';
import 'package:wings/widgets/drawer.dart';
import 'package:wings/widgets/image_loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends BaseState<Home> {
  DatabaseService _databaseService = DatabaseService("categories");
  @override
  void initState() {
    super.initState();
    _databaseService.saveLocalList(orderBy: ["score ASC"]);
    // final _messaging = FBMessaging.instance;
    // _messaging.requestPermission().then((_) async {
    //   final _token = await _messaging.getToken();
    //   print('Token: $_token');
    // });
    // _messaging.stream.listen((event) {
    //   print('New Message: ${event}');
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wings"),
        elevation: 5.0,
        actions: [
          Cart(true),
        ],
      ),
      drawer: DrawerWidget(),
      body: FutureBuilder(
        future: _databaseService.openBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return ValueListenableBuilder(
            valueListenable: _databaseService.box.listenable(),
            builder: (context, Box box, _) {
              print("box size: ${_databaseService.box.length}");
              return ListView.builder(
                itemCount: _databaseService.box.length,
                padding: EdgeInsets.only(top: 4, bottom: 4),
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> document = _databaseService.box.getAt(index);
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, "/productsByCategory", arguments: document["objectId"]);
                    },
                    child: Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.only(right: index % 2 == 0 ? 8 : 24, left: index % 2 == 0 ? 24 : 8, top: 4, bottom: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: ImageView(
                          imageUrl: '${document['mainImage']}',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
