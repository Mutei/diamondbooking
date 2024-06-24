import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/page/qrViewScan.dart';
import 'package:diamond_booking/private.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/styles.dart';
import '../global/censor_message.dart';
import '../resources/user_services.dart';

class Chat extends StatefulWidget {
  final String idEstate;
  final String Name;
  final String Key;

  Chat({required this.idEstate, required this.Name, required this.Key});

  @override
  _State createState() => new _State(idEstate, Name, Key);
}

class _State extends State<Chat> {
  final databaseReference = FirebaseDatabase.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<String> _messageNotifier = ValueNotifier<String>("");
  final ValueNotifier<int> _charCountNotifier = ValueNotifier<int>(0);

  String idEstate;
  String Name;
  String Key;
  String? id = "";
  User? currentUser;
  bool hasAccess = false;
  Timer? accessTimer;
  String userType = "1";

  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendNotificationsadmin',
      options: HttpsCallableOptions(timeout: Duration(seconds: 5)));

  _State(this.idEstate, this.Name, this.Key);

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser?.uid;
    currentUser = UserService().getCurrentUser();
    fetchUserType();
  }

  @override
  void dispose() {
    accessTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserType() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DatabaseReference userTypeRef =
            databaseReference.ref().child('App/User/$uid/TypeUser');
        DataSnapshot snapshot = await userTypeRef.get();
        if (snapshot.exists) {
          setState(() {
            userType = snapshot.value.toString();
            if (userType == "2") {
              hasAccess = true;
            } else {
              checkAccess();
            }
          });
        }
      }
    } catch (e) {
      print("Failed to fetch user type: $e");
    }
  }

  Future<void> checkAccess() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String accessTimeKey = 'access_time_$idEstate';
    String? accessEndTimeString = sharedPreferences.getString(accessTimeKey);

    if (accessEndTimeString != null) {
      DateTime accessEndTime = DateTime.parse(accessEndTimeString);
      if (accessEndTime.isAfter(DateTime.now())) {
        setState(() {
          hasAccess = true;
        });
        startAccessTimer(accessEndTime.difference(DateTime.now()));
      }
    }
  }

  void startAccessTimer(Duration duration) {
    accessTimer = Timer(duration, () {
      setState(() {
        hasAccess = false;
      });
    });
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QRViewScan(expectedID: idEstate)));
    print('QR Scan Result: $result');
    if (result == true) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String accessTimeKey = 'access_time_$idEstate';
      DateTime accessEndTime = DateTime.now().add(Duration(minutes: 3));
      sharedPreferences.setString(
          accessTimeKey, accessEndTime.toIso8601String());
      setState(() {
        hasAccess = true;
      });
      startAccessTimer(Duration(minutes: 3));
      print('Access granted');
    } else {
      print('Access denied');
    }
  }

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

  void sendMessage(String message) async {
    _textController.clear();
    _messageNotifier.value = "";
    _charCountNotifier.value = 0;

    String censoredMessage = censorMessage(message);
    String fullName = await getUserFullName(id!);
    String? hour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String? minute = TimeOfDay.now().minute.toString().padLeft(2, '0');

    DatabaseReference refChat = FirebaseDatabase.instance
        .ref("App")
        .child("Chat")
        .child(widget.idEstate)
        .child(widget.Key);

    DatabaseReference refChatList = FirebaseDatabase.instance
        .ref("App")
        .child("ChatList")
        .child(widget.idEstate);

    await refChat.push().set({
      'message': censoredMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'SenderId': id,
      'IDEstate': idEstate,
      'seen': "0",
      'Type': "2",
      'Name': fullName,
      'time': "$hour:$minute"
    });

    await refChatList.child(id!).set({
      "SenderId": id,
      "IDEstate": idEstate,
      "Name": fullName,
    });

    await refChatList.child(widget.Key).set({
      "SenderId": widget.Key,
      "IDEstate": idEstate,
      "Name": fullName,
    });

    String? token = await firebaseMessaging.getToken();
    fetchPost('New Message For $Name', censoredMessage);
  }

  void fetchPost(String title, String message) async {
    try {
      await callable.call(<String, dynamic>{
        'userid': widget.Key,
        'title': title,
        'message': message,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference refChat = FirebaseDatabase.instance
        .ref("App")
        .child("Chat")
        .child(widget.idEstate)
        .child(widget.Key);

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Chat ${widget.Name}', style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
        iconTheme: kIconTheme,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  stream: refChat.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<DataSnapshot> items =
                        snapshot.data!.snapshot.children.toList();
                    if (items.isEmpty) {
                      return Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        Map map = items[index].value as Map;
                        map['Key'] = items[index].key;

                        return FutureBuilder<String>(
                          future: getUserFullName(map['SenderId']),
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (asyncSnapshot.hasError ||
                                !asyncSnapshot.hasData) {
                              return Text('Error fetching user name');
                            }
                            String fullName = asyncSnapshot.data!;
                            return Column(
                              crossAxisAlignment:
                                  map['SenderId'] == currentUser?.uid
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: map['SenderId'] == currentUser?.uid
                                        ? kPrimaryColor
                                        : Colors.grey[300],
                                    borderRadius:
                                        map['SenderId'] == currentUser?.uid
                                            ? kMessageBorderRadius2
                                            : kMessageBorderRadius,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 16.0),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        fullName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: map['SenderId'] ==
                                                    currentUser?.uid
                                                ? kSenderTextMessage
                                                : kReceiverTextMessage,
                                            fontSize: 10),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              map['message'] ?? "",
                                              style: TextStyle(
                                                  color: map['SenderId'] ==
                                                          currentUser?.uid
                                                      ? kSenderTextMessage
                                                      : kReceiverTextMessage,
                                                  fontSize: 15.0),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            map['time'] ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: map['SenderId'] ==
                                                        currentUser?.uid
                                                    ? kSenderTextMessage
                                                    : kReceiverTextMessage,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: const BorderSide(color: Colors.grey, width: 1.0)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _charCountNotifier,
                        builder: (context, count, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '$count / 125',
                              style: TextStyle(
                                  color:
                                      count > 500 ? Colors.red : Colors.grey),
                            ),
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              maxLength: 125,
                              maxLines: null,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(16.0),
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                counterText: "", // Hide the counter text
                              ),
                              onChanged: (text) {
                                _messageNotifier.value = text;
                                _charCountNotifier.value = text.length;
                              },
                              onSubmitted: (text) {
                                if (text.isNotEmpty && hasAccess) {
                                  sendMessage(text);
                                }
                              },
                              enabled: hasAccess, // Disable typing if no access
                            ),
                          ),
                          if (userType == "1")
                            IconButton(
                              icon: Icon(Icons.qr_code_scanner),
                              color: kPrimaryColor,
                              onPressed: scanQRCode,
                            ),
                          ValueListenableBuilder<String>(
                            valueListenable: _messageNotifier,
                            builder: (context, value, child) {
                              return IconButton(
                                icon: const Icon(Icons.send),
                                color: value.isEmpty || !hasAccess
                                    ? Colors.grey
                                    : kPrimaryColor,
                                onPressed: value.isEmpty || !hasAccess
                                    ? null
                                    : () {
                                        sendMessage(_textController.text);
                                      },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!hasAccess && userType == "1")
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Scan the QR code to access chat",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: Icon(Icons.qr_code_scanner),
                          label: Text("Scan QR Code"),
                          onPressed: scanQRCode,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
