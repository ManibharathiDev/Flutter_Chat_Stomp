import 'dart:ffi';

class Chats {
  late int id;

  //private String chatId; // ChatRoom chatId
  //late Date createdAt;
  late String senderId;
  late String recipientId;
  late String message;

  Chats(
      {required this.id,
      required this.senderId,
      required this.recipientId,
      required this.message});

  factory Chats.fromJson(Map<String, dynamic> addjson) {
    return Chats(
        id: addjson["id"],
        senderId: addjson["senderId"],
        recipientId: addjson["recipientId"],
        message: addjson["message"]);
  }

  static Map<String, dynamic> toJson(Chats value) =>
      {'id': value.id, 'senderId': value.senderId,'recipientId':value.recipientId,'message':value.message};
}
