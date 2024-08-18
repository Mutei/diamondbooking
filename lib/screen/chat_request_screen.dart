import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;
import '../constants/colors.dart';
import '../constants/styles.dart';
import 'private_chat_screen.dart';

class PrivateChatRequest extends StatefulWidget {
  const PrivateChatRequest({super.key});

  @override
  State<PrivateChatRequest> createState() => _PrivateChatRequestState();
}

class _PrivateChatRequestState extends State<PrivateChatRequest>
    with SingleTickerProviderStateMixin {
  final databaseReference = FirebaseDatabase.instance;
  String? id = "";
  User? currentUser;
  late TabController _tabController;
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser?.uid;
    currentUser = FirebaseAuth.instance.currentUser;
    _tabController = TabController(length: 2, vsync: this);
    _fetchChatRequestCount();
  }

  Future<void> acceptChatRequest(String senderId, String senderName) async {
    DatabaseReference refChatRequest = databaseReference
        .ref("App/PrivateChatRequest")
        .child(id!)
        .child(senderId);

    DataSnapshot snapshot = await refChatRequest.get();
    if (snapshot.exists) {
      Map<String, dynamic> requestData =
          Map<String, dynamic>.from(snapshot.value as Map);

      // Fetching the ReceiverName correctly
      String receiverName = requestData["ReceiverName"] ?? "Unknown User";
      String requestSenderName = requestData["SenderName"] ?? senderName;

      // Debugging: Ensure correct values are being retrieved
      print("Fetched Receiver Name: $receiverName");
      print("Fetched Sender Name: $requestSenderName");

      // Now use these values to update the chat lists
      await databaseReference
          .ref("App/PrivateChatList")
          .child(senderId)
          .child(id!)
          .set({
        "ReceiverId": id,
        "Name": receiverName,
      });

      await databaseReference
          .ref("App/PrivateChatList")
          .child(id!)
          .child(senderId)
          .set({
        "ReceiverId": senderId,
        "Name": requestSenderName,
      });

      // Double-check the stored data in PrivateChatList
      print("Updated PrivateChatList for SenderId:");
      print({
        "ReceiverId": id,
        "Name": receiverName,
      });

      print("Updated PrivateChatList for ReceiverId:");
      print({
        "ReceiverId": senderId,
        "Name": requestSenderName,
      });

      // Remove the chat request after accepting it
      await refChatRequest.remove();

      // Update the request count in the UI
      setState(() {
        _requestCount--;
      });

      // Log the acceptance
      print("Chat request accepted from $requestSenderName ($senderId)");

      // Delay before navigating to ensure everything is updated
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate to the PrivateChatScreen
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PrivateChatScreen(
                userId: senderId,
                fullName: requestSenderName,
              )));
    } else {
      print("No chat request found for $senderId");
    }
  }

  Future<void> rejectChatRequest(String senderId) async {
    DatabaseReference refChatRequest = databaseReference
        .ref("App/PrivateChatRequest")
        .child(id!)
        .child(senderId);

    await refChatRequest.remove();

    // Update the request count
    setState(() {
      _requestCount--;
    });
  }

  Future<void> _fetchChatRequestCount() async {
    DatabaseReference refChatRequest =
        databaseReference.ref("App/PrivateChatRequest").child(id!);

    refChatRequest.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map requests = event.snapshot.value as Map;
        setState(() {
          _requestCount = requests.length;
        });
      } else {
        setState(() {
          _requestCount = 0;
        });
      }
    });
  }

  Widget _buildChatRequests() {
    DatabaseReference refChatRequest =
        databaseReference.ref("App/PrivateChatRequest").child(id!);

    return StreamBuilder(
      stream: refChatRequest.onValue
          .asBroadcastStream(), // Ensure this stream can be listened to multiple times
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

        List<DataSnapshot> items = snapshot.data!.snapshot.children.toList();

        if (items.isEmpty) {
          return Center(
              child: Text(getTranslated(context, 'No chat requests')));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            Map map = items[index].value as Map;
            map['Key'] = items[index].key;
            dynamic senderId = map['SenderId'] ?? "";

            // Fetch SenderName from Firebase if it's not provided in the request
            dynamic senderName = map['SenderName'] ?? "";
            if (senderName == "Unknown Sender") {
              _fetchSenderName(senderId).then((name) {
                setState(() {
                  senderName = name;
                });
              });
            }

            return ListTile(
              title: Text(senderName),
              subtitle: Text(
                  '${getTranslated(context, 'Chat request from')} $senderName'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      acceptChatRequest(senderId, senderName);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      rejectChatRequest(senderId);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _fetchSenderName(String senderId) async {
    // Fetch the sender's name from the Firebase database
    DatabaseReference refUser =
        databaseReference.ref("App/User").child(senderId);
    DataSnapshot snapshot = await refUser.get();

    if (snapshot.exists) {
      String firstName = snapshot.child("FirstName").value?.toString() ?? "";
      String lastName = snapshot.child("LastName").value?.toString() ?? "";
      return "$firstName $lastName";
    }
    return "Unknown Sender";
  }

  Widget _buildChatList() {
    DatabaseReference refChatList =
        databaseReference.ref("App/PrivateChatList").child(id!);

    return StreamBuilder(
      stream: refChatList.onValue
          .asBroadcastStream(), // Ensure this stream can be listened to multiple times
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

        List<DataSnapshot> items = snapshot.data!.snapshot.children.toList();

        if (items.isEmpty) {
          return Center(child: Text(getTranslated(context, 'No chats')));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            Map map = items[index].value as Map;
            map['Key'] = items[index].key;
            String receiverId = map['ReceiverId'] ?? "";
            String receiverName = map['Name'] ?? map['Name'];

            return ListTile(
              title: Text(receiverName),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PrivateChatScreen(
                          userId: receiverId,
                          fullName: receiverName,
                        )));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
        centerTitle: true,
        title: Text(
          getTranslated(context, "Chat Requests"),
          style: TextStyle(color: kPrimaryColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: getTranslated(context, "Requests"),
              icon: _requestCount > 0
                  ? badges.Badge(
                      badgeContent: Text(
                        _requestCount.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      child: const Icon(Icons.message),
                    )
                  : const Icon(Icons.message),
            ),
            Tab(text: getTranslated(context, "Chats")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatRequests(),
          _buildChatList(),
        ],
      ),
    );
  }
}
