import 'dart:io';

import 'package:todo_client/todo_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

var domain = Platform.isAndroid ? "http://10.0.2.2" : "http://localhost";
var client = Client('$domain:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Serverpod Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // These fields hold the last result or error message that we've received from
  // the server or null if no result exists yet.
  String? _resultMessage;
  String? _errorMessage;

  List<Todo> _todos = [];

  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAllTodos();
  }

  // Calls the `hello` method of the `example` endpoint. Will set either the
  // `_resultMessage` or `_errorMessage` field, depending on if the call
  // is successful.
  void _callHello() async {
    try {
      final result = await client.example.hello(_textEditingController.text);
      setState(() {
        _resultMessage = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _addTodo() async {
    final todo = Todo(
      title: _textEditingController.text,
      date: DateTime.now(),
      isDone: false,
    );

    try {
      final result = await client.todo.addTodo(todo);
      if (result) {
        setState(() {
          _resultMessage = 'Todo Added';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _getAllTodos() async {
    try {
      _todos = await client.todo.getTodos();
      setState(() {
        _resultMessage = 'Todo Added';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }

    _getAllTodos();
  }

  void _toggleTodo(Todo todo) async {
    try {
      final result = await client.todo.toggleTodo(todo);

      setState(() {
        _resultMessage = result ? 'Todo Updated' : 'Todo Update Failed';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _deleteTodo(int id) async {
    try {
      final result = await client.todo.deleteTodo(id);

      setState(() {
        _resultMessage = result ? 'Todo Deleted' : 'Todo Delete Failed';
      });
      _getAllTodos();
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _addTodo,
                child: const Text('Send to Server'),
              ),
            ),
            _ResultDisplay(
              resultMessage: _resultMessage,
              errorMessage: _errorMessage,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (ctx, i) {
                  var todo = _todos[i];
                  return ListTile(
                    leading: IconButton(
                      onPressed: () {
                        // toggleTodo
                        _toggleTodo(todo..isDone = !todo.isDone);
                      },
                      icon: Icon(
                        todo.isDone
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                      ),
                    ),
                    title: Text(todo.title),
                    subtitle: Text(todo.date.toString()),
                    trailing: IconButton(
                      onPressed: () {
                        // delete todo
                        _deleteTodo(todo.id!);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// _ResultDisplays shows the result of the call. Either the returned result from
// the `example.hello` endpoint method or an error message.
class _ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;

  const _ResultDisplay({
    this.resultMessage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return Container(
      height: 50,
      color: backgroundColor,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
