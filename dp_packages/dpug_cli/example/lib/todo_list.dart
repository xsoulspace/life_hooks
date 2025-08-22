import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> todos = ['Learn DPUG', 'Build Flutter app', 'Test conversion'];
  String newTodo = '';

  void addTodo() {
    if (newTodo.isNotEmpty) {
      setState(() {
        todos = [...todos, newTodo];
        newTodo = '';
      });
    }
  }

  void removeTodo(final int index) {
    setState(() {
      todos = todos.where((final todo) => todo != todos[index]).toList();
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Todo List')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: newTodo),
                  onChanged: (final value) => setState(() => newTodo = value),
                  decoration: const InputDecoration(
                    hintText: 'Enter new todo...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: addTodo, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: todos.isEmpty
              ? const Center(
                  child: Text(
                    'No todos yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (final context, final index) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(todos[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => removeTodo(index),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}
