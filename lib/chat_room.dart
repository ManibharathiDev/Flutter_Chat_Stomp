import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dto/Chat.dart';

import 'package:stomp_dart_client/stomp_frame.dart';

import 'dto/Users.dart';
import 'models/ChatData.dart';

late String senderId;
late String recipientId;

late ChatData chatData;

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  static const String routeName = "/ChatHome";

  @override
  State<StatefulWidget> createState() {
    return MyChatState();
  }
}

class MyChatState extends State<ChatHome> {
  final chatController = TextEditingController();
  String chatMessage = "";
  String userStatus = "offline";

  // late StompClient stompClient;

  late Future<List<Chats>> futureChats;
  late Future<Users> futureUserStatus;
  late List<Chats> chats;
  final ScrollController _scrollController = ScrollController();

  void onConnects() {
    stompClient.subscribe(
        destination: '/user/${chatData.recipientId}/status',
        headers: {},
        callback: (frame) {
          dynamic data = Users.fromJson(json.decode(frame.body!));
          Users user = Users(
              id: data.id,
              profileName: data.profileName,
              name: data.name,
              status: data.status,
              email: data.email);
          setState(() {
            userStatus = (user.status == 1) ? "Online" : "Offline";
          });
        });

    stompClient.subscribe(
      destination: '/user/public',
      headers: {},
      callback: (frame) {
        dynamic data = Users.fromJson(json.decode(frame.body!));
        print('Public status Received');
        Users user = Users(
            id: data.id,
            profileName: data.profileName,
            name: data.name,
            status: data.status,
            email: data.email);
        setState(() {
          if (chatData.recipientId == user.email)
          {
            userStatus = (user.status == 1) ? "Online" : "Offline";
          }
        });
      },
    );

    stompClient.subscribe(
      destination: '/user/disconnect',
      headers: {},
      callback: (frame) {
        dynamic data = Users.fromJson(json.decode(frame.body!));
        print('Public status Received');
        Users user = Users(
            id: data.id,
            profileName: data.profileName,
            name: data.name,
            status: data.status,
            email: data.email);
        setState(() {
          if (chatData.recipientId == user.email) {
            userStatus = (user.status == 1) ? "Online" : "Offline";
          }
        });
      },
    );

    String receiveURL = '/user/${chatData.senderId}/queue/messages';
    print("URL is $receiveURL");

    stompClient.subscribe(
        destination: receiveURL,
        headers: {},
        callback: (frame) {
          dynamic data = Chats.fromJson(json.decode(frame.body!));
          Chats chat = Chats(
              id: data.id,
              senderId: data.senderId,
              recipientId: data.recipientId,
              message: data.message);
          setState(() {
            chats.add(chat);
          });
          if (_scrollController.hasClients) {
            final position = _scrollController.position.maxScrollExtent;
            _scrollController.jumpTo(position);
          }
        });
  }

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
      destination: '/user/public',
      headers: {},
      callback: (frame) {
        dynamic result = json.decode(frame.body!);
      },
    );

    String receiveURL = '/user/${chatData.senderId}/queue/messages';
    print("URL is $receiveURL");

    stompClient.subscribe(
        destination: receiveURL,
        headers: {},
        callback: (frame) {
          dynamic data = Chats.fromJson(json.decode(frame.body!));
          Chats chat = Chats(
              id: data.id,
              senderId: data.senderId,
              recipientId: data.recipientId,
              message: data.message);
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
      Chats chat = Chats(
          id: 0,
          senderId: chatData.senderId,
          recipientId: chatData.recipientId,
          message: chatMessage);
      chats.add(chat);
      sendChat(chatMessage);

      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(position);
      }
      chatController.text = "";
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setState(() {
      chatData = ModalRoute.of(context)!.settings.arguments as ChatData;
    });
    if (stompClient.connected && stompClient.isActive) {
      onConnects();
    } else {
      print('Stomp Client not available');
    }

    fetchUserStatus(chatData.recipientId);
  }

  @override
  void initState() {
    super.initState();

    print("Connection Status => ${stompClient.connected}");

    print("Active Status => ${stompClient.isActive}");

    // if (stompClient.connected && stompClient.isActive) {
    //   onConnects();
    // } else {
    //   print('Stomp Client not available');
    // }
    //futureChats = fetchChats();
    /*stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://10.10.3.16:8080/ws',
        onConnect: onConnect,
        beforeConnect: () async {

          await Future.delayed(const Duration(milliseconds: 200));

        },
        onWebSocketError: (dynamic error) => print(error.toString()),

      ),
    );
    stompClient.activate();*/
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   chatData = ModalRoute.of(context)!.settings.arguments as ChatData;
    // });

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
                    Navigator.pop(context);
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
                        chatData.recipientId,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        userStatus,
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
                future: fetchChats(),
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

  Future<Users> fetchUserStatus(String email) async {
    var url = Uri.parse("http://10.10.3.16:8080/user/status/$email");
    log("API URL $url");
    final response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      Users users =
          Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      if (users.status == 1) {
        setState(() {
          userStatus = "Online";
        });
      } else {
        setState(() {
          userStatus = "Offline";
        });
      }
      return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<Chats> sendChat(String message) async {
    final response = await http.post(
      Uri.parse('http://10.10.3.16:8080/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'senderId': chatData.senderId,
        'recipientId': chatData.recipientId,
        'message': message
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
    var url = Uri.parse(
        "http://10.10.3.16:8080/message/${chatData.senderId}/${chatData.recipientId}");
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

  Widget buildChats(List<Chats> data, String s) {
    return ListView.builder(
      itemCount: chats.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        final chat = chats[index];

        return Container(
          padding:
              const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (chat.senderId == chatData.senderId
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (chat.senderId == chatData.senderId
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
