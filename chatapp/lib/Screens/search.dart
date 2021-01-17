import 'package:chatapp/Screens/conversationScreen.dart';
import 'package:chatapp/Services/database.dart';
import 'package:chatapp/Widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/Helper/constants.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController =
      new TextEditingController();

  QuerySnapshot searchSnapshot;

  initiateSearch() {
    databaseMethods
        .getUserByUsername(searchTextEditingController.text)
        .then((val) {
      setState(() {
        print(val);
        searchSnapshot = val;
      });
    });
  }

  createChatroomAndStartConversation({String username}) {
    String chatRoomID = getChatRoomID(username, Constants.myName);
    List<String> users = [username, Constants.myName];
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatroomID": chatRoomID
    };
    databaseMethods.createChatRoom(chatRoomID, chatRoomMap);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConversationScreen(chatRoomID, username)),
    );
  }

  Widget SearchTile({String userName, String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange, width: 2.5)),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Column(
              children: [
                Text(userName, style: simpleTextStyle()),
                Text(userEmail, style: simpleTextStyle()),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                createChatroomAndStartConversation(username: userName);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 19, vertical: 12),
                child: Text("Message"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return searchSnapshot.docs[index].data()["Username"] ==
                      Constants.myName
                  ? null
                  : SearchTile(
                      userName: searchSnapshot.docs[index].data()["Username"],
                      userEmail: searchSnapshot.docs[index].data()["Email"],
                    );
            })
        : Container();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchTextEditingController,
                      decoration: InputDecoration(
                        hintText: "Search username",
                        hintStyle: TextStyle(color: Colors.black),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Icon(Icons.person_search),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            searchList()
          ],
        ),
      ),
    );
  }
}

getChatRoomID(String a, String b) {
  if (a.compareTo(b) > 0) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
