// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../widgets/cardEstate.dart';
import 'Estate.dart';

class MyEstate extends StatefulWidget {
  String Type;

  MyEstate({required this.Type});
  @override
  _State createState() => new _State(Type);
}

class _State extends State<MyEstate> {
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
                      child: TextFormFieldStyle(),
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

                    String? id = FirebaseAuth.instance.currentUser?.uid;

                    if (id == map['IDUser']) {
                      if (Search_Controller.text.isEmpty) {
                        return CardEstate(
                          context: context,
                          obj: map,
                          icon: Type == "1"
                              ? "assets/images/hotel.png"
                              : Type == "2"
                                  ? "assets/images/coffee.png"
                                  : "assets/images/restaurant.png",
                          VisEdit: true,
                          image: "",
                          Visimage: false,
                        );
                      } else {
                        if (map['NameEn']
                                .toString()
                                .contains(Search_Controller.text) ||
                            map['NameAr']
                                .toString()
                                .contains(Search_Controller.text)) {
                          return CardEstate(
                            context: context,
                            obj: map,
                            icon: Type == "1"
                                ? "assets/images/hotel.png"
                                : Type == "2"
                                    ? "assets/images/coffee.png"
                                    : "assets/images/restaurant.png",
                            VisEdit: true,
                            image: "",
                            Visimage: false,
                          );
                        } else {
                          return Container();
                        }
                      }
                    } else {
                      return Container();
                    }
                    return Container();
                  },
                  query: query,
                ),

                height: MediaQuery.of(context).size.height,
              ),
            ],
          ),
        )));
  }

  Widget TextFormFieldStyle() {
    return Container(
      height: 6.5.h,
      width: 150.w,
      margin: const EdgeInsets.only(right: 40, top: 10),
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        // ignore: prefer_const_literals_to_create_immutables
        boxShadow: [
          // ignore: prefer_const_constructors
          BoxShadow(
            color: Colors.grey,
            offset: const Offset(0.0, 1.0), //(x,y)
            blurRadius: 10.0,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        controller: Search_Controller,
        obscureText: false,
        onChanged: (String x) {
          setState(() {});
        },
        decoration: InputDecoration(
            // ignore: prefer_const_constructors
            icon: Icon(
              Icons.search,
              color: const Color(0xFF84A5FA),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: getTranslated(context, "Search"),
            hintStyle: TextStyle(fontSize: 12)
            //fillColor: Colors.green
            ),
        style: const TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}
