import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_flutter/Provider/fetch.dart';
import 'package:to_do_list_flutter/Provider/index.dart';
import 'package:to_do_list_flutter/Resources/ListTask/list_task.dart';
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
  static late Provider provider;
  static Provider providerWidget =
      Provider<dynamic>(providerKey: "ToDoListPageWidget", value: null);

  ToDoListPage() {
    provider = Provider(providerKey: "ToDoListPage", value: false);
  }

  @override
  _ToDoListPageState createState() => _ToDoListPageState();

  static SetLoading() {
    provider.setValue(true);
  }

  static UnLoading() {
    provider.setValue(false);
  }
}

enum TypeWidgetBuild { loading, error }

class _ToDoListPageState extends State<ToDoListPage> {
  bool _isLoading = false;
  String _txtLoading = 'loading...';

  @override
  void initState() {
    super.initState();
    Provider.registerCallback(ProviderCallback("ToDoListPage", setLoading));
  }

  void setLoading(value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _isLoading ? _loading(text: _txtLoading) : Container(),
            Fetch<List<ListTask>?, dynamic>(
                request: requestListListTaskFormJson,
                builder: (fetchState) {
                  if (fetchState.loading!) {
                    ToDoListPage.providerWidget
                        .setValue(TypeWidgetBuild.loading);
                    return Consumer<dynamic>(
                        providerKey: "ToDoListPageWidget",
                        builder: (context, value) {
                          if (value is TypeWidgetBuild) {
                            if (value == TypeWidgetBuild.loading)
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                          }
                        });
                  }
                  ToDoListPage.providerWidget.setValue(fetchState.response);
                  return Consumer<dynamic>(
                      providerKey: "ToDoListPageWidget",
                      builder: (context, value) {
                        if (value is List<ListTask>) {
                          return Container(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return dialogSetNewTag();
                                            });
                                      },
                                      child: Text("Thêm")),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: value
                                        .map((listTask) =>
                                            Fetch<String?, ListTaskFetchParams>(
                                                params: ListTaskFetchParams(
                                                    listTaskId: listTask.id),
                                                lazy: true,
                                                request: requestDeleteListTask,
                                                builder:
                                                    (fetchStateDeleteButton) {
                                                  if (fetchStateDeleteButton
                                                          .response ==
                                                      null) {
                                                    return ListTagWidget(
                                                      countOfTask: listTask
                                                          .listTaskTag!.length,
                                                      name: listTask.name!,
                                                      onDelete: () async {
                                                        setLoading(true);
                                                        await fetchStateDeleteButton
                                                            .fetch(null);
                                                        setLoading(false);
                                                      },
                                                      child: Column(
                                                          children: listTask
                                                              .listTaskTag!
                                                              .map((e) => Fetch<
                                                                      TaskTag?,
                                                                      TaskTagFetchParams>(
                                                                  params: TaskTagFetchParams(
                                                                      taskTagId: e
                                                                          .toString()),
                                                                  request:
                                                                      requestTaskTagByIdFormJson,
                                                                  builder:
                                                                      (fetchStateTaskTag) {
                                                                    if (fetchStateTaskTag
                                                                            .response ==
                                                                        null) {
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      );
                                                                    } else {
                                                                      TaskTag
                                                                          _taskTag =
                                                                          fetchStateTaskTag
                                                                              .response!;
                                                                      return TaskTagWidget(
                                                                        taskTagGet:
                                                                            _taskTag,
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
                        }
                        return Container();
                      });
                })
          ],
        ),
      ),
    );
  }

  Widget _loading({text}) {
    return Align(
        alignment: Alignment.center,
        child: Container(
            color: Colors.lightBlue.withOpacity(0.3),
            height: 150,
            width: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  text,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )
              ],
            )));
  }
}

class dialogSetNewTag extends StatefulWidget {
  @override
  _dialogSetNewTagState createState() => _dialogSetNewTagState();
}

class _dialogSetNewTagState extends State<dialogSetNewTag> {
  TextEditingController _noteController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String idList = '';
  bool _isLoading = false;

  void setLoading(value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: AlertDialog(
        content: Container(
          color: Colors.white,
          child: Stack(
            children: [
              _isLoading
                  ? Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
              Fetch<List<ListTask>?, dynamic>(
                  request: requestListListTaskFormJson,
                  builder: (fetchState) {
                    if (fetchState.loading!) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (idList.isEmpty) {
                      idList = fetchState.response!.first.id.toString();
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("Chọn Task"),
                          DropdownButton(
                            value: idList,
                            items: fetchState.response!
                                .map((e) => DropdownMenuItem<String>(
                                      value: e.id.toString(),
                                      child: new Text(e.name!),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                idList = value.toString();
                              });
                            },
                          ),
                          TextFormField(
                            controller: _nameController,
                            maxLines: 1,
                            decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'ghi ten task zô',
                              labelText: 'Ten task',
                              prefixIcon: const Icon(
                                Icons.note,
                                color: Colors.redAccent,
                              ),
                            ),
                            onChanged: (txt) {
                              setState(() {});
                            },
                          ),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
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
                          ),
                          TextButton(
                              onPressed: () async {
                                setLoading(true);
                                var _taskTag = await requestCreateTaskTagByIdFormJson(
                                    TaskTagFetchParams(
                                        taskTagId: '200',
                                        body: TaskTag(
                                            note: this._noteController.text,
                                            name: this._nameController.text,
                                            id: '200',
                                            listTaskId: int.parse(this.idList),
                                            assignee: 1)));
                                setLoading(false);
                                if(_taskTag is TaskTag && _taskTag != null){
                                  List<ListTask> data = Provider.providers[ToDoListPage.providerWidget.providerKey] == null?{}:Provider.providers[ToDoListPage.providerWidget.providerKey];
                                  ListTask _listTask = data.where((element) => element.id == _taskTag.listTaskId).first;
                                  _listTask.listTaskTag!.add(int.parse(_taskTag.id!));
                                  var listReturn = data.map((e) {
                                    if(e.id == _listTask.id){
                                      return _listTask;
                                    }
                                    return e;
                                  }).toList();
                                  ToDoListPage.providerWidget.setValue(listReturn);
                                }
                                Navigator.pop(context);
                              },
                              child: Text("Thêm"))
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
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
                  onPressed: () async {
                    this.widget.onDelete();
                  },
                  child: Text("Xóa Bảng"))
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
    return Consumer<bool>(
        providerKey: keyProvider,
        builder: (context, value) {
          return value
              ? Container()
              : Container(
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
                                      onPressed: () async {
                                        ToDoListPage.SetLoading();
                                        await fetchStateDelete.fetch(null);
                                        ToDoListPage.UnLoading();
                                        await this._provider.setValue(true);
                                      },
                                      child: Text(
                                        "Xóa",
                                        style:
                                            TextStyle(color: Colors.redAccent),
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
                                              onTap: () async {
                                                ToDoListPage.SetLoading();
                                                await fetchState.fetch(null);
                                                ToDoListPage.UnLoading();
                                              },
                                              child: Text(
                                                "Cập Nhật Task",
                                                style: TextStyle(
                                                    color: Colors.lightBlue,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
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
