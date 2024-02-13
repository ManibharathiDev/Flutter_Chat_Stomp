import 'dart:convert';
import 'package:chat_app/MyTextFile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dto/Users.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Flutter Demo',
      color: Colors.green.shade50,
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
    });

    if (!_userNamevalidate && !_nameValidate && !_profileNameValidate) {
      setState(() {
        isView = "LOADING";
      });
      Future<Users> saveResponse = register();
      saveResponse.whenComplete(() => Navigator.pop(context));
    }
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

      return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {

      throw Exception('Failed to register users.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          leading: const BackButton(),
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green.shade300,
          title: const Text(
            'New Registration',
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
          ),
        ),
        body: (isView == "NORMAL") ? _signUpWidget(context) : _loadingWidget());
  }

  Widget _signUpWidget(BuildContext context) {
    return (
        Center(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos.png',
                    alignment: Alignment.center,
                    height: 200,
                    width: 200,
                  ),
                  const Text(
                    'Signup',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 16, left: 32, right: 32, bottom: 16),
                    child: MyTextFile(controller: emailController, labelText: 'Email ID', obsCureText: false, validateText: _userNamevalidate,textInputAction: TextInputAction.next,)
                    // child: TextField(
                    //   decoration: InputDecoration(
                    //       errorText: _userNamevalidate ? "Value can't be empty" : null,
                    //       border: const OutlineInputBorder(),
                    //       labelText: 'Email ID',
                    //       hintText: 'Enter your username'),
                    //   controller: emailController,
                    // ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
                      child: MyTextFile(controller: nameController, labelText: 'Name of the User', obsCureText: false, validateText: _nameValidate,textInputAction: TextInputAction.next,)
                      // child: TextField(
                      //   decoration: InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: 'Name of the User',
                      //     errorText: _nameValidate ? "Value can't be empty" : null,
                      //   ),
                      //   controller: nameController,
                      // )
        ),
                  Padding(
                      padding: const EdgeInsets.only(left: 32, right: 32),
                      child: MyTextFile(controller: profileController, labelText: 'Profile Name', obsCureText: false, validateText: _profileNameValidate,textInputAction: TextInputAction.done,)
                      // child: TextField(
                      //   decoration: InputDecoration(
                      //     border: const OutlineInputBorder(),
                      //     labelText: 'Profile Name',
                      //     errorText: _profileNameValidate ? "Value can't be empty" : null,
                      //   ),
                      //   controller: profileController,
                      // )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                        onPressed: () {
                          _setData();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade300,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        child: const Text(
                          'Signup',
                          style:
                          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
            ),
          ),
        )

    );
  }

  Widget _loadingWidget() {
    return (const Center(
      child: CircularProgressIndicator(),
    ));
  }
}
