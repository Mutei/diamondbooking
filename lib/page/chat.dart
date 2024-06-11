import 'dart:io';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/private.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';

import '../constants/styles.dart';

class Chat extends StatefulWidget {
  String idEstate;
  String Name;
  String Key;

  Chat({required this.idEstate, required this.Name, required this.Key});
  @override
  _State createState() => new _State(idEstate, Name, Key);
}

class _State extends State<Chat> {
  final databaseReference = FirebaseDatabase.instance.reference();
  String idEstate;
  String Name;
  String Key;

  _State(this.idEstate, this.Name, this.Key);
  String? id = "";
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendNotificationsadmin',
      options: HttpsCallableOptions(timeout: Duration(seconds: 5)));
  final ValueNotifier<String> _messageNotifier = ValueNotifier<String>("");

  @override
  void initState() {
    id = FirebaseAuth.instance.currentUser?.uid;
    // Do something with the message and timestamp
    super.initState();
  }

  final TextEditingController _textController = TextEditingController();

  Future<String> getUserFullName(String userId) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App").child("User").child(userId);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      String firstName = snapshot.child("FirstName").value?.toString() ?? "";
      String secondName = snapshot.child("SecondName").value?.toString() ?? "";
      String lastName = snapshot.child("LastName").value?.toString() ?? "";
      return "$firstName $secondName $lastName";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference refChat = FirebaseDatabase.instance
        .ref("App")
        .child("Chat")
        .child(idEstate)
        .child(id!);

    DatabaseReference refChatList =
        FirebaseDatabase.instance.ref("App").child("ChatList").child(id!);

    void sendNotification(
        String? recipientToken, String title, String body) async {
      firebaseMessaging.requestPermission();

      try {
        var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
        var body = {
          'to': recipientToken,
          'notification': {"title": "test", "body": "test"}
        };

        var response = await http.post(url,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader: 'key=$chatApiKey'
            },
            body: jsonEncode(body));

        if (response.statusCode == 200) {
          print('Notification sent successfully!');
        } else {
          print(
              'Failed to send notification. Error code: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error sending notification: $e');
      }
    }

    void fetchPost(String title, String message) async {
      String? id = FirebaseAuth.instance.currentUser?.uid;
      try {
        final HttpsCallableResult result = await callable.call(
          <String, dynamic>{
            'userid': Key,
            'title': title,
            'message': message,
          },
        );
      } catch (e) {
        print('caught firebase functions exception');
        print('caught generic exception');
      }
    }

    void sendMessage(String message) async {
      _textController.clear();
      _messageNotifier.value = "";

      // Fetch full name before setting the data in refChatList
      String fullName = await getUserFullName(id!);

      refChat.push().set({
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'IDUser': id,
        'IDEstate': idEstate,
        'seen': "0",
        'Type': "2",
        'Name': fullName,
      });
      refChatList
          .child(idEstate)
          .set({"IDUser": id, "IDEstate": idEstate, "Name": Name});
      // Initialize Firebase Cloud Messaging
      String? token = await firebaseMessaging.getToken();
      final FirebaseMessaging x = FirebaseMessaging.instance;
      fetchPost('New Message For $Name', message);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            color: kPrimaryColor,
          ),
        ),
        centerTitle: true,
        iconTheme: kIconTheme,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: FirebaseAnimatedList(
              shrinkWrap: true,
              defaultChild: const Center(
                child: CircularProgressIndicator(),
              ),
              itemBuilder: (context, snapshot, animation, index) {
                Map map = snapshot.value as Map;
                map['Key'] = snapshot.key;
                return FutureBuilder<String>(
                  future: getUserFullName(map['IDUser']),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (asyncSnapshot.hasError || !asyncSnapshot.hasData) {
                      return Text('Error fetching user name');
                    }
                    String fullName = asyncSnapshot.data!;
                    return Column(
                      crossAxisAlignment: map['Type'] == "1"
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: map['Type'] == "1"
                                ? Colors.grey[300]
                                : kPrimaryColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 10),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                map['message'] ?? "",
                                style: TextStyle(
                                    color: map['Type'] == "1"
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 15.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              query: FirebaseDatabase.instance
                  .ref("App")
                  .child("Chat")
                  .child(idEstate)
                  .child(id!),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: const BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      _messageNotifier.value = text;
                    },
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        sendMessage(text);
                      }
                    },
                  ),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _messageNotifier,
                  builder: (context, value, child) {
                    return IconButton(
                      icon: Icon(Icons.send),
                      color: value.isEmpty ? Colors.grey : kPrimaryColor,
                      onPressed: value.isEmpty
                          ? null
                          : () {
                              sendMessage(_textController.text);
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
