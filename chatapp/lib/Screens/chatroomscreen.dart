import 'package:chatapp/Helper/authenticate.dart';
import 'package:chatapp/Helper/constants.dart';
import 'package:chatapp/Helper/helperfunctions.dart';
import 'package:chatapp/Screens/search.dart';
import 'package:chatapp/Services/auth.dart';
import 'package:chatapp/Services/database.dart';
import 'conversationScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/Widgets/widgets.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  Stream chatRoomStream;

  @override
  void initState() {
    doAtStart();
    super.initState();
  }

  doAtStart() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 7),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatRoomTile(
                        ds.id
                            .replaceAll(Constants.myName, "")
                            .replaceAll("_", ""),
                        ds["lastMessage"],
                        ds["chatroomID"],
                        (ds["lastMessageSentTs"] as Timestamp).toDate());
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget chatRoomTile(String name, String lastMessage, String chatroomID,
      DateTime lastMessageSentTs) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatroomID, name)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900],
            border:
                Border(bottom: BorderSide(color: Colors.white, width: 0.5))),
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(name,
                        style: TextStyle(color: Colors.white, fontSize: 25))),
                SizedBox(width: 5.0),
                DateTime.now().day == lastMessageSentTs.day
                    ? Text("Today", style: simpleTextStyle())
                    : Text(
                        (lastMessageSentTs.day.toString() +
                            "-" +
                            lastMessageSentTs.month.toString() +
                            "-" +
                            lastMessageSentTs.year.toString()),
                        style: simpleTextStyle(),
                      ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(lastMessage,
                      style: TextStyle(color: Colors.white60, fontSize: 15)),
                ),
                Text(
                  (lastMessageSentTs.hour.toString() +
                      ":" +
                      lastMessageSentTs.minute.toString()),
                  style: simpleTextStyle(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  signOut() {
    HelperFunctions.saveUserLoggedInSharedPreference(false);
    authMethods.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Authenticate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat app"),
        elevation: 0.0,
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              signOut();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.exit_to_app)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(),
            ),
          );
        },
      ),
      body: chatRoomsList(),
    );
  }
}
