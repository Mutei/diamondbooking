import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              // Determine the estate name based on the app's current locale
              String locale = Localizations.localeOf(context).languageCode;
              String estateName = locale == 'ar'
                  ? value["NameAr"] ?? "غير معروف"
                  : value["NameEn"] ?? "Unknown";

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
                              getTranslated(context, "FromDate"),
                            ),
                          ),
                          Expanded(
                            child: ItemInCard(
                              Icon(Icons.calendar_month),
                              value["EndDate"].toString().split(" ")[0],
                              getTranslated(context, "ToDate"),
                            ),
                          )
                        ],
                      ),
                      ItemInCard(
                        Icon(Icons.hotel),
                        value["Status"] == "1"
                            ? getTranslated(
                                context, "Your Booking is Under Process")
                            : value["Status"] == "2"
                                ? getTranslated(
                                    context, "Your Booking is Confirmed")
                                : getTranslated(
                                    context, "Your Booking is Canceled"),
                        getTranslated(context, "Status"),
                      ),
                      ItemInCard(
                        Icon(Icons.business),
                        estateName,
                        getTranslated(context, "Estate Name"),
                      ),
                      if (value["Status"] == "2")
                        ItemInCard(
                          Icon(Icons.confirmation_number),
                          value['IDBook'],
                          getTranslated(context, "Order ID"),
                        ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
          query: FirebaseDatabase.instance
              .ref("App")
              .child("Booking")
              .child("Book"),
        ),
      ),
    );
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
              leading: Icon(
                Icons.single_bed,
                color: Color(0xFF84A5FA),
              ),
              trailing: Text(
                map['Price'],
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
              trailing: Text(
                map['Price'],
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
          appBar: AppBar(
            backgroundColor: Color(0xFF84A5FA),
            elevation: 0,
            title: Text(
              getTranslated(context, "Request"),
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
            ),
          ),
        );
      },
    );
  }

  ItemInCard(Icon icon, String data, String label) {
    return Container(
      child: ListTile(
        leading: icon,
        iconColor: Colors.black,
        title: Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
        subtitle: Text(
          data,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
