import 'package:diamond_booking/widgets/text_form_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../constants/styles.dart';
import '../general_provider.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import 'Estate.dart';
import 'chat.dart';

class ListChatUser extends StatefulWidget {
  String id;
  String Name;
  ListChatUser({required this.id, required this.Name});
  @override
  _State createState() => new _State(id, Name);
}

class _State extends State<ListChatUser> {
  TextEditingController Search_Controller = TextEditingController();
  String id;
  String Name;

  _State(this.id, this.Name);

  @override
  void initState() {
    super.initState();
    print("Chat ID: $id");
  }

  Future<String> getName(String id) async {
    final ref = FirebaseDatabase.instance.ref("App");
    final snapshot = await ref.child("User").child(id).get();
    if (snapshot.exists) {
      final Map data = snapshot.value as Map;
      String firstName = data['FirstName'] ?? "";
      String secondName = data['SecondName'] ?? "";
      String lastName = data['LastName'] ?? "";
      return "$firstName $secondName $lastName".trim();
    } else {
      print('No data available.');
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    print("Chat ID in build method: $id");

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: kIconTheme,
        title: Text("Hello"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 10, bottom: 10, right: 5, top: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormFieldStyle(
                        context: context,
                        hint: "Search",
                        icon: const Icon(
                          Icons.search,
                          color: kPrimaryColor,
                        ),
                        control: Search_Controller,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                height: MediaQuery.of(context).size.height,
                child: FirebaseAnimatedList(
                  shrinkWrap: true,
                  defaultChild:
                      const Center(child: CircularProgressIndicator()),
                  itemBuilder: (context, snapshot, animation, index) {
                    Map map = snapshot.value as Map;

                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => Chat(
                                idEstate: widget.id,
                                Name: widget.Name,
                                Key: snapshot.key.toString(),
                              ),
                            ),
                          );
                        },
                        title: FutureBuilder<String?>(
                          future: getName(snapshot.key.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              return Text(snapshot.data!);
                            }
                            return const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  query: FirebaseDatabase.instance
                      .ref("App")
                      .child("ChatList")
                      .child(widget.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
