import 'package:chatapp/Helper/constants.dart';
import 'package:chatapp/Services/database.dart';
import 'package:chatapp/Widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomID;
  final String username;
  ConversationScreen(this.chatRoomID, this.username);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  Stream messageStream;
  String messageID = "";
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageTextEditingController =
      new TextEditingController();
  //Stream chatMessageStream;

  Widget chatMessageTitle(String message, bool sentByMe) {
    return Row(
      mainAxisAlignment:
          sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4.5),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.orange[700],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight:
                    sentByMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft:
                    sentByMe ? Radius.circular(24) : Radius.circular(0)),
          ),
          child: Text(
            message,
            style: simpleTextStyle(),
          ),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                padding: EdgeInsets.only(bottom: 80),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTitle(
                      ds["Message"], Constants.myName == ds["sentBy"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  sendMessage(bool sendClicked) {
    if (messageTextEditingController.text.isEmpty) {
      return null;
    }
    String message = messageTextEditingController.text;
    DateTime lastMessageTs = DateTime.now();

    Map<String, dynamic> messageMap = {
      "Message": messageTextEditingController.text,
      "sentBy": Constants.myName,
      "ts": lastMessageTs
    };
    if (messageID == "") {
      messageID = randomAlphaNumeric(12);
    }

    DatabaseMethods()
        .addMessage(widget.chatRoomID, messageID, messageMap)
        .then((val) {
      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": message,
        "lastMessageSentTs": lastMessageTs,
        "lastMessageSentBy": Constants.myName
      };
      DatabaseMethods()
          .updateLastMessageSent(widget.chatRoomID, lastMessageInfoMap);

      if (sendClicked) {
        // remove text in the message input field
        messageTextEditingController.text = "";
        //make message blank
        messageID = "";
      }
    });
  }

  getAndSetMessages() async {
    messageStream =
        await DatabaseMethods().getChatRoomMessages(widget.chatRoomID);
    setState(() {});
  }

  @override
  void initState() {
    getAndSetMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        centerTitle: false,
      ),
      body: Container(
        //padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageTextEditingController,
                          decoration: InputDecoration(
                            hintText: "Type a message",
                            hintStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage(true);
                        },
                        child: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  MessageTile(this.message);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(message, style: simpleTextStyle()),
    );
  }
}
