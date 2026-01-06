import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/editor_page.dart';
import 'pages/preview_page.dart';


void main() {
  runApp(const InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Generator',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
        ),
      ),

      initialRoute: '/',
     routes: {
  '/': (context) => HomePage(),
  '/editor': (context) => EditorPage(),
  '/preview': (context) => PreviewPage(),
},

    );
  }
}
