import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:to_do_list_flutter/Provider/fetch.dart';
import 'package:to_do_list_flutter/Resources/ListTask/list_task.dart';
import 'package:to_do_list_flutter/Resources/ListTask/list_task_data.dart';
http.Client client = http.Client();


requestListListTaskFormJson(dynamic params) async {
  List<ListTask> _list = [];
  final response = await client.get(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/ListTask"));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }
  _list = (jsonDecode(response.body) as List)
      .map((data) => ListTaskFactory.create(json.encode(data)))
      .toList();
  print("lisst $_list");
  return _list;
}


requestDeleteListTask(ListTaskFetchParams? params) async {
  final response = await client.delete(Uri.parse("https://60ffcd75bca46600171cf51f.mockapi.io/ListTask/${params!.listTaskId}"));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }
  return 'Da xoa';
}
