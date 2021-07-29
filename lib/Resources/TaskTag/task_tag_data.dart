import 'package:to_do_list_flutter/Resources/TaskTag/task_tag.dart';

class TaskTagFetchParams {
  TaskTagFetchParams({this.body, this.taskTagId});

  TaskTag? body;
  String? taskTagId;
}