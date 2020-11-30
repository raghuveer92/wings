import 'dart:async';

import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/src/widgets/async.dart';
import 'package:hive/hive.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

import 'auth.dart';

class DatabaseService {
  final String collectionName;
  Box box;

  DatabaseService(this.collectionName);

  Future<AppResponse<ResponseType, dynamic>> save(Map<String, dynamic> data, {String documentId}) async {
    try {
      if (documentId != null) {
        data["objectId"] = documentId;
      }
      var response = await Backendless.data.of(collectionName).save(data);
      return AppResponse<ResponseType, dynamic>(ResponseType.SUCCESS, response);
    } catch (e) {
      return AppResponse<ResponseType, dynamic>(ResponseType.ERROR, e.message);
    }
  }

  Future<dynamic> getLastDocument() async {
    return await Backendless.data.of(collectionName).findLast();
  }

  Future<dynamic> get(String documentId, {List<String> related, int relationsDepth}) async {
    DataQueryBuilder queryBuilder;
    if (related != null) {
      queryBuilder = DataQueryBuilder();
      queryBuilder.related = related;
      queryBuilder.relationsDepth = relationsDepth;
    }
    return await Backendless.data.of(collectionName).findById(documentId, queryBuilder: queryBuilder);
  }

  Future<dynamic> delete(Map element) async {
    return await Backendless.data.of(collectionName).remove(entity: element);
  }

  Future<dynamic> find({String query, List<String> orderBy, List<String> related, int relationsDepth}) async {
    DataQueryBuilder queryBuilder;
    queryBuilder = DataQueryBuilder();
    queryBuilder.whereClause = query;
    queryBuilder.sortBy = orderBy;
    queryBuilder.related = related;
    queryBuilder.relationsDepth = relationsDepth;
    queryBuilder.pageSize = 50;
    return await Backendless.data.of(collectionName).find(queryBuilder);
  }

  Future addRelation(String objectId, String columnName, List<String> childrenObjectIds) async {
    print("addRelation($objectId, $columnName, $childrenObjectIds)");
    return await Backendless.data.of(collectionName).addRelation(objectId, columnName, childrenObjectIds: childrenObjectIds);
  }

  Future saveLocalList({String query, List<String> orderBy, String key}) async {
    var value = await find(query: query, orderBy: orderBy);
    if (value != null) {
      var box = this.box ?? await Hive.openBox("$collectionName$key");
      await box.clear();
      await box.addAll(value);
    }
  }

  Future saveLocalObject(String documentId, {List<String> related, int relationsDepth, String key}) async {
    var value = await get(documentId, related: related, relationsDepth: relationsDepth);
    if (value != null) {
      var box = this.box ?? await openBox(key: key);
      await box.clear();
      await box.add(value);
    }
  }

  static updateCart() async {
    FBroadcast.instance().broadcast("cart");
  }

  Future saveLocal(AsyncSnapshot<dynamic> snapshot, {String key}) async {
    await box.clear();
    await box.add(snapshot.data);
  }

  Future<Box> openBox({String key}) async {
    box = await Hive.openBox("$collectionName$key");
    return box;
  }

  void close() {
    box?.close();
  }
}
