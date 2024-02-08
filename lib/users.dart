import 'dart:convert';

import 'package:chat_app/chat_room.dart';
import 'package:chat_app/dto/Users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';



class MyUsers extends StatelessWidget {
  final String loginId;

  MyUsers({super.key, required this.loginId});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserHome(),
    );
  }
}

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<StatefulWidget> createState() {
    //return _HomeState();
    return _myUserState();
  }
}

class _myUserState extends State<UserHome> {
  // final String loginId;
  // MyUsers({super.key,required this.loginId});

  late Future<List<Users>> futureUsers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: Text(
          'Online Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Users>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final posts = snapshot.data!;
            return buildPosts(posts);
            //return Text(snapshot.data!.title);
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Future<List<Users>> fetchUsers() async {
    // final response = await http
    //     .get(Uri.parse('http://10.10.3.16:8080/view_users'));

    var url = Uri.parse("http://10.10.3.16:8080/view_users");
    final response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final List body = json.decode(response.body);
      log('response: $body');
      return body.map((e) => Users.fromJson(e)).toList();

      // If the server did return a 200 OK response,
      // then parse the JSON.
      //return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}

Widget buildPosts(List<Users> users) {



  return ListView.builder(
    itemCount: users.length,
    itemBuilder: (context, index) {
      final user = users[index];

      return GestureDetector(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("RECIPIENT_ID", user!.email);
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom())

          );
        },
        child: Container(
          padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      //backgroundImage: NetworkImage(widget.imageUrl),
                      maxRadius: 30,
                    ),
                    SizedBox(width: 16,),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(user!.email, style: TextStyle(fontSize: 16),),
                            SizedBox(height: 6,),
                            //Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Text(widget.time,style: TextStyle(fontSize: 12,fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
            ],
          ),
        ),
      );

      /*return GestureDetector(
        onTap: () async {
            log("Clicked ITem");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("RECIPIENT_ID", user!.email);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom())

            );
        },
        child: Container(
          color: Colors.grey.shade300,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          height: 50,
          width: double.maxFinite,
          child: Row(
            children: [
              // Expanded(flex: 1, child: Image.network(post.url!)),
              SizedBox(width: 5),
              Expanded(flex: 3, child: Text(user!.email,),),
            ],

          ),

        )
      );*/
      
    },
  );
}
