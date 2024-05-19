// ignore_for_file: non_constant_identifier_names

import 'package:diamond_booking/widgets/text_form_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
  List<Estate> LstEstate = [];
  List<Rooms> LstRooms = [];
  TextEditingController Search_Controller = TextEditingController();
  List<Additional> LstAdditional = [];
  String id;
  int flag = 0;
  String Name;

  _State(this.id, this.Name);
  late Query query;
  @override
  void initState() {
    super.initState();
  }

  Future<String> getName(String id) async {
    String name = "";
    final ref = FirebaseDatabase.instance.ref("App");
    final snapshot = await ref.child("User").child(id).get();
    if (snapshot.exists) {
      final Map data = snapshot.value as Map;
      return data['Name'];
    } else {
      print('No data available.');
      return "";
    }
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF84A5FA),
        ),
        body: SafeArea(
            child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 10, bottom: 10, right: 5, top: 5),
                child: Row(
                  children: [
                    // ignore: sort_child_properties_last
                    Expanded(
                      // ignore: sort_child_properties_last
                      child: TextFormFieldStyle(
                          context: context,
                          hint: "Search",
                          // ignore: prefer_const_constructors
                          icon: Icon(
                            Icons.search,
                            color: const Color(0xFF84A5FA),
                          ),
                          control: Search_Controller,
                          isObsecured: false,
                          validate: true,
                          textInputType: TextInputType.emailAddress),
                      flex: 4,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                // ignore: sort_child_properties_last
                child: FirebaseAnimatedList(
                  shrinkWrap: true,
                  defaultChild: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  itemBuilder: (context, snapshot, animation, index) {
                    Map map = snapshot.value as Map;

                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => Chat(
                                    idEstate: id,
                                    Name: Name,
                                    Key: snapshot.key.toString(),
                                  )));
                        },
                        title: FutureBuilder<String?>(
                          future: getName(snapshot.key.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              return Text(snapshot.data!);
                            }
                            // ignore: prefer_const_constructors
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: const Center(
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
                      .child("Chat")
                      .child(id),
                ),

                height: MediaQuery.of(context).size.height,
              ),
            ],
          ),
        )));
  }
}
