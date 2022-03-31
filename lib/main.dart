import 'package:flutter/material.dart';
import 'package:notes/database/database_provider.dart';
import 'package:notes/model/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserModel> userList = [];
  String? title, note;
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  bool isNew = false;

  Future<List<UserModel>> getData() async {
    userList = await DatabaseProvider.instance.readAllElements();
    return userList.isEmpty ? [] : userList;
  }

  addNote() {
    key.currentState?.save();
    DatabaseProvider.instance.createUser(UserModel(
      title: title,
      note: note,
    ));
    Navigator.pop(context);
    setState(() {});
  }

  editNote(int id) {
    key.currentState?.save();
    DatabaseProvider.instance.updateUser(UserModel(
      id: id,
      title: title,
      note: note,
    ));

    Navigator.pop(context);
    setState(() {
      isNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Note',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
      floatingActionButton: buildFloatingActionButton(),
      body: getAllUser(),
    );
  }

  buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => openAlertBox(),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }

  getAllUser() {
    return FutureBuilder<List<UserModel>>(
        future: getData(),
        builder: (context, snapshot) {
          return createListView(context, snapshot);
        });
  }

  createListView(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      userList = snapshot.data;
    }

    return userList.isNotEmpty
        ? ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      'Delete',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onDismissed: (direction) =>
                    DatabaseProvider.instance.deleteUser(userList[index].id),
                child: _buildItem(userList[index], index),
              );
            })
        : const Center(
            child: Text(
        'data is empty',
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
          ));
  }

  _buildItem(UserModel model, int index) {
    return ListTile(
      title: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Text(
                  model.title!.isNotEmpty
                      ? model.title!.substring(0, 1).toUpperCase()
                      : '',
                  style: const TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Padding(padding: EdgeInsets.only(right: 10)),
                  Text(
                    model.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Padding(padding: EdgeInsets.only(right: 10)),
                  Text(
                    model.note!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _onEdit(model, index),
        icon: const Icon(Icons.edit),
      ),
    );
  }

  _onEdit(UserModel model, int index) {
    openAlertBox(model: model);
  }

  openAlertBox({UserModel? model}) {
    if (model != null) {
      title = model.title;
      note = model.note;
      isNew = true;
    } else {
      title = '';
      note = '';
      isNew = false;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              height: 150,
              child: Form(
                key: key,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: title,
                      decoration: InputDecoration(
                        hintText: 'Add Title',
                        fillColor: Colors.grey[300],
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (String? value) {
                        title = value;
                      },
                    ),
                    TextFormField(
                      initialValue: note,
                      decoration: InputDecoration(
                        hintText: 'Add Note',
                        fillColor: Colors.grey[300],
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (String? value) {
                        note = value;
                      },
                    ),
                    TextButton(
                      onPressed: () => isNew ? editNote(model!.id!) : addNote(),
                      child: Text(isNew ? 'Edit Note' : 'Add Note'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
