// ignore_for_file: non_constant_identifier_names

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../localization/language_constants.dart';
import '../page/estate1.dart';
import '../screen/user_type_screen.dart';

class CardType extends StatefulWidget {
  BuildContext context;
  CustomerType obj;

  CardType({
    required this.context,
    required this.obj,
  });

  @override
  _State createState() => _State(context, obj);
}

class _State extends State<CardType> {
  BuildContext context;
  CustomerType obj;

  _State(
    this.context,
    this.obj,
  );

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 50.w,
        child: SizedBox(
          height: 60.w,
          child: Row(
            children: [
              // ignore: prefer_const_constructors
              SizedBox(
                width: 10,
              ),
              Container(
                  width: 15.w,
                  height: 15.h,
                  // ignore: prefer_const_constructors
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image(
                      image: AssetImage(obj.image),
                      width: 30,
                      height: 30,
                    ),
                  )),
              // ignore: prefer_const_constructors
              SizedBox(
                width: 25,
              ),
              // ignore: sort_child_properties_last
              Expanded(
                // ignore: sort_child_properties_last
                child: Text(
                  getTranslated(context, obj.name),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                flex: 1,
              )
            ],
          ),
        ),
      ),
      onTap: () {
        Query query;

        if (obj.type == "1") {
          query = FirebaseDatabase.instance
              .ref("App")
              .child("Estate")
              .child("Hottel");
        } else if (obj.type == "2") {
          query = FirebaseDatabase.instance
              .ref("App")
              .child("Estate")
              .child("Coffee");
        } else {
          query = FirebaseDatabase.instance
              .ref("App")
              .child("Estate")
              .child("Restaurant");
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EstatePage(
                  type: obj.type,
                  icon: obj.image,
                  query: query,
                )));
      },
    );
  }
}
