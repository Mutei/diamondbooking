import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

class PrivateChatRequest extends StatefulWidget {
  const PrivateChatRequest({super.key});

  @override
  State<PrivateChatRequest> createState() => _PrivateChatRequestState();
}

class _PrivateChatRequestState extends State<PrivateChatRequest> {
  final databaseReference = FirebaseDatabase.instance;
  String? id = "";
  User? currentUser;

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser?.uid;
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> acceptChatRequest(String senderId) async {
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
    }
  }

  Future<void> rejectChatRequest(String senderId) async {
    DatabaseReference refChatRequest = databaseReference
        .ref("App/PrivateChatRequest")
        .child(id!)
        .child(senderId);

    await refChatRequest.remove();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference refChatRequest =
        databaseReference.ref("App/PrivateChatRequest").child(id!);

    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
        centerTitle: true,
        title: const Text(
          "Chat Request",
          style: TextStyle(color: kPrimaryColor),
        ),
      ),
      body: StreamBuilder(
        stream: refChatRequest.onValue,
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
                        acceptChatRequest(senderId);
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
      ),
    );
  }
}
