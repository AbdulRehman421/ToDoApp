import 'package:flutter/material.dart';
import 'package:new_one/todolist.dart';
void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(colorScheme: ColorScheme.highContrastLight()),
      home : ToDoList(),
    );
  }
}
