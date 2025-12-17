import 'package:flutter/material.dart';
import 'package:get/get.dart';
// FIX: Import from the view folder
import 'view/error_search_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Error Code Lookup',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: ErrorSearchView(),
    );
  }
}
