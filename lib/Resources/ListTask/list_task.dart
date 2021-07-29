import 'dart:convert';

import 'package:to_do_list_flutter/Resources/TaskTag/task_tag.dart';

class ListTaskFactory {
  static ListTask create(String jsonString) {
    var json = jsonDecode(jsonString);
    var listTask = ListTaskFactory._fromJson(json);
    return listTask;
  }
  static ListTask _fromJson(Map<String, dynamic> json) {
    var listTask = ListTask();
    if (json["id"] is String) listTask.id = int.parse(json["id"]);
    if (json["name"] is String) listTask.name = json["name"];
    if (json["listTask"] is List) {
      List<dynamic> _list = json["listTask"];
      listTask.listTaskTag = _list.map((id) => int.parse(id.toString())).toList();
    }else{
      List<dynamic> _list =  jsonDecode(json["listTask"]);
      listTask.listTaskTag = _list.map((id) => int.parse(id.toString())).toList();
    }
    return listTask;
  }

  static Map<String, dynamic> toJson(ListTask listTask) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = listTask.id.toString();
    data["name"] = listTask.name;
    data["listTask"] = listTask.listTaskTag!.toString();
    return data;
  }
}


class ListTask{
  ListTask({ this.id,this.name,this.listTaskTag});
  int? id;
  String? name;
  List<int>? listTaskTag;

}