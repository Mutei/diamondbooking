import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import 'private_chat_screen.dart';
import 'dart:async';

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

  late StreamController<DatabaseEvent> _chatRequestsController;
  late StreamController<DatabaseEvent> _chatListController;

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser?.uid;
    currentUser = FirebaseAuth.instance.currentUser;
    _tabController = TabController(length: 2, vsync: this);

    _chatRequestsController = StreamController<DatabaseEvent>.broadcast();
    _chatListController = StreamController<DatabaseEvent>.broadcast();

    _listenToChatRequests();
    _listenToChatList();
  }

  void _listenToChatRequests() {
    DatabaseReference refChatRequest =
        databaseReference.ref("App/PrivateChatRequest").child(id!);

    refChatRequest.onValue.listen((event) {
      _chatRequestsController.add(event);
    });
  }

  void _listenToChatList() {
    DatabaseReference refChatList =
        databaseReference.ref("App/PrivateChatList").child(id!);

    refChatList.onValue.listen((event) {
      _chatListController.add(event);
    });
  }

  Future<void> acceptChatRequest(String senderId, String senderName) async {
    DatabaseReference refChatRequest = databaseReference
        .ref("App/PrivateChatRequest")
        .child(id!)
        .child(senderId);

    DatabaseReference refChatListSender =
        databaseReference.ref("App/PrivateChatList").child(senderId);

    DatabaseReference refChatListReceiver =
        databaseReference.ref("App/PrivateChatList").child(id!);

    DataSnapshot snapshot = await refChatRequest.get();
    if (snapshot.exists) {
      Map<String, dynamic> requestData =
          Map<String, dynamic>.from(snapshot.value as Map);

      await refChatListSender.child(id!).set({
        "ReceiverId": id,
        "Name": requestData["ReceiverName"],
      });

      await refChatListReceiver.child(senderId).set({
        "ReceiverId": senderId,
        "Name": requestData["SenderName"],
      });

      await refChatRequest.remove();

      // Navigate to the PrivateChatScreen
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PrivateChatScreen(
                userId: senderId,
                fullName: senderName,
              )));
    }
  }

  Future<void> rejectChatRequest(String senderId) async {
    DatabaseReference refChatRequest = databaseReference
        .ref("App/PrivateChatRequest")
        .child(id!)
        .child(senderId);

    await refChatRequest.remove();
  }

  Widget _buildChatRequests() {
    return StreamBuilder(
      stream: _chatRequestsController.stream,
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
          return const Center(child: Text('No chat requests'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            Map map = items[index].value as Map;
            map['Key'] = items[index].key;
            String senderId = map['SenderId'];
            String senderName = map['SenderName'];

            return ListTile(
              title: Text(senderName),
              subtitle: Text('Chat request from $senderName'),
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
    return StreamBuilder(
      stream: _chatListController.stream,
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
          return const Center(child: Text('No chats'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            Map map = items[index].value as Map;
            map['Key'] = items[index].key;
            String receiverId = map['ReceiverId'];
            String receiverName = map['Name'];

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
  void dispose() {
    _chatRequestsController.close();
    _chatListController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
        centerTitle: true,
        title: const Text(
          "Chat Requests",
          style: TextStyle(color: kPrimaryColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "Chats"),
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
