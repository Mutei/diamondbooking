// ignore_for_file: non_constant_identifier_names

import 'package:diamond_booking/Page/Chat.dart';
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

class MyChat extends StatefulWidget {
  String Type;

  MyChat({required this.Type});
  @override
  _State createState() => new _State(Type);
}

class _State extends State<MyChat> {
  List<Estate> LstEstate = [];
  List<Rooms> LstRooms = [];
  TextEditingController Search_Controller = TextEditingController();
  List<Additional> LstAdditional = [];
  String Type;
  int flag = 0;
  _State(this.Type);
  late Query query;
  @override
  void initState() {
    if (Type == "1") {
      query =
          FirebaseDatabase.instance.ref("App").child("Estate").child("Hottel");
    } else if (Type == "2") {
      query =
          FirebaseDatabase.instance.ref("App").child("Estate").child("Coffee");
    } else {
      query = FirebaseDatabase.instance
          .ref("App")
          .child("Estate")
          .child("Restaurant");
    }
    super.initState();
  }

  String? id = FirebaseAuth.instance.currentUser?.uid;
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
                                      idEstate: map['IDEstate'].toString(),
                                      Name: map['Name'],
                                      Key: id!,
                                    )));
                          },
                          title: Text(map['Name']),
                        ),
                      );
                    },
                    query: FirebaseDatabase.instance
                        .ref("App")
                        .child("ChatList")
                        .child(id!)),

                height: MediaQuery.of(context).size.height,
              ),
            ],
          ),
        )));
  }
}
