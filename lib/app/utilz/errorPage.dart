import 'package:flutter/material.dart';

class errorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text("terjadi kesalahan"),
        ),
      ),
    );
  }
}
