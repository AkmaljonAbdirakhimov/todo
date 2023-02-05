import 'package:serverpod/serverpod.dart';
import 'package:todo_server/src/generated/protocol.dart';

class TodoEndpoint extends Endpoint {
  Future<bool> addTodo(Session session, Todo todo) async {
    await Todo.insert(session, todo);
    return true;
  }

  Future<List<Todo>> getTodos(Session session) async {
    return await Todo.find(session);
  }

  Future<bool> toggleTodo(Session session, Todo todo) async {
    return await Todo.update(session, todo);
  }

  Future<bool> deleteTodo(Session session, int id) async {
    final result = Todo.delete(session, where: (todo) => todo.id.equals(id));
    return result == 1;
  }
}
