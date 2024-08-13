import 'package:diamond_booking/constants/colors.dart';
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

class Request extends StatefulWidget {
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
  @override
  void initState() {
    super.initState();
    Provider.of<GeneralProvider>(context, listen: false).resetNewRequestCount();
  }

  Future<double?> fetchUserRating(String userId) async {
    DatabaseReference ratingsRef = FirebaseDatabase.instance
        .ref("App")
        .child("ProviderFeedbackToCustomer")
        .child(userId)
        .child("ratings");

    DataSnapshot snapshot = await ratingsRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> ratingsData =
          snapshot.value as Map<dynamic, dynamic>;
      int totalRatings = ratingsData.length;
      double sumRatings = 0;

      ratingsData.forEach((key, value) {
        sumRatings += value['rating'] ?? 0;
      });

      double averageRating = sumRatings / totalRatings;
      return averageRating;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: kPrimaryColor,
      //   elevation: 0,
      // ),
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
            if (value["IDOwner"] == id) {
              return FutureBuilder<double?>(
                future: fetchUserRating(value['IDUser']),
                builder: (context, ratingSnapshot) {
                  if (ratingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(); // or any loading indicator
                  }
                  double? userRating = ratingSnapshot.data;
                  return Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: value["Status"] == "1"
                          ? Colors.white
                          : value["Status"] == "2"
                              ? Colors.lightGreen
                              : Colors.red[100],
                      child: InkWell(
                        onTap: () {
                          if (value["Status"] == "1") {
                            if (value["EndDate"].toString() != "") {
                              _showMyDialog(value);
                            } else {
                              _showMyDialogCoffe(value);
                            }
                          }
                        },
                        child: Wrap(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ItemInCard(
                                      Icon(Icons.calendar_month),
                                      value["StartDate"].toString(),
                                      // .split(" ")[2]
                                      getTranslated(context, "FromDate")),
                                ),
                                Expanded(
                                  child: value["EndDate"].toString() != ""
                                      ? ItemInCard(
                                          Icon(Icons.calendar_month),
                                          value["EndDate"].toString(),
                                          getTranslated(context, "ToDate"))
                                      : Container(),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ItemInCard(
                                      Icon(Icons.bookmark_added_sharp),
                                      value["IDBook"].toString(),
                                      // .split(" ")[2]
                                      getTranslated(context, "Booking ID")),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ItemInCard(
                                      Icon(Icons.timer),
                                      value["Clock"].toString(),
                                      // .split(" ")[2]
                                      getTranslated(context, "Time")),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ItemInCard(
                                    Icon(Icons.person),
                                    value['NameUser'] ?? "",
                                    getTranslated(context, "UserName"),
                                  ),
                                ),
                                Expanded(
                                  child: value["NetTotal"].toString() != "null"
                                      ? ItemInCard(
                                          Icon(Icons.money),
                                          value["NetTotal"].toString(),
                                          getTranslated(context, "Total"))
                                      : Container(),
                                )
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: kPrimaryColor,
                                    ),
                                    const SizedBox(width: 20),
                                    Text(userRating.toString(),
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            ItemInCard(Icon(Icons.business), value["NameEn"],
                                getTranslated(context, "Hottel Name")),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 70,
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
          Map? map;
          try {
            map = snapshot.value as Map;
            map['Key'] = snapshot.key;
          } catch (e) {
            print(e);
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 70,
            child: ListTile(
              title: Text(map!['NameEn']),
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF84A5FA),
            elevation: 0,
            title: Text(
              getTranslated(context, "Request"),
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: RichText(
                    text: TextSpan(
                      text: getTranslated(context, "Booking"),
                      style: GoogleFonts.laila(
                        fontSize: 6.w,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: getTranslated(context, " Details"),
                          style: GoogleFonts.laila(
                            fontWeight: FontWeight.bold,
                            fontSize: 6.w,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 20,
                ),
                Text(
                  getTranslated(context, "Rooms"),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ListRoom(map['IDBook']),
                Text(
                  getTranslated(context, "additional services"),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ListAdd(map['IDBook']),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text(
                          getTranslated(context, 'Confirm'),
                          style: TextStyle(
                            color: kPrimaryColor,
                          ),
                        ),
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
                        child: Text(
                          getTranslated(context, 's'),
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
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
                        child: Text(
                          getTranslated(context, 'close'),
                          style: TextStyle(
                            color: kPrimaryColor,
                          ),
                        ),
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

  Future<void> _showMyDialogCoffe(Map map) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: RichText(
                    text: TextSpan(
                      text: getTranslated(context, "Booking"),
                      style: GoogleFonts.laila(
                        fontSize: 6.w,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: getTranslated(context, " Details"),
                          style: GoogleFonts.laila(
                            fontWeight: FontWeight.bold,
                            fontSize: 6.w,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text(
                          getTranslated(context, 'Confirm'),
                          style: TextStyle(
                            color: kPrimaryColor,
                          ),
                        ),
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
                        child: Text(
                          getTranslated(context, 'Reject'),
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
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
                        child: Text(
                          getTranslated(context, 'close'),
                          style: TextStyle(
                            color: kPrimaryColor,
                          ),
                        ),
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

  ItemInCard(Icon icon, String data, String label, {Widget? additionalWidget}) {
    return Container(
      child: ListTile(
        leading: icon,
        iconColor: kPrimaryColor,
        title: Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data,
              style: TextStyle(fontSize: 12),
            ),
            if (additionalWidget != null) additionalWidget,
          ],
        ),
      ),
    );
  }
}
