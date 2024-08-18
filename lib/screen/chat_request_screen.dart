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

  Future<void> sendChatRequest(String receiverId, String receiverName) async {
    final senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final databaseReference = FirebaseDatabase.instance;

    if (senderId.isEmpty) return;

    // Fetch the current user's name
    DatabaseReference senderRef = databaseReference.ref("App/User/$senderId");
    DataSnapshot senderSnapshot = await senderRef.get();
    String senderName = "Unknown User";

    if (senderSnapshot.exists) {
      String firstName =
          senderSnapshot.child("FirstName").value?.toString() ?? '';
      String lastName =
          senderSnapshot.child("LastName").value?.toString() ?? '';
      senderName = "$firstName $lastName".trim();
    }

    // Debugging: Print the names before storing
    print("Storing Chat Request:");
    print("SenderId: $senderId, SenderName: $senderName");
    print("ReceiverId: $receiverId, ReceiverName: $receiverName");

    // Create chat request
    DatabaseReference refChatRequestReceiver = databaseReference
        .ref("App/PrivateChatRequest")
        .child(receiverId)
        .child(senderId);

    await refChatRequestReceiver.set({
      'SenderId': senderId,
      'SenderName': senderName,
      'ReceiverId': receiverId,
      'ReceiverName': receiverName,
    });

    // Debugging: Confirm the data was set
    print("Chat request data stored in Firebase:");
    print({
      'SenderId': senderId,
      'SenderName': senderName,
      'ReceiverId': receiverId,
      'ReceiverName': receiverName,
    });
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

      // Try to fetch ReceiverName from requestData
      String receiverName = requestData["ReceiverName"] ?? "Unknown User";
      String requestSenderName = requestData["SenderName"] ?? senderName;

      // If ReceiverName is "Unknown User", fetch it directly from the user's data
      if (receiverName == "Unknown User") {
        DatabaseReference receiverRef = databaseReference.ref("App/User/$id");
        DataSnapshot receiverSnapshot = await receiverRef.get();
        if (receiverSnapshot.exists) {
          String firstName =
              receiverSnapshot.child("FirstName").value?.toString() ?? '';
          String secondName =
              receiverSnapshot.child("SecondName").value?.toString() ?? '';
          String lastName =
              receiverSnapshot.child("LastName").value?.toString() ?? '';
          receiverName = "$firstName $secondName $lastName".trim();
          print("Fetched Receiver Name from User Data: $receiverName");
        } else {
          print("Receiver data does not exist for ID: $id");
        }
      }

      // Debugging: Ensure correct values are being retrieved
      print("Final Receiver Name: $receiverName");
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

    print("Chat request rejected from $senderId");
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
            String senderId = map['SenderId'] ?? 'Unknown User';
            String senderName = map['SenderName'] ?? 'Unknown User';

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
            String receiverId = map['ReceiverId'] ?? 'Unknown User';
            String receiverName = map['Name'] ?? 'Unknown User';

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
