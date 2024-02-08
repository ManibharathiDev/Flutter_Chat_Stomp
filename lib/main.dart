import 'dart:math';

import 'package:chat_app/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    //return _HomeState();
    return _myHomeState();
  }
}

class _myHomeState extends State<Home> {
  final loginController = TextEditingController();
  String loginId = "No text is available";

  Future<void> _setText() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      loginId = loginController.text;
      prefs.setString('SENDER_ID',loginId);
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyUsers(loginId: loginId))

      );
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Enter your email id",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your username'),
                  controller: loginController,
                )),
            Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () {
                      _setText();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    child: Text('Sign In',
                        style: TextStyle(
                          color: Colors.white,
                        ))))
          ],
        ),
      ),
    );
  }
}
