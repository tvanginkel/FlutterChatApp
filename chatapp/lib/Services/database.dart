import 'package:chatapp/Helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Username", isEqualTo: username)
        .get();
  }

  getUserByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection("users").add(userMap);
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future addMessage(String chatRoomID, String messageID, Map messageMap) async {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("Chats")
        .doc(messageID)
        .set(messageMap);
  }

  updateLastMessageSent(String chatRoomID, Map lastMessageSent) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .update(lastMessageSent);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(String chatRoomID) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("Chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myName = await HelperFunctions.getUserNameSharedPreference();
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .orderBy("lastMessageSentTs", descending: true)
        .where("users", arrayContains: myName)
        .snapshots();
  }
}
