import 'package:flutter/material.dart';
import 'package:product/page/main_page/main_page_provider.dart';
import 'package:product/page/main_page/main_page_screen.dart';
import 'package:product/page/search_page/search_page_provider.dart';
import 'package:product/provider/crud_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchPageProvider()),
        ChangeNotifierProvider(create: (context) => MainPageProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPageScreen(),
    );
  }
}
