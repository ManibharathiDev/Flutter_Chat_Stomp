import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dto/Chat.dart';

import 'package:stomp_dart_client/parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_exception.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:stomp_dart_client/stomp_parser.dart';

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
      home: ChatHome(),
    );
  }
}

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<StatefulWidget> createState() {
    //return _HomeState();
    return _myChatState();
  }
}



class _myChatState extends State<ChatHome> {

  final chatController = TextEditingController();
  String chatMessage = "";
  late StompClient stompClient;

  late Future<List<Chats>> futureChats;



  void onConnect(StompFrame frame)
  {
    print('connected...');
    stompClient.subscribe(
      destination: '/user/public',
      callback: (frame) {
        print(frame);
        print(frame.body);
        dynamic result = json.decode(frame.body!);
        print(result);
      },
    );

    // Timer.periodic(const Duration(seconds: 10), (_) {
    //   stompClient.send(
    //     destination: '/app/test/endpoints',
    //     body: json.encode({'a': 123}),
    //   );
    // });
  }

  void setMessage(){
    setState(() {
      chatMessage = chatController.text;
    });
    log("message $chatMessage");
  }


  // late SharedPreferences prefs;
  //
  // Future<void> getPrefs()
  // async {
  //   prefs = await SharedPreferences.getInstance();
  // }

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
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        //stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
        //webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
      ),
    );
    stompClient.activate();

  }

  _loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recipientId = prefs.getString("RECIPIENT_ID").toString();
    });

    // setState(() {
    //   senderId = prefs.getString("SENDER_ID").toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    //getPrefs();
    // TODO: implement build
    return Scaffold(
       appBar:
       AppBar(
         elevation: 0,
         automaticallyImplyLeading: false,
         backgroundColor: Colors.white,
         flexibleSpace: SafeArea(
           child: Container(
             padding: EdgeInsets.only(right: 16),
             child: Row(
               children: <Widget>[
                 IconButton(
                   onPressed: ()
                   {
                     //Navigator.pop(context);
                   },
                   icon: Icon(Icons.arrow_back,color: Colors.black,),
                 ),
                 SizedBox(width: 2,),
                 CircleAvatar(
                   //backgroundImage: NetworkImage("<https://randomuser.me/api/portraits/men/5.jpg>"),
                   maxRadius: 20,
                 ),
                 SizedBox(width: 12,),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: <Widget>[
                       Text(recipientId,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                       SizedBox(height: 6,),
                       Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                     ],
                   ),
                 ),
                 Icon(Icons.settings,color: Colors.black54,),
               ],
             ),
           ),
         ),
       ),
      // AppBar(
      //   backgroundColor: Colors.red.shade900,
      //   title: Text(
      //     recipientId,
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      body:
      Stack(
        children: <Widget>[

          Padding(padding: EdgeInsets.only(bottom:70),
          child: FutureBuilder<List<Chats>>(
            future: futureChats,

            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final posts = snapshot.data!;
                return buildChats(posts, "test");
                //return Text(snapshot.data!.title);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          )
          )
          ,
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 20, ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none
                      ),
                      controller: chatController,
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: (){
                      setMessage();
                    },
                    child: Icon(Icons.send,color: Colors.white,size: 18,),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],

              ),
            ),
          )

        ],
      ),


    );
  }

  Future<List<Chats>> fetchChats() async {
    // final response = await http
    //     .get(Uri.parse('http://10.10.3.16:8080/view_users'));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    senderId = prefs.getString("SENDER_ID").toString();
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

  Widget buildChats(List<Chats> chats, String s) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];

        return Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
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
              padding: EdgeInsets.all(16),
              child: Text(
                chat.message,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}
