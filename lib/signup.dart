import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dto/Users.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignupState(),
    );
  }
}

class SignupState extends StatefulWidget {
  static const String routeName = "/SignupState";

  const SignupState({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignupHome();
  }
}

class SignupHome extends State<SignupState> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final profileController = TextEditingController();

  String isView = "NORMAL";

  String email = "";
  String name = "";
  String profile = "";

  bool _userNamevalidate = false;
  bool _nameValidate = false;
  bool _profileNameValidate = false;

  late Future<Users> saveResponse;

  void _setData() {
    setState(() {
      _userNamevalidate = emailController.text.isEmpty;
      _nameValidate = nameController.text.isEmpty;
      _profileNameValidate = profileController.text.isEmpty;

      email = emailController.text;
      name = nameController.text;
      profile = profileController.text;

      isView = "LOADING";
    });
    Future<Users> saveResponse = register();
    saveResponse.whenComplete(() => Navigator.pop(context));
  }

  Future<Users> register() async {
    final response = await http.post(
      Uri.parse('http://10.10.3.16:8080/add_user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'profileName': profile,
        'name': name,
        'email': email
      }),
    );

    if (response.statusCode == 201) {
      print("user created");

      setState(() {
        emailController.text = "";
        nameController.text = "";
        profileController.text = "";
        isView = "NORMAL";
      });

      //final responseData = jsonDecode(response.body);

      return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to register users.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          // actions: [
          //   IconButton(
          //       icon: Icon(
          //           Icons.login,
          //           color: const Color(0xFF0000FF),
          //           size: 34.0),
          //       onPressed: (){}
          //   ),
          //   IconButton(
          //       icon: Icon(
          //           Icons.favorite,
          //           color: const Color(0xFFFF0000),
          //           size: 34.0),
          //       onPressed: (){}
          //   ),
          //   IconButton(
          //       icon: Icon(
          //           Icons.settings,
          //           color: const Color(0xFF00FF00),
          //           size: 34.0),
          //       onPressed: (){}
          //   ),
          // ],
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const Text(
            'New Registration',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: (isView == "NORMAL") ? _signUpWidget(context) : _loadingWidget());
  }

  Widget _signUpWidget(BuildContext context) {
    return (Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: Text(
            "Enter Your Email ID",
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: TextField(
            decoration: InputDecoration(
                errorText: _userNamevalidate ? "Value can't be empty" : null,
                border: const OutlineInputBorder(),
                hintText: 'Enter your username'),
            controller: emailController,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: Text(
            "Enter Your Name",
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Your Name',
                errorText: _nameValidate ? "Value can't be empty" : null,
              ),
              controller: nameController,
            )),
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: Text(
            "Enter Your Profile Name",
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Profile Name',
                errorText: _profileNameValidate ? "Value can't be empty" : null,
              ),
              controller: profileController,
            )),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
              onPressed: () {
                _setData();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              child: const Text(
                'Signup',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        )
      ],
    ));
  }

  Widget _loadingWidget() {
    return (const Center(
      child: CircularProgressIndicator(),
    ));
  }
}
