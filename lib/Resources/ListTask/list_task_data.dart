import 'package:to_do_list_flutter/Resources/ListTask/list_task.dart';

class ListTaskFetchParams {
  ListTaskFetchParams({this.body, this.listTaskId});

  ListTask? body;
  int? listTaskId;
}