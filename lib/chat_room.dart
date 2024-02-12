import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dto/Chat.dart';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

late String senderId;
late String recipientId;

class ChatRoom extends StatelessWidget {
  const ChatRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatHome(),
    );
  }
}

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _myChatState();
  }
}

class _myChatState extends State<ChatHome> {
  final chatController = TextEditingController();
  String chatMessage = "";
  late StompClient stompClient;

  late Future<List<Chats>> futureChats;
  late List<Chats> chats;
  ScrollController _scrollController = new ScrollController();

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
      destination: '/user/public',
      headers: {},
      callback: (frame) {
        dynamic result = json.decode(frame.body!);

      },
    );

    String receiveURL = '/user/$senderId/queue/messages';
    print("URL is $receiveURL");

    stompClient.subscribe(
        destination: receiveURL,
        headers: {},
        callback: (frame) {

          dynamic data = Chats.fromJson(json.decode(frame.body!));
           Chats chat = Chats(id: data.id, senderId: data.senderId, recipientId: data.recipientId, message: data.message);
          setState(() {
            chats.add(chat);
          });
          if (_scrollController.hasClients) {
            final position = _scrollController.position.maxScrollExtent;
            _scrollController.jumpTo(position);
          }
        });

  }

  void setMessage() {
    setState(() {
      chatMessage = chatController.text;
      Chats chat = Chats(id: 0, senderId: senderId, recipientId: recipientId, message: chatMessage);
      chats.add(chat);
      sendChat(senderId,recipientId,chatMessage);


      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(position);
      }
      chatController.text = "";

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPref();
    futureChats = fetchChats();

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
  }

  _loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    senderId = prefs.getString("SENDER_ID").toString();
    setState(() {
      recipientId = prefs.getString("RECIPIENT_ID").toString();
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    //Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                const CircleAvatar(
                  //backgroundImage: NetworkImage("<https://randomuser.me/api/portraits/men/5.jpg>"),
                  maxRadius: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        recipientId,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FutureBuilder<List<Chats>>(
                future: futureChats,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final posts = snapshot.data!;
                    chats = snapshot.data!;


                     return buildChats(posts, "test");

                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return const CircularProgressIndicator();
                },
              )),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      controller: chatController,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setMessage();
                    },
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Chats> sendChat(String senderId,String recipientId,String message) async {
    final response = await http.post(
      Uri.parse('http://10.10.3.16:8080/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'senderId': senderId,
        'recipientId':recipientId,
        'message':message
      }),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return Chats.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create Chats.');
    }
  }

  Future<List<Chats>> fetchChats() async {
    // final response = await http
    //     .get(Uri.parse('http://10.10.3.16:8080/view_users'));

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // senderId = prefs.getString("SENDER_ID").toString();
    // recipientId = prefs.getString("RECIPIENT_ID").toString();

    log("Sender ID $senderId");
    log("Recipient ID $recipientId");
    var url =
        Uri.parse("http://10.10.3.16:8080/message/$senderId/$recipientId");
    log("API URL $url");
    final response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final List body = json.decode(response.body);
      log('response: $body');
      return body.map((e) => Chats.fromJson(e)).toList();

      // If the server did return a 200 OK response,
      // then parse the JSON.
      //return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Widget buildChats(List<Chats> data,String s) {

    return ListView.builder(
      itemCount: chats.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        final chat = chats[index];

        return Container(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (chat.senderId == senderId
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (chat.senderId == senderId
                    ? Colors.grey.shade200
                    : Colors.blue[200]),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                chat.message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}
