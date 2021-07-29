import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/testing.dart';
import 'package:to_do_list_flutter/Provider/fetch.dart';
import 'package:to_do_list_flutter/Provider/index.dart';
import 'package:to_do_list_flutter/Resources/ListTask/list_task.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list_flutter/Resources/ListTask/list_task_data.dart';
import 'package:to_do_list_flutter/Resources/ListTask/list_task_requests.dart';
import 'package:to_do_list_flutter/Resources/TaskTag/task_tag.dart';
import 'package:to_do_list_flutter/Resources/TaskTag/task_tag_data.dart';
import 'package:to_do_list_flutter/Resources/TaskTag/task_tag_requests.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToDoListPage(),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Fetch<List<ListTask>?, dynamic>(
            request: requestListListTaskFormJson,
            builder: (fetchState) {
              if (fetchState.response == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextButton(onPressed: (){}, child: Text("Thêm")),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: fetchState.response!
                            .map((listTask) => Fetch<String?,
                                    ListTaskFetchParams>(
                                params: ListTaskFetchParams(
                                    listTaskId: listTask.id),
                                lazy: true,
                                request: requestDeleteListTask,
                                builder: (fetchStateDeleteButton) {
                                  if (fetchStateDeleteButton.response == null) {
                                    return ListTagWidget(
                                      countOfTask: listTask.listTaskTag!.length,
                                      name: listTask.name!,
                                      onDelete: () {
                                        fetchStateDeleteButton.fetch(null);
                                      },
                                      child: Column(
                                          children: listTask.listTaskTag!
                                              .map((e) => Fetch<TaskTag?,
                                                      TaskTagFetchParams>(
                                                  params: TaskTagFetchParams(
                                                      taskTagId: e.toString()),
                                                  request:
                                                      requestTaskTagByIdFormJson,
                                                  builder: (fetchStateTaskTag) {
                                                    if (fetchStateTaskTag
                                                            .response ==
                                                        null) {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    } else {
                                                      TaskTag _taskTag =
                                                          fetchStateTaskTag
                                                              .response!;
                                                      return TaskTagWidget(
                                                        taskTagGet: _taskTag,
                                                      );
                                                    }
                                                  }))
                                              .toList()),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class ListTagWidget extends StatefulWidget {
  const ListTagWidget(
      {required this.countOfTask,
      required this.name,
      required this.onDelete,
      this.child});

  final int countOfTask;
  final String name;
  final VoidCallback onDelete;
  final Widget? child;

  @override
  _ListTagWidgetState createState() => _ListTagWidgetState();
}

class _ListTagWidgetState extends State<ListTagWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "${widget.name}  Số task:${widget.countOfTask}",
                style: TextStyle(fontSize: 20),
              ),
              TextButton(
                  onPressed: this.widget.onDelete, child: Text("Xóa Bảng"))
            ],
          ),
          this.widget.child!
        ],
      ),
    );
  }
}

class TaskTagWidget extends StatefulWidget {
  const TaskTagWidget({required this.taskTagGet});

  final TaskTag taskTagGet;

  @override
  _TaskTagWidgetState createState() => _TaskTagWidgetState();
}

class _TaskTagWidgetState extends State<TaskTagWidget> {
  final noteController = TextEditingController();
  final nameController = TextEditingController();
  var keyProvider = "";

  bool _checkDelete = false;
  TaskTag taskTag = new TaskTag();
  late Provider _provider;

  bool checkOnchange() {
    if (taskTag.note != noteController.text) {
      return false;
    }

    if (taskTag.name != nameController.text) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    taskTag = this.widget.taskTagGet;
    keyProvider = "key_task${taskTag.id}";
    _provider = Provider<bool?>(providerKey: keyProvider, value: false);
    noteController.text = taskTag.note!;
    nameController.text = taskTag.name!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<bool>(providerKey: keyProvider, builder: (context,value){

      return value ? Container():Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(
              5.0) //                 <--- border radius here
          ),
        ),
        child: LayoutBuilder(
          builder: (context, containers) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------------
                Fetch<String, TaskTagFetchParams>(
                    request: requestDeleteTaskTagByIdFormJson,
                    lazy: true,
                    params: TaskTagFetchParams(
                        body: taskTag, taskTagId: taskTag.id),
                    builder: (fetchStateDelete) {
                      if (fetchStateDelete.response == null) {
                        return TextButton(
                            onPressed: () {
                              this._provider.setValue(true);
                              fetchStateDelete.fetch(null);
                            },

                            child: Text(
                              "Xóa",
                              style: TextStyle(color: Colors.redAccent),
                            ));
                      } else {
                        _checkDelete = true;
                        _provider.setValue(_checkDelete);
                        return Container();
                      }
                      return Container();
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: containers.maxWidth * 0.7,
                      child: TextFormField(
                        controller: nameController,
                        maxLines: 1,
                        decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide:
                              new BorderSide(color: Colors.teal)),
                          hintText: 'Tên Task',
                          labelText: 'Tên Task',
                          prefixIcon: const Icon(
                            Icons.note,
                            color: Colors.redAccent,
                          ),
                        ),
                        onChanged: (txt) {
                          setState(() {});
                        },
                      ),
                    ),
                    checkOnchange()
                        ? Container()
                        : Fetch<String, TaskTagFetchParams>(
                      lazy: true,
                      request: requestUpdateTaskTagByIdFormJson,
                      params: TaskTagFetchParams(
                          body: TaskTag(
                            listTaskId: taskTag.listTaskId,
                            assignee: taskTag.assignee,
                            id: taskTag.id,
                            name: nameController.text,
                            note: noteController.text,
                          ),
                          taskTagId: taskTag.id),
                      builder: (fetchState) {
                        if (fetchState.response == null) {
                          return InkWell(
                              onTap: () {
                                fetchState.fetch(null);
                              },
                              child: Text(
                                "Cập Nhật Task",
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold),
                              ));
                        }
                        taskTag = TaskTag(
                          listTaskId: taskTag.listTaskId,
                          assignee: taskTag.assignee,
                          id: taskTag.id,
                          name: nameController.text,
                          note: noteController.text,
                        );
                        return Container();
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    "Người thực hiện: ${taskTag.listTaskId}",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                    hintText: 'Ghi chú zô',
                    labelText: 'Ghi CHú',
                    prefixIcon: const Icon(
                      Icons.note,
                      color: Colors.redAccent,
                    ),
                  ),
                  onChanged: (txt) {
                    setState(() {});
                  },
                )



              ],
            );
          },
        ),
      );


    });
  }
}
