import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:chat_app/signup.dart';
import 'package:chat_app/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MyTextFile.dart';
import 'dto/Users.dart';

TextEditingController loginController = TextEditingController();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      SignupState.routeName: (BuildContext context) => const SignupState(),
    };

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
      routes: routes,
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
  String loginId = "No text is available";
  bool _userNamevalidate = false;
  bool _isLoading = false;

  Future<Users> auth() async {
    final response = await http.get(
        Uri.parse('http://10.10.3.16:8080/login/$loginId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      print("Login Success");

      return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to Login.');
    }
  }

  Future<void> _setText() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _userNamevalidate = loginController.text.isEmpty;
      loginId = loginController.text;

      if (!_userNamevalidate) {
        _isLoading = true;
        Future<Users> loginResponse = auth();
        loginResponse.then((value) {
          prefs.setString('SENDER_ID', loginId);
          _isLoading = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyUsers(loginId: loginId)));
        }).catchError((error)
        {
          print("User Not Found");
          _isLoading = false;
        });
      }
    });
  }

  Widget loginWidget() {
    return (Center(
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
                    hintText: 'Enter your username',
                    fillColor: Colors.grey,
                    filled: true),
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
            onTap: () => {
              Navigator.pushNamed(context, SignupState.routeName)

              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => SignupHome()))
            },
            child: const Text("Signup",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: (_isLoading)?_loadingWidget():loginUI(),
      ),
    );
  }

  Widget loginUI() {
    return (Center(
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logos.png',
            alignment: Alignment.center,
            height: 200,
            width: 200,
          ),
          Container(
            margin: const EdgeInsets.only(left: 32, right: 32),
            child: Column(
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 25),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 0),
                    child: MyTextFile(
                      controller: loginController,
                      labelText: 'User Email',
                      obsCureText: false,
                      validateText: _userNamevalidate,
                      textInputAction: TextInputAction.done,
                    )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                    ),
                    onPressed: () => {_setText()},
                    child: const Text('Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      {Navigator.pushNamed(context, SignupState.routeName)},
                  child: const Text("Signup",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                )
              ],
            ),
          )
        ],
      )),
    ));
  }

  Widget _loadingWidget() {
    return (const Center(
      child: CircularProgressIndicator(),
    ));
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.green.shade800;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height / 2, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
