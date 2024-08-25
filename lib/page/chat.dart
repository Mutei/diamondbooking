import 'dart:async';
import 'dart:ui';
import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../screen/active_customer_screen.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../global/censor_message.dart';
import '../resources/user_services.dart';
import '../screen/private_chat_screen.dart';
import 'qrViewScan.dart';
import 'package:intl/intl.dart';
import '../general_provider.dart';

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
  DateTime? lastScanTime;
  int activeCustomers = 0;
  String? typeAccount = "";
  bool isHotel = false;

  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendNotificationsadmin',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 5)));

  _State(this.idEstate, this.Name, this.Key);

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser?.uid;
    currentUser = UserService().getCurrentUser();
    fetchUserType();
    fetchTypeAccount();
    listenToActiveCustomers();
    checkAccessPeriodically();
    checkIfHotel();
  }

  @override
  void dispose() {
    accessTimer?.cancel();
    if (!hasAccess) {
      removeActiveCustomer();
    }
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

  Future<void> fetchTypeAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DatabaseReference typeAccountRef =
            databaseReference.ref().child('App/User/$uid/TypeAccount');
        DataSnapshot snapshot = await typeAccountRef.get();
        if (snapshot.exists) {
          setState(() {
            typeAccount = snapshot.value.toString();
          });
        }
      }
    } catch (e) {
      print("Failed to fetch TypeAccount: $e");
    }
  }

  Future<void> checkIfHotel() async {
    DatabaseReference estateRef =
        databaseReference.ref().child('App/Estate/Hottel/$idEstate');
    DataSnapshot snapshot = await estateRef.get();
    if (snapshot.exists) {
      setState(() {
        isHotel = true;
      });
    }
  }

  Future<void> checkAccess() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String accessTimeKey = 'access_time_${widget.idEstate}_$id';
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

    String lastScanTimeKey = 'last_scan_time_${widget.idEstate}_$id';
    String? lastScanTimeString = sharedPreferences.getString(lastScanTimeKey);
    if (lastScanTimeString != null) {
      setState(() {
        lastScanTime = DateTime.parse(lastScanTimeString);
      });
    }
  }

  void startAccessTimer(Duration duration) {
    accessTimer = Timer(duration, () {
      setState(() {
        hasAccess = false;
      });
      removeActiveCustomer();
    });
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QRViewScan(expectedID: idEstate)));
    print('QR Scan Result: $result');
    if (result == true) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String accessTimeKey = 'access_time_${widget.idEstate}_$id';
      DateTime accessEndTime = DateTime.now().add(
          isHotel ? const Duration(minutes: 10 ) : const Duration(minutes: 10));
      sharedPreferences.setString(
          accessTimeKey, accessEndTime.toIso8601String());

      String lastScanTimeKey = 'last_scan_time_${widget.idEstate}_$id';
      DateTime now = DateTime.now();
      sharedPreferences.setString(lastScanTimeKey, now.toIso8601String());
      setState(() {
        lastScanTime = now;
        hasAccess = true;
      });
      startAccessTimer(
        isHotel ? const Duration(minutes: 10) : const Duration(minutes: 10),
      );
      print('Access granted');
      addActiveCustomer();
    } else {
      print('Access denied');
    }
  }

  Future<void> addActiveCustomer() async {
    if (id != null) {
      try {
        DateTime now = DateTime.now();
        DateTime endTime = isHotel
            ? now.add(const Duration(minutes: 5))
            : now.add(const Duration(minutes: 5));

        await databaseReference.ref("App/ActiveCustomers/$idEstate/$id").set({
          "StartTime": now.toIso8601String(),
          "EndTime": endTime.toIso8601String(),
        }).timeout(Duration(seconds: 10), onTimeout: () {
          // Handle timeout
          print("Timeout while adding active customer.");
        });
      } catch (e) {
        print("Failed to add active customer: $e");
      }
    }
  }


  Future<void> removeActiveCustomer() async {
    if (id != null) {
      try {
        print("Attempting to remove customer with ID: $id");
        print("Estate ID: $idEstate");

        DatabaseReference customerRef =
        databaseReference.ref("App/ActiveCustomers/$idEstate/$id");
        DataSnapshot snapshot = await customerRef.get();

        print("Snapshot: ${snapshot.value}");

        if (snapshot.exists) {
          // Access the nested data without casting directly to a specific type
          Map<dynamic, dynamic>? customerData = snapshot.value as Map?;
          if (customerData != null) {
            Map<dynamic, dynamic>? userEntry = customerData[id];
            if (userEntry != null) {
              String? endTimeString = userEntry['EndTime'];
              print("EndTime: $endTimeString");

              if (endTimeString != null) {
                DateTime endTime = DateTime.parse(endTimeString);
                if (DateTime.now().isAfter(endTime)) {
                  await customerRef.remove();

                } else {
                  print("End time has not passed yet; customer not removed.");
                }
              } else {
                print("End time is null, cannot remove customer.");
              }
            } else {
              print("User entry does not exist, cannot remove customer.");
            }
          } else {
            print("Customer data is null or not a map, cannot remove customer.");
          }
        } else {
          print("No customer data exists at the specified reference.");
        }
      } catch (e) {
        print("Failed to remove customer: $e");
      }
    } else {
      print("User ID is null, cannot proceed with removal.");
    }
  }





  void listenToActiveCustomers() {
    DatabaseReference activeCustomersRef =
        databaseReference.ref("App/ActiveCustomers/$idEstate");
    activeCustomersRef.onValue.listen((event) async {
      if (event.snapshot.exists) {
        Map activeUsers = event.snapshot.value as Map;
        setState(() {
          activeCustomers = activeUsers.length;
        });

        if (!activeUsers.containsKey(id)) {
          setState(() {
            hasAccess = false;
          });

          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.remove('access_time_${widget.idEstate}_$id');
          sharedPreferences.remove('last_scan_time_${widget.idEstate}_$id');
        }
      } else {
        setState(() {
          activeCustomers = 0;
          hasAccess = false;
        });

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.remove('access_time_${widget.idEstate}_$id');
        sharedPreferences.remove('last_scan_time_${widget.idEstate}_$id');
      }
    });
  }

  void checkAccessPeriodically() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await removeActiveCustomer();
    });
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

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App").child("User").child(userId);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      String gender = snapshot.child("Gender").value?.toString() ?? "";
      String typeAccount =
          snapshot.child("TypeAccount").value?.toString() ?? "";
      return {"Gender": gender, "TypeAccount": typeAccount};
    }
    return {};
  }

  Future<bool> checkIfRequestAccepted(String senderId) async {
    try {
      DatabaseReference chatRequestRef = FirebaseDatabase.instance
          .ref("App/PrivateChatList")
          .child(id!)
          .child(senderId);

      DataSnapshot snapshot = await chatRequestRef.get();

      return snapshot.exists && snapshot.hasChild('ReceiverId');
    } catch (e) {
      print("Error checking request acceptance: $e");
      return false;
    }
  }

  void sendMessage(String message) async {
    if (!hasAccess) return;

    if (userType == "2") return;

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

  void _showProfileDialog(String userId) async {
    if (userType == "2") {
      return;
    }

    if (typeAccount != '2' && typeAccount != '3') {
      return;
    }

    if (userId == id) {
      return;
    }

    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App").child("User").child(userId);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      String fullName =
          '${snapshot.child("FirstName").value as String? ?? ""} ${snapshot.child("SecondName").value as String? ?? ""} ${snapshot.child("LastName").value as String? ?? ""}';
      String profileImageUrl =
          snapshot.child("ProfileImageUrl").value as String? ??
              'assets/images/man.png';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(fullName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : AssetImage('assets/images/man.png') as ImageProvider,
                ),
                16.kH,
                ElevatedButton.icon(
                  icon: Icon(Icons.message),
                  label: Text('Message'),
                  onPressed: () async {
                    Navigator.of(context).pop();

                    bool isAccepted = await checkIfRequestAccepted(userId);

                    if (isAccepted) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PrivateChatScreen(
                              userId: userId, fullName: fullName)));
                    } else {
                      _sendChatRequest(userId, fullName);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _sendChatRequest(String receiverId, String receiverName) async {
    if (typeAccount != '2' && typeAccount != '3') {
      return;
    }

    if (userType == "2") {
      return;
    }

    String fullName = await getUserFullName(id!);

    DatabaseReference refChatRequest = FirebaseDatabase.instance
        .ref("App/PrivateChatRequest")
        .child(receiverId)
        .child(id!);

    await refChatRequest.set({
      "SenderId": id,
      "ReceiverId": receiverId,
      "SenderName": fullName,
      "ReceiverName": receiverName,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat request sent to $receiverName'),
      ),
    );
  }

  String formatTimestamp(int timestamp) {
    DateTime now = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return DateFormat('MM/dd/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference refChat = FirebaseDatabase.instance
        .ref("App")
        .child("Chat")
        .child(widget.idEstate)
        .child(widget.Key);

    final objProvider = Provider.of<GeneralProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.only(
                  right: 55,
                ),
                child: Text(
                  '${objProvider.CheckLangValue ? widget.Name : widget.Name} ${getTranslated(context, "Chat")}',
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: userType == "2"
                    ? () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ActiveCustomersScreen(idEstate: idEstate)));
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$activeCustomers',
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<DataSnapshot> items =
                        snapshot.data!.snapshot.children.toList();

                    items = items.reversed.toList();

                    if (items.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        Map map = items[index].value as Map;
                        map['Key'] = items[index].key;

                        if (lastScanTime != null &&
                            map['timestamp'] <
                                lastScanTime!.millisecondsSinceEpoch) {
                          return const SizedBox.shrink();
                        }

                        return GestureDetector(
                          onTap: () => _showProfileDialog(map['SenderId']),
                          child: FutureBuilder<String>(
                            future: getUserFullName(map['SenderId']),
                            builder: (context, asyncSnapshot) {
                              if (asyncSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (asyncSnapshot.hasError ||
                                  !asyncSnapshot.hasData) {
                                return const Text('Error fetching user name');
                              }
                              String fullName = asyncSnapshot.data!;
                              return FutureBuilder<Map<String, dynamic>>(
                                future: getUserDetails(map['SenderId']),
                                builder: (context, detailsSnapshot) {
                                  if (detailsSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (detailsSnapshot.hasError ||
                                      !detailsSnapshot.hasData) {
                                    return const Text(
                                        'Error fetching user details');
                                  }
                                  String gender =
                                      detailsSnapshot.data!['Gender'];
                                  String typeAccount =
                                      detailsSnapshot.data!['TypeAccount'];
                                  Color nameColor = Colors.white;
                                  if (map['SenderId'] != currentUser?.uid) {
                                    if (gender == 'Male' &&
                                        (typeAccount == '2' ||
                                            typeAccount == '3')) {
                                      nameColor = Colors.red;
                                    } else if (gender == 'Male') {
                                      nameColor = Colors.blue;
                                    } else if (gender == 'Female' &&
                                        (typeAccount == '2' ||
                                            typeAccount == '3')) {
                                      nameColor = Colors.yellowAccent;
                                    } else if (gender == 'Female') {
                                      nameColor = Colors.pink;
                                    } else {
                                      nameColor = Colors.black;
                                    }
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        map['SenderId'] == currentUser?.uid
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                        ),
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: map['SenderId'] ==
                                                  currentUser?.uid
                                              ? kPrimaryColor
                                              : Colors.grey[300],
                                          borderRadius: map['SenderId'] ==
                                                  currentUser?.uid
                                              ? kMessageBorderRadius2
                                              : kMessageBorderRadius,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 16.0),
                                        child: IntrinsicWidth(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                fullName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    color: nameColor,
                                                    fontSize: 10),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      map['message'] ?? "",
                                                      style: TextStyle(
                                                          color: map['SenderId'] ==
                                                                  currentUser
                                                                      ?.uid
                                                              ? kSenderTextMessage
                                                              : kReceiverTextMessage,
                                                          fontSize: 15.0),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        formatTimestamp(
                                                            map['timestamp'] ??
                                                                0),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: map['SenderId'] ==
                                                                    currentUser
                                                                        ?.uid
                                                                ? kSenderTextMessage
                                                                : kReceiverTextMessage,
                                                            fontSize: 10),
                                                      ),
                                                      Text(
                                                        map['time'] ?? "",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: map['SenderId'] ==
                                                                    currentUser
                                                                        ?.uid
                                                                ? kSenderTextMessage
                                                                : kReceiverTextMessage,
                                                            fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (userType == "1")
                Container(
                  decoration: const BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Colors.grey, width: 1.0)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: _charCountNotifier,
                          builder: (context, count, child) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
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
                                maxLength: 100,
                                maxLines: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(16.0),
                                  hintText: getTranslated(
                                      context, 'Type a message...'),
                                  border: InputBorder.none,
                                  counterText: "",
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
                                enabled: hasAccess,
                              ),
                            ),
                            if (userType == "1")
                              ValueListenableBuilder<String>(
                                valueListenable: _messageNotifier,
                                builder: (context, value, child) {
                                  return IconButton(
                                    icon: const Icon(Icons.send),
                                    color: value.isEmpty || !hasAccess
                                        ? Colors.grey
                                        : kPrimaryColor,
                                    onPressed: (value.isEmpty || !hasAccess)
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
                          getTranslated(
                              context, "Scan the QR code to access chat"),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        20.kH,
                        ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(
                            getTranslated(context, "Scan QR Code"),
                          ),
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
