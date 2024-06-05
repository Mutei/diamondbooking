// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/data_request.dart';

class NotificationUser extends StatefulWidget {
  @override
  _State createState() => new _State();
}

List<DataRequest> LstDataRequest = [];

class _State extends State<NotificationUser> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context);

    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        defaultChild: const Center(
          child: CircularProgressIndicator(),
        ),
        itemBuilder: (context, snapshot, animation, index) {
          Map value = snapshot.value as Map;
          value['Key'] = snapshot.key;
          String? id = FirebaseAuth.instance.currentUser?.uid;

          if (value["IDUser"] == id) {
            return Card(
              color: value["Status"] == "1"
                  ? Colors.white
                  : value["Status"] == "2"
                      ? Colors.green[200]
                      : Colors.red[100],
              child: Container(
                  child: Wrap(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ItemInCard(
                            Icon(Icons.calendar_month),
                            value["StartDate"].toString().split(" ")[0],
                            "From Date"),
                      ),
                      Expanded(
                        child: ItemInCard(
                            Icon(Icons.calendar_month),
                            value["EndDate"].toString().split(" ")[0],
                            "To Date"),
                      )
                    ],
                  ),
                  ItemInCard(
                      Icon(Icons.hotel),
                      value["Status"] == "1"
                          ? "Your Booking Under Prossing"
                          : value["Status"] == "2"
                              ? "Your Booking is Confermed"
                              : "Your Booking is Canseld",
                      "Status"),

                  // ignore: prefer_interpolation_to_compose_strings
                ],
              )),
            );
          } else {
            return Container();
          }
        },
        query:
            FirebaseDatabase.instance.ref("App").child("Booking").child("Book"),
      ),
    ));
  }

  ListRoom(String id) {
    return Container(
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        defaultChild: const Center(
          child: CircularProgressIndicator(),
        ),
        itemBuilder: (context, snapshot, animation, index) {
          Map map = snapshot.value as Map;
          map['Key'] = snapshot.key;
          //----------------------------
          return Container(
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: Text(getTranslated(context, map['Name'])),
              // ignore: prefer_const_constructors
              leading: Icon(
                Icons.single_bed,
                color: Color(0xFF84A5FA),
              ),
              trailing: Text(
                map['Price'],
                // ignore: prefer_const_constructors
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
              onTap: () async {},
            ),
          );
        },
        query: FirebaseDatabase.instance
            .ref("App")
            .child("Booking")
            .child("Room")
            .child(id),
      ),
    );
  }

  ListAdd(String id) {
    return Container(
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        defaultChild: const Center(
          child: CircularProgressIndicator(),
        ),
        itemBuilder: (context, snapshot, animation, index) {
          Map map = snapshot.value as Map;
          map['Key'] = snapshot.key;
          //----------------------------
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 70,
            child: ListTile(
              title: Text(map['NameEn']),
              // ignore: prefer_const_constructors
              trailing: Text(
                map['Price'],
                // ignore: prefer_const_constructors
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
              onTap: () async {},
            ),
          );
        },
        query: FirebaseDatabase.instance
            .ref("App")
            .child("Booking")
            .child("Additional")
            .child(id),
      ),
    );
  }

  Future<void> _showMyDialog(Map map) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Scaffold(
          // ignore: unnecessary_const
          appBar: AppBar(
            backgroundColor: Color(0xFF84A5FA),
            elevation: 0,
            title: Text(
              getTranslated(context, "Request"),
              // ignore: prefer_const_constructors
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30),
            ),
          ),
          body: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, "Rooms"),
                style: TextStyle(fontSize: 18),
              ),
              ListRoom(map['IDBook']),
              Text(
                getTranslated(context, "additional services"),
                style: TextStyle(fontSize: 18),
              ),
              ListAdd(map['IDBook']),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text(getTranslated(context, 'Confirm')),
                      onPressed: () async {
                        DatabaseReference ref = FirebaseDatabase.instance
                            .ref("App")
                            .child("Booking")
                            .child("Book")
                            .child(map['IDBook']);

                        await ref.update({
                          "Status": "2",
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: Text(getTranslated(context, 'Reject')),
                      onPressed: () async {
                        DatabaseReference ref = FirebaseDatabase.instance
                            .ref("App")
                            .child("Booking")
                            .child("Book")
                            .child(map['IDBook']);

                        await ref.update({
                          "Status": "3",
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: Text(getTranslated(context, 'close')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              )
            ],
          )),
        );
      },
    );
  }

  ItemInCard(Icon icon, String data, String labe) {
    return Container(
        child: ListTile(
      leading: icon,
      iconColor: Colors.black,
      title: Text(
        labe,
        style: TextStyle(fontSize: 12),
      ),
      subtitle: Text(
        data,
        style: TextStyle(fontSize: 12),
      ),
    ));
  }
}
