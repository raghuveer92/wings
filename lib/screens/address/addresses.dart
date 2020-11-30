import 'package:flutter/material.dart';
import 'package:wings/custom_views/sub_title_text.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/services/database.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class Addresses extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddressesState();
}

class _AddressesState extends BaseState<Addresses> {
  var databaseService = DatabaseService('addresses');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Addresses"),
        elevation: 5.0,
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: (){
            Navigator.pushNamed(context, "/addAddress").then((value){
              setState(() {
              });
            });
          })
        ],
      ),
      body: FutureBuilder(
        future: databaseService.find(query: "userId='${Preferences.getString(PrefKeys.USER_ID)}'"),
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
            itemBuilder: (context, index){
              Map document = querySnapshot[index];
              return Card(
                elevation: 5,
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: new Text("${document['name']}"),
                      ),
                      Expanded(
                        flex: 0,
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'Update Address':
                                Navigator.pushNamed(context, "/updateAddress", arguments: document["objectId"]);
                                break;
                              case 'Delete Address':
                                showProgress();
                                try{
                                  await databaseService.delete(document);
                                }catch(e){
                                  print(e);
                                }
                                hideProgress();
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Update Address','Delete Address'}.map((String choice) {
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SubTitle("${document['fullAddress']}"),
                      SubTitle("${document['mobileNumber']}"),
                      SizedBox(height: 8,)
                    ],
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
