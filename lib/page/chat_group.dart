// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/private.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';

class ChatGroup extends StatefulWidget {
  String idEstate;
  String Name;
  String Key;
  ChatGroup({required this.idEstate, required this.Name, required this.Key});
  @override
  _State createState() => new _State(idEstate, Name, Key);
}

class _State extends State<ChatGroup> {
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

    DatabaseReference refChat =
        FirebaseDatabase.instance.ref("App").child("ChatGroup").child(idEstate);

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
              HttpHeaders.authorizationHeader: 'key=$chatGroupApiKey'
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
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String name = sharedPreferences.getString("Name")!;
      refChat.push().set({
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'IDUser': id,
        'IDEstate': idEstate,
        'Name': name,
        'seen': "0",
        'Type': "2"
      });

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
                  return Card(
                    color: Color(0xFF84A5FA),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Wrap(
                      children: [
                        Container(
                          height: 98,
                          width: MediaQuery.of(context).size.width,
                          // ignore: prefer_const_constructors
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          margin: EdgeInsets.only(left: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(map['Name']),
                                      Text(map['message']),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 22.0),
                                child: TextButton(
                                  onPressed: () {
                                    //some logic
                                  },
                                  child: Text(''),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                query: FirebaseDatabase.instance
                    .ref("App")
                    .child("ChatGroup")
                    .child(idEstate)),
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
