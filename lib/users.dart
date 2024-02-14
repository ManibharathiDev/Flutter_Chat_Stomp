import 'dart:convert';
import 'package:chat_app/chat_room.dart';
import 'package:chat_app/dto/Users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'models/ChatData.dart';

late StompClient stompClient;

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  static const String routeName = "/UserHome";

  @override
  State<StatefulWidget> createState() {
    return UsersState();
  }
}

class UsersState extends State<UserHome> {
  late Future<List<Users>> futureUsers;

  void onConnect(StompFrame frame) {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://10.10.3.16:8080/ws',
        onConnect: onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    stompClient.activate();

    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ChatData;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Online Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Users>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final posts = snapshot.data!;
            return buildPosts(posts, args);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String senderId = prefs.getString("SENDER_ID").toString();
    var url = Uri.parse("http://10.10.3.16:8080/view_users/$senderId");
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

Widget buildPosts(List<Users> users, ChatData args) {
  return ListView.builder(
    itemCount: users.length,
    itemBuilder: (context, index) {
      final user = users[index];

      return GestureDetector(
        onTap: () {
          ChatData chatData = ChatData(args.senderId, user.email);
          Navigator.pushNamed(context, ChatHome.routeName, arguments: chatData);
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      //backgroundImage: NetworkImage(widget.imageUrl),
                      maxRadius: 30,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user!.email,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
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
