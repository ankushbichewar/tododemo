import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:tododemo/model.dart';

dynamic database;

class Adtodo extends StatefulWidget {
  const Adtodo({super.key});
  @override
  State<Adtodo> createState() => _AdtodoState();
}

class _AdtodoState extends State<Adtodo> {
  List carddata = [

  ];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    databaseConnection();
  }

  void databaseConnection() async {
    database = openDatabase(
      path.join(await getDatabasesPath(), "todoad.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
    Create table ToDoTask(
      taskId INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      date DATE
    )

 ''');
      },
    );
  await getData();
  }

  Future<void> insertTask(ToDoModel obj) async {
    final localDB = await database;

    await localDB.insert('ToDoTask', obj.todoMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

//fetch tasks
  Future getAllTask() async {
    final localDB = await database;
    List<Map<String, dynamic>> taskdata = await localDB.query('ToDoTask');
   return List.generate(taskdata.length, (index) {
      return ToDoModel(
          taskId: taskdata[index]['taskId'],
          title: taskdata[index]['title'],
          description: taskdata[index]['description'],
          date: taskdata[index]['date']);
    });
  }

//delete
  Future<void> deleteTask(ToDoModel obj) async {
    final localDB = await database;

    await localDB
        .delete('ToDoTask', where: 'taskId=?', whereArgs: [obj.taskId]);
  }

  //update task
  Future updateTask(ToDoModel obj) async {
    final localDB = await database;
    await localDB.update('ToDoTask', obj.todoMap(),
        where: 'taskId=?', whereArgs: [obj.taskId]);
  }

  Future getData() async {
     List taskdata1 = await getAllTask();
    setState(() {
      carddata = taskdata1;
    });
  }

//submitTask

  void submitTask(bool isEdit, [ToDoModel? toDoModelobj]) {
    if (titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty) {
      if (!isEdit) {
         insertTask(ToDoModel(
              title: titleController.text,
              description: descriptionController.text,
              date: dateController.text));
        setState(() {
        });
     
      } else {
        toDoModelobj!.title = titleController.text.trim();
          toDoModelobj.description = descriptionController.text.trim();
          toDoModelobj.date = dateController.text.trim();
          editTask(toDoModelobj);
        setState(() {
        });
      }
    }
    clearController();
  }

//to edit task
  void editTask(ToDoModel toDoModelobj) {
    titleController.text = toDoModelobj.title;
    descriptionController.text = toDoModelobj.description;
    dateController.text = toDoModelobj.date;
    showBottomSheet(true, toDoModelobj);
    getData();
  }

//clear task
  void clearController() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    //updateTask(toDoModelobj);
  }

  void showBottomSheet(bool isEdit, [ToDoModel? toDoModelobj]) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        isScrollControlled: true,
        isDismissible: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,

                ///TO AVOID THE KEYBOARD OVERLAP THE SCREEN
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Create Task",
                      style:// GoogleFonts.quicksand
                      TextStyle
                      (
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      const Text(
                          "Title",
                          style://GoogleFonts.quicksand
                          TextStyle(
                            color: const Color.fromRGBO(111, 81, 255, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(111, 81, 255, 1),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.purpleAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "Description",
                          style: //GoogleFonts.quicksand
                          TextStyle(
                            color: const Color.fromRGBO(111, 81, 255, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(111, 81, 255, 1),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.purpleAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "Date",
                          style:// GoogleFonts.quicksand
                          TextStyle(
                            color: const Color.fromRGBO(111, 81, 255, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.date_range_rounded),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(111, 81, 255, 1),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.purpleAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onTap: () async {
                            DateTime? pickeddate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2025),
                            );
                            String formatedDate =
                                DateFormat.yMMMd().format(pickeddate!);
                            setState(() {
                              dateController.text = formatedDate;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(111, 81, 255, 1),
                        ),
                        onPressed: () {
                          isEdit
                              ? submitTask(isEdit, toDoModelobj)
                              : submitTask(isEdit);
                          Navigator.of(context).pop();
                        },
                        child:const  Text(
                          "Submit",
                          style: //GoogleFonts.inter
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
  getData();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(111, 81, 255, 1),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromRGBO(111, 81, 255, 1),
          onPressed: () {
            showBottomSheet(false);
            clearController();
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Container(
              alignment: Alignment.centerLeft,
              child:const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Good morning",
                    style:// GoogleFonts.quicksand
                    TextStyle(
                      color:  Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    "Ankush",
                    style: //GoogleFonts.quicksand
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Color.fromRGBO(217, 217, 217, 1)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "CREATE TO DO LIST",
                    style: //GoogleFonts.quicksand
                    TextStyle(
                        color: const Color.fromRGBO(0, 0, 0, 1),
                        fontWeight: FontWeight.w500,
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40)),
                          color: Colors.white),
                      child: ListView.builder(
                          itemCount: carddata.length,
                          itemBuilder: (context, index) {
                            return Slidable(
                                closeOnScroll: true,
                                endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                editTask(carddata[index]);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                    89, 57, 241, 1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                deleteTask(carddata[index]);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(89,57,241, 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      ))
                                    ]),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 30),
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(38, 66, 42, 1),
                                        blurRadius: 7,
                                      )
                                    ],
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                              height: 52,
                                              width: 52,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 128, 124, 124),
                                                child: Image.asset(
                                                  "assets/task1.jpg",
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            carddata[index].date,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),

                                      //  title and desscreption coloum
                                      Expanded(
                                          child: Column(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                carddata[index].title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                  carddata[index]
                                                          .description,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                ));
                          }),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
