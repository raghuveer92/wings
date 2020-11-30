import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/auth.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class DrawerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerWidget();
}

class _DrawerWidget extends BaseState<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircularProfileAvatar(
                    Preferences.getString(PrefKeys.USER_IMAGE, ""),
                    radius: 32,
                    backgroundColor: Theme.of(context).primaryColor,
                    borderWidth: 5,
                    borderColor: Theme.of(context).primaryColorDark,
                    elevation: 5.0,
                    foregroundColor: Theme.of(context).primaryColor,
                    cacheImage: true,
                    showInitialTextAbovePicture: false,
                    initialsText: Text(
                      Preferences.getString(PrefKeys.NAME,"  ").substring(0, 1),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    Preferences.getString(PrefKeys.NAME) ?? "NA",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("${Preferences.getString(PrefKeys.EMAIL)}"),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
            ),
          ),
          Visibility(
            visible: false,
            child: ListTile(
              title: Text("My Profile"),
              onTap: () {
                Navigator.pushNamed(context, "/myProfile");
              },
            ),
          ),
          Visibility(
            visible: Preferences.getString(PrefKeys.EMAIL) != "raghuveer.ameta92@gmail.com",
            child: ListTile(
              title: Text("My Addresses"),
              onTap: () {
                Navigator.pushNamed(context, "/addresses");
              },
            ),
          ),
          Visibility(
            visible: Preferences.getString(PrefKeys.EMAIL) != "raghuveer.ameta92@gmail.com",
            child: ListTile(
              title: Text("My Orders"),
              onTap: () {
                Navigator.pushNamed(context, "/myOrders");
              },
            ),
          ),
          Visibility(
            visible: Preferences.getString(PrefKeys.EMAIL) == "raghuveer.ameta92@gmail.com",
            child: ListTile(
              title: Text("Categories"),
              onTap: () {
                Navigator.pushNamed(context, "/categories");
              },
            ),
          ),
          Visibility(
            visible: Preferences.getString(PrefKeys.EMAIL) == "raghuveer.ameta92@gmail.com",
            child: ListTile(
              title: Text("Products"),
              onTap: () {
                Navigator.pushNamed(context, "/products");
              },
            ),
          ),
          Visibility(
            visible: Preferences.getString(PrefKeys.EMAIL) == "raghuveer.ameta92@gmail.com",
            child: ListTile(
              title: Text("All Orders"),
              onTap: () {
                Navigator.pushNamed(context, "/orders");
              },
            ),
          ),
          FutureBuilder(
            future: AuthService().getLoggedUser(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                BackendlessUser user = snapshot.data;
                return Visibility(
                  child: ListTile(
                    title: Text(Preferences.getString(PrefKeys.ROLE, "USER") == "GUEST"?"Login":"Logout"),
                    onTap: () {
                      showProgress();
                      Backendless.userService.logout().then((value) {
                        hideProgress();
                        Preferences.clear();
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                      }).catchError((e){
                        hideProgress();
                      });
                    },
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
