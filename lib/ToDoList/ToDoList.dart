import 'package:flutter/material.dart';
import '../constants/Colors.dart';
import 'todo.dart';
import 'todo_item.dart';

class ToDoList extends StatefulWidget {
  ToDoList({Key? key}) : super(key: key);

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final _todoController = TextEditingController();
  String _selectedPriority = 'Relatively Soon';
  late List<ToDo> todosList = [];
  late List<ToDo> _foundToDo = [];

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  Future<void> _loadToDoList() async {
    await ToDo.loadToDoListFromFirebase();
    setState(() {
      todosList = ToDo.todoList;
      _foundToDo = todosList;
    });
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    ToDo.updateToDoItem(todo);
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      _foundToDo = todosList;
    });
    ToDo.deleteToDoItem(id);
  }

  void _addToDoItem(String toDo, String priority) {
    setState(() {
      ToDo.addTodoItem(toDo, priority);
      todosList = ToDo.todoList;
      _foundToDo = todosList;
    });
    _todoController.clear();
    _selectedPriority = 'Relatively Soon';
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: searchBox(),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 50,
                    bottom: 20,
                  ),
                  child: Text(
                    'All ToDos',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                for (ToDo todo in _foundToDo.reversed)
                  ToDoItem(
                    todo: todo,
                    onToDoChanged: _handleToDoChange,
                    onDeleteItem: _deleteToDoItem,
                  ),
              ],
            ),
          ),
          _buildAddToDoField(),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  Widget _buildAddToDoField() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
        right: 20,
        left: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                    spreadRadius: 0.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Add Task',
                      border: InputBorder.none,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    items: <String>[
                      'Urgent',
                      'Timely',
                      'Relatively Soon',
                      'Down to line'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            onPressed: () {
              _addToDoItem(_todoController.text, _selectedPriority);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tdBlue,
              minimumSize: Size(60, 60),
              elevation: 10,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.deepPurple.shade600,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'MyList ToDo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/profile.png'),
            ),
          ),
        ],
      ),
    );
  }
}
