import 'package:badges/badges.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class Cart extends StatefulWidget {
  final bool home;

  const Cart(this.home, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Cart();
}

class _Cart extends State<Cart> {
  DatabaseService _databaseService = new DatabaseService("cartItems");
  @override
  void initState() {
    super.initState();
    FBroadcast.instance().register("cart", (value, callback) {
      _databaseService.saveLocalList(query: "userId='${Preferences.getString(PrefKeys.USER_ID)}'");
    },context: this);
    _databaseService.saveLocalList(query: "userId='${Preferences.getString(PrefKeys.USER_ID)}'");
  }

  @override
  void dispose() {
    FBroadcast.instance().unregister(this);
    _databaseService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _databaseService.openBox(key: Preferences.getString(PrefKeys.USER_ID)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return ValueListenableBuilder(
            valueListenable: _databaseService.box.listenable(),
            builder: (context, _, __) {
              return Badge(
                badgeContent: Text(
                  '${_databaseService.box.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                showBadge: _databaseService.box.length > 0,
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(context, "/cartItems").then((value) {
                      setState(() {});
                    });
                  },
                ),
                badgeColor: Colors.white,
                position: BadgePosition.topEnd(top: 2, end: 2),
              );
            });
      },
    );
  }
}
