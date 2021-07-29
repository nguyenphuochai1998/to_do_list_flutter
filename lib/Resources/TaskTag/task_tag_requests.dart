import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:to_do_list_flutter/Provider/fetch.dart';
import 'package:to_do_list_flutter/Resources/ListTask/list_task.dart';
import 'package:to_do_list_flutter/Resources/TaskTag/task_tag.dart';
import 'package:to_do_list_flutter/Resources/TaskTag/task_tag_data.dart';
http.Client client = http.Client();


requestTaskTagByIdFormJson(TaskTagFetchParams? params) async {
  TaskTag taskTag ;
  final response = await client.get(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/Task/${params!.taskTagId}"));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }
  taskTag = TaskTagFactory.create(response.body);
  return taskTag;
}

requestUpdateTaskTagByIdFormJson(TaskTagFetchParams? params) async {
  TaskTag taskTag ;
  String aCheck =jsonEncode(TaskTagFactory.toJson(params!.body!));
  final response = await client.put(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/Task/${params.taskTagId}"),body:TaskTagFactory.toJson(params.body!));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }

  return 'Đã Update';
}
requestDeleteTaskTagByIdFormJson(TaskTagFetchParams? params) async {
  String aCheck =jsonEncode(TaskTagFactory.toJson(params!.body!));
  final responseList = await client.get(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/ListTask/${params.body!.listTaskId}"));
  var listTask = ListTaskFactory.create(responseList.body);
  if(listTask.listTaskTag!.remove(int.parse(params.body!.id.toString())) == true){
    final updateList = await client.put(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/ListTask/${params.body!.listTaskId}"),body: ListTaskFactory.toJson(listTask));
    if (updateList.statusCode != 200) {
      throw FetchError(httpStatus: updateList.statusCode, message: updateList.body);
    }
  }
  final response = await client.delete(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/Task/${params.taskTagId}"));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }

  return 'Đã Xoa';
}