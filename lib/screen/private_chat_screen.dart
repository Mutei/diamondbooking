import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../constants/colors.dart';
import '../constants/styles.dart';

class PrivateChatScreen extends StatefulWidget {
  final String userId;
  final String fullName;

  PrivateChatScreen({required this.userId, required this.fullName});

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final databaseReference = FirebaseDatabase.instance;
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<String> _messageNotifier = ValueNotifier<String>("");
  final ValueNotifier<int> _charCountNotifier = ValueNotifier<int>(0);
  String? id = "";
  User? currentUser;
  String? currentUserName = "User"; // Default to 'User' to avoid null issues

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser?.uid ?? '';
    currentUser = FirebaseAuth.instance.currentUser;
    fetchCurrentUserFullName(); // Fetch the current user's full name on initialization
  }

  // Function to fetch the current user's full name from the Firebase database
  Future<void> fetchCurrentUserFullName() async {
    if (id != null && id!.isNotEmpty) {
      DatabaseReference userRef = databaseReference.ref("App/User/$id");
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        String firstName = snapshot.child("FirstName").value?.toString() ?? '';
        String secondName = snapshot.child("SecondName").value?.toString() ?? '';
        String lastName = snapshot.child("LastName").value?.toString() ?? '';
        setState(() {
          currentUserName = "$firstName $secondName $lastName".trim();
        });
        print("Fetched Current User Name: $currentUserName");
      } else {
        print("User data does not exist for ID: $id");
      }
    } else {
      print("User ID is null or empty");
    }
  }

  // Function to send a message and update the chat lists in Firebase
  Future<void> sendMessage(String message) async {
    if (message.isEmpty || id == null || id!.isEmpty) {
      return;
    }

    _textController.clear();
    _messageNotifier.value = "";
    _charCountNotifier.value = 0;

    String fullName = currentUserName ?? 'User';
    String hour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String minute = TimeOfDay.now().minute.toString().padLeft(2, '0');

    DatabaseReference refChatSender = databaseReference
        .ref("App/PrivateChat")
        .child(id!)
        .child(widget.userId);

    DatabaseReference refChatReceiver = databaseReference
        .ref("App/PrivateChat")
        .child(widget.userId)
        .child(id!);

    Map<String, dynamic> messageData = {
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'SenderId': id,
      'ReceiverId': widget.userId,
      'seen': "0",
      'Type': "1",
      'Name': fullName,
      'time': "$hour:$minute"
    };

    await refChatSender.push().set(messageData);
    await refChatReceiver.push().set(messageData);

    print("Message data sent to Firebase:");
    print(messageData);

    DatabaseReference refChatListSender =
    databaseReference.ref("App/PrivateChatList").child(id!);

    DatabaseReference refChatListReceiver =
    databaseReference.ref("App/PrivateChatList").child(widget.userId);

    // Here we explicitly set the receiver's name to the correct one
    await refChatListSender.child(widget.userId).set({
      "ReceiverId": widget.userId,
      "Name": widget.fullName, // Ensure we use the correct receiver name
    });

    print("Updated PrivateChatList for SenderId:");
    print({
      "ReceiverId": widget.userId,
      "Name": widget.fullName,
    });

    await refChatListReceiver.child(id!).set({
      "ReceiverId": id,
      "Name": currentUserName, // Ensure we use the correct sender name
    });

    print("Updated PrivateChatList for ReceiverId:");
    print({
      "ReceiverId": id,
      "Name": currentUserName,
    });
  }


  // Function to format the timestamp for display
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
    DatabaseReference refChat = databaseReference
        .ref("App/PrivateChat")
        .child(id!)
        .child(widget.userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fullName,
          style: const TextStyle(color: kPrimaryColor),
        ),
        iconTheme: kIconTheme,
        centerTitle: true,
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

                    // Reverse the list to show the latest message first
                    items = items.reversed.toList();

                    if (items.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      reverse: true, // Start the list from the bottom
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        Map map = items[index].value as Map;
                        map['Key'] = items[index].key;

                        String senderId = map['SenderId'] ?? '';
                        String message = map['message'] ?? '';
                        String time = map['time'] ?? '';
                        String name = map['Name'] ?? '';

                        print("Displaying message:");
                        print("SenderId: $senderId, Name: $name, Message: $message");

                        return Column(
                          crossAxisAlignment: senderId == id
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                              ),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: senderId == id
                                    ? kPrimaryColor
                                    : Colors.grey[300],
                                borderRadius: senderId == id
                                    ? kMessageBorderRadius2
                                    : kMessageBorderRadius,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      name.isNotEmpty ? name : 'Unknown',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: senderId == id
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 10),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            message.isNotEmpty
                                                ? message
                                                : '[No message]',
                                            style: TextStyle(
                                                color: senderId == id
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
                                                  map['timestamp'] ?? 0),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: senderId == id
                                                      ? kSenderTextMessage
                                                      : kReceiverTextMessage,
                                                  fontSize: 10),
                                            ),
                                            Text(
                                              time.isNotEmpty ? time : '00:00',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: senderId == id
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
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 1.0)),
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
                              '$count / 100',
                              style: TextStyle(
                                  color: count > 125 ? Colors.red : Colors.grey),
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
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                counterText: "", // Hide the counter text
                              ),
                              onChanged: (text) {
                                _messageNotifier.value = text;
                                _charCountNotifier.value = text.length;
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
                                icon: const Icon(Icons.send),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
