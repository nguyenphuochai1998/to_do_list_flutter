import 'dart:convert';

class TaskTagFactory {
  static TaskTag create(String jsonString) {
    var json = jsonDecode(jsonString);
    var taskTag = TaskTagFactory._fromJson(json);
    return taskTag;
  }
  static TaskTag _fromJson(Map<String, dynamic> json) {
    var taskTag = TaskTag();
    if (json["id"] is String) taskTag.id = json["id"];
    if (json["name"] is String) taskTag.name = json["name"];
    if (json["note"] is String) taskTag.note = json["note"];
     taskTag.assignee = int.parse(json["assignee"].toString()) ;
     taskTag.listTaskId = int.parse(json["listTaskId"].toString()) ;
    return taskTag;
  }

  static Map<String, dynamic> toJson(TaskTag taskTag) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = taskTag.id ;
    data["name"] = taskTag.name;
    data["note"] = taskTag.note;
    data["assignee"] = taskTag.assignee.toString();
    data["listTaskId"] = taskTag.listTaskId.toString();
    return data;
  }
}


class TaskTag{
  TaskTag({ this.id,this.name,this.note,this.assignee,this.listTaskId});
  String? id;
  String? name;
  String? note;
  int? assignee;
  int? listTaskId;

}