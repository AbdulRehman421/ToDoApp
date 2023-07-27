import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_one/todolist.dart';
class AddToDo extends StatefulWidget {
  final Map? todo;
   AddToDo({super.key, this.todo, });

  @override
  State<AddToDo> createState() => _AddToDoState();
}

class _AddToDoState extends State<AddToDo> {
  @override
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  void initState(){
    super.initState();
    final todo = widget.todo;
    if(widget.todo != null){
      isEdit = true;
      final title = todo?['title'];
      final description = todo?['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit To Do" : "Add To DO",

      ),),
    body: Form(
      key: _formKey,
      child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                },
                controller: titleController,
          decoration: InputDecoration(hintText: "Title"),
      ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                },
                controller: descriptionController,
                decoration: InputDecoration(
                hintText: "Description"
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 8,
                minLines: 5,
              ),
            ),
            SizedBox(height: 20,),
            Container(
              height: 40,
padding: EdgeInsets.only(right: 50,left: 50),
              child: ElevatedButton(
              //     onPressed: () {
              // isEdit? UpdateData() :  submitData();
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoList(),));
              // },
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Processing Data')),
                      // );
                      isEdit? UpdateData() :  submitData();
                      Navigator.of(context).pop();                        // Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoList(),));

                    }
                  },
                  child: Text(isEdit ? "Update" : "Submit",style: TextStyle(fontSize: 20),)),
            )
        ],
      ),
    ),
    );
  }
 Future <void> UpdateData() async {
    final todo = widget.todo;
    if(todo == null){
      print('You can not update todo without data');
      return;
    }
    final id = todo['_id'];
   final title = titleController.text;
   final description = descriptionController.text;
   final body = {
     "title": title,
     "description": description,
     "is_completed": false
   };


   final url = "https://api.nstack.in/v1/todos/$id";
   final uri = Uri.parse(url);
   final response = await http.put(uri,
       body: jsonEncode(body),
       headers: {'Content-Type' : 'application/json'}
   );
    if (response.statusCode == 200){
      showSucessMessage('Update Sucess');
    }
    else{
      showErrorMessage('Update failed');
      print(response.body);
    }
 }

    Future <void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body),
    headers: {'Content-Type' : 'application/json'}
    );
  if (response.statusCode == 201){
    showSucessMessage('Creation Sucess');
  }
  else{
    showErrorMessage('Creation failed');
    print(response.body);
  }
  }
  void showSucessMessage(String message){
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  void showErrorMessage(String message){
    final snackbar = SnackBar(content: Text(message),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
