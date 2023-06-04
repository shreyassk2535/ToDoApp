import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_first_app/data/database.dart';
import 'package:my_first_app/pages/todo_list.dart';

void main() async {
  await Hive.initFlutter();

  var box = await Hive.openBox("mybox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.yellow,
        ),
        home: const HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    if (db.NULL()) {
      db.createInitialData();
    } else {
      db.loadData();
    }

    super.initState();
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.yellow,
              content: SizedBox(
                height: 120,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Add a new task"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            onPressed: saveNewTask,
                            color: Theme.of(context).primaryColor,
                            child: const Text("Save"),
                          ),
                          const SizedBox(width: 8),
                          MaterialButton(
                            onPressed: () => Navigator.of(context).pop(),
                            color: Theme.of(context).primaryColor,
                            child: const Text("Cancel"),
                          )
                        ],
                      )
                    ]),
              ));
        });
    db.updateDataBase();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
    });
    Navigator.pop(context);
    _controller.value = TextEditingValue.empty;

    db.updateDataBase();
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });

    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow[200],
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "TO DO",
          ),
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: db.toDoList.length,
          itemBuilder: (content, index) {
            return ToDoList(
              deleteFunction: (context) => deleteTask(index),
              taskName: db.toDoList[index][0],
              taskCompleted: db.toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              // deleteFunction: (context) => deleteTask(index),
            );
          },
        ));
  }
}
