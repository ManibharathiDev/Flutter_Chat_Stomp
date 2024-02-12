
import 'package:http/http.dart' as http;

import 'package:chat_app/signup.dart';
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
      home: const Home(),
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
      prefs.setString('SENDER_ID', loginId);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyUsers(loginId: loginId)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Enter Your Email ID",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your username'),
                  controller: loginController,
                )),
            Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () {
                      _setText();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    child: const Text('Sign In',
                        style: TextStyle(
                          color: Colors.white,
                        )))),
            GestureDetector(
              onTap: () =>{
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Signup()))
              },
              child: const Text("Signup",

                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            )

          ],
        ),
      ),
    );
  }
}
