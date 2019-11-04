import 'dart:collection';
import 'dart:convert';

import 'package:app_4_todo/app/model/Todo.dart';
import 'package:app_4_todo/app/model/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
    theme: ThemeData(
      hintColor: Colors.blue,
      primaryColor: Colors.blue,
    ),
    home: Home()));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dataProvider = DataProvider();
  final addTodoController = TextEditingController();

  final defaultFocusNode = FocusNode();

  List<Todo> _todoList = [];
  Todo _lastRemoved;
  int _lastRemovedIndex;

  @override
  initState() {
    super.initState();

    dataProvider.getFileContents().then((values){
      final List jsonData = json.decode(values);
      setState(() {
        jsonData.forEach((map){
          _todoList.add(Todo(map["title"], map["done"]));
        });
      });
    });
  }

  void _addTodo() async{
    String textToAdd = addTodoController.text;
    if(textToAdd != "" && textToAdd != null){
      setState(() {
        _todoList.add(Todo(textToAdd, false));
      });
      addTodoController.text = "";
      await dataProvider.saveFileContents(_todoList.toString());
      defaultFocusNode.requestFocus();
    }
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _todoList.sort((a, b){
        if(a.done && b.done) return 0;
        if(a.done) return 1;
        return -1;
      });
      dataProvider.saveFileContents(_todoList.toString());
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de Tarefas",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white))),
      body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                        controller: addTodoController,
                        decoration: InputDecoration(
                            labelText: "Nova Tarefa",
                            labelStyle: TextStyle(color: Colors.blue))),
                  ),
                  RaisedButton(
                    child: Text("ADD"),
                    onPressed: _addTodo,
                    color: Colors.blue,
                    textColor: Colors.white,
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(UniqueKey().toString()),                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment(-0.9, 0.0),
                          child: Icon(Icons.delete, color: Colors.white70),
                        ),
                      ),
                      child:  TodoRow(_todoList[index], _todoList),
                      onDismissed: (direction){
                        setState(() {
                          _lastRemoved = _todoList[index];
                          _lastRemovedIndex = index;
                          _todoList.remove(_lastRemoved);
                        });
                        dataProvider.saveFileContents(_todoList.toString());
                        final snack = SnackBar(
                          content: Text("Tarefa \"${_lastRemoved.title}\" excluída!"),
                          action: SnackBarAction(
                            label: "DESFAZER",
                            onPressed: (){
                              setState(() {
                                _todoList.insert(_lastRemovedIndex, _lastRemoved);
                                dataProvider.saveFileContents(_todoList.toString());
                              });
                            },
                          ),
                          duration: Duration(seconds: 2),
                        );
                        Scaffold.of(context).showSnackBar(snack);

                      },
                    );
                  }),
              ),
            ),
          ],
        ),
    );
  }
}

class TodoRow extends StatefulWidget {
  Todo todo;
  List listContext;

  TodoRow(this.todo, this.listContext);

  @override
  _TodoRowState createState() => _TodoRowState(this.todo, listContext);
}

class _TodoRowState extends State<TodoRow> {
  Todo todo;
  List listContext;

  _TodoRowState(this.todo, this.listContext);

  @override
  Widget build(BuildContext context) {

    return CheckboxListTile(
      value: todo.done,
      title: Text(todo.title),
      secondary: CircleAvatar(
        child: Icon(
            todo.done ? Icons.check : Icons.error,
            color: Colors.white70
        ),
        backgroundColor: todo.done ? Colors.green : Colors.blue,
      ),
      onChanged: (value){
        setState(()  {
          todo.done = value;
          print(listContext);
          new DataProvider().saveFileContents(listContext.toString());
        });
      },
    );

    return Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Icon(Icons.timer_off),
          ),
          Expanded(
            child: Text(todo.title),
          ),
          Checkbox(
              value: todo.done,
              onChanged: (v) {
                return v;
              })
        ],
      ),
    );
  }
}
