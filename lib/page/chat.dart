// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:diamond_booking/constants/colors.dart';
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

  @override
  void initState() {
    id = FirebaseAuth.instance.currentUser?.uid;
    // Do something with the message and timestamp
    super.initState();
  }

  final TextEditingController _textController = TextEditingController();

  Widget build(BuildContext context) {
    //
    // final objProvider = Provider.of<GeneralProvider>(context, listen: false);

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
              HttpHeaders.authorizationHeader:
              'key=AAAAzq_Non8:APA91bHuc2TOrD5Tca_Pyb5AfZ6fCkd4Rz0642C2g3DJFnSQX6cpf4lFH65WjWOUEESJH5qqO_VGJ_c-1de48lk5NQ8MofERtPQX1qzobWoi4Xc8W0DTvk5YWxt7b8zUqnPJ4ELP5-X5'
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

      refChat.push().set({
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'IDUser': id,
        'IDEstate': idEstate,
        'seen': "0",
        'Type': "2"
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
        title: Text('Chat'),
        backgroundColor: const Color(0xFF84A5FA),
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
                return Row(
                  mainAxisAlignment: map['Type'] == "1"
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: map['Type'] == "1"
                            ? Colors.grey[300]
                            : kPrimaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // ignore: prefer_const_constructors
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: Text(
                        map['message'] ?? "",
                        style: TextStyle(
                            color: map['Type'] == "1"
                                ? Colors.black
                                : Colors.white,
                            fontSize: 15.0),
                      ),
                    ),
                  ],
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
            // ignore: prefer_const_constructors
            decoration: BoxDecoration(
              // ignore: prefer_const_constructors
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
                    // ignore: prefer_const_constructors
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: kPrimaryColor,
                  onPressed: () {
                    sendMessage(_textController.text);
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
