import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  String id;
  String todoText;
  bool isDone;
  String priority;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    required this.priority,
  });

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'] ?? false,
      priority: json['priority'] ?? 'Relatively Soon',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'todoText': todoText,
    'isDone': isDone,
    'priority': priority,
  };

  static List<ToDo> todoList = [];

  static void addTodoItem(String text, String priority) {
    var newId = DateTime.now().millisecondsSinceEpoch.toString();
    var newItem = ToDo(
      id: newId,
      todoText: text,
      priority: priority,
    );
    todoList.add(newItem);
    FirebaseFirestore.instance.collection('todolist').doc(newId).set(newItem.toJson()).catchError((error) {
      print("Failed to add todo: $error");
    });
  }

  static Future<void> loadToDoListFromFirebase() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection('todolist').get();
      todoList = querySnapshot.docs.map((doc) => ToDo.fromJson(doc.data())).toList();
    } catch (error) {
      print("Failed to load todos: $error");
    }
  }

  static Future<void> updateToDoItem(ToDo todo) async {
    try {
      await FirebaseFirestore.instance.collection('todolist').doc(todo.id).update(todo.toJson());
    } catch (error) {
      print("Failed to update todo: $error");
    }
  }

  static Future<void> deleteToDoItem(String id) async {
    try {
      await FirebaseFirestore.instance.collection('todolist').doc(id).delete();
    } catch (error) {
      print("Failed to delete todo: $error");
    }
  }
}
