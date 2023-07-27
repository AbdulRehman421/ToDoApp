import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'addlist.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  bool isLoading = true;
  List items = [];
  void initState(){
    super.initState();
    fetchData();
    getConnectivity();
  }
  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
              (connectivityResult)async {
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if(!isDeviceConnected && isAlertSet == false){
              showDialogBox();
              setState(() {
                isAlertSet =true;
              });
            }
          });

  void dispose(){
    subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(

        appBar: AppBar(
          title: Text("ToDoList"),
          centerTitle: true,
          leading: IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoList(),));
          }, icon: Icon(Icons.refresh)),
        ),
        body: Visibility(
          visible: isLoading,
          child  : Center(
            child : CircularProgressIndicator(),
          ),
          replacement: RefreshIndicator(
            onRefresh: fetchData,
            child: Visibility(
              visible: items.isNotEmpty,
              replacement: Center(
                child: Text('No ToDo Items', style: Theme.of(context).textTheme.headlineLarge,),
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items [index];
                  final id = item['_id'] as String;
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      leading: CircleAvatar(child: Text("${index + 1}")),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit'){
                            navigateToEditPage(item);
                          }else if(value == 'delete'){
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return[
                            PopupMenuItem(child: Text('Edit'),value: 'edit'),
                            PopupMenuItem(child: Text('Delete'),value: 'delete',),
                          ];
                        },),
                    ),
                  );
                },),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(onPressed: () async {

          Navigator.push(context, MaterialPageRoute(builder: (context) => AddToDo()));
        }, label: Text("AddTodo")),
      ),
    );
  }
  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddToDo(todo : item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;

    });
    fetchData();
  }
  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context) => AddToDo(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;

    });
    fetchData();
  }
  Future<void> deleteById(String id) async{
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
        showSucessMessage('Deleted');
      });
    } else{
      showErrorMessage('Deletion Failed');
    }

  }
  Future<void> fetchData()async{
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode ==200){
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
  void showSucessMessage(String message){
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  void showErrorMessage(String message){
    final snackbar = SnackBar(content: Text(message),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  showDialogBox() =>showCupertinoDialog(context: context, builder: (BuildContext context) => CupertinoAlertDialog(
    title: Text('No Internet Connection'),
    content: Text('Plese Check Your Internet Connection'),
    actions: [
      TextButton(onPressed: () async {
        // Navigator.pop(context, MaterialPageRoute(builder: (context) => ToDoList(),));
        // Navigator.pop(context);
        // Navigator.of(context);
        Navigator. of(context). pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoList(),));
        setState(() {
          isAlertSet = false;

        });
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if(!isDeviceConnected){
          showDialogBox();
          setState(() {
            isAlertSet = false;
          });
        }
      }, child: Text('OK'))
    ],
  ) ,
  );


}
