import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../screen/main_screen.dart';

class DateBooking extends StatefulWidget {
  final Map Estate;
  final List<Rooms> LstRooms;
  final List<Additional> LstAdditional;

  DateBooking({
    required this.Estate,
    required this.LstRooms,
    required this.LstAdditional,
  });

  @override
  State<DateBooking> createState() =>
      _DateBookingState(Estate, LstAdditional, LstRooms);
}

class _DateBookingState extends State<DateBooking> {
  DateTimeRange? _selectedDateRange;
  final Map Estate;
  final List<Rooms> LstRooms;
  final List<Additional> LstAdditional;

  _DateBookingState(this.Estate, this.LstAdditional, this.LstRooms);

  String? FromDate = "x ";
  String? EndDate = "x ";
  int? countofday = 0;
  double netTotal = 0;

  DatabaseReference bookingRef =
      FirebaseDatabase.instance.ref("App").child("Booking");
  DatabaseReference refRooms =
      FirebaseDatabase.instance.ref("App").child("Booking").child("Room");
  DatabaseReference refAdd =
      FirebaseDatabase.instance.ref("App").child("Booking").child("Additional");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterLayoutWidgetBuild());
  }

  void afterLayoutWidgetBuild() async {
    _show();
  }

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      setState(() {
        _selectedDateRange = result;
        FromDate = _selectedDateRange?.start.toString();
        EndDate = _selectedDateRange?.end.toString();
        countofday = (_selectedDateRange?.end
            .difference(DateTime.parse(FromDate!))
            .inDays);
      });
    }
  }

  String generateUniqueOrderID() {
    var random = Random();
    return (random.nextInt(90000) + 10000)
        .toString(); // Generates a 5-digit number
  }

  Future<String> getUserFullName() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App/User/$userId");
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      String firstName = snapshot.child("FirstName").value.toString();
      String secondName = snapshot.child("SecondName").value.toString();
      String lastName = snapshot.child("LastName").value.toString();
      return "$firstName $secondName $lastName";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: ListTile(
                leading: Image(
                    image: AssetImage(Estate['Type'] == "1"
                        ? "assets/images/hotel.png"
                        : Estate['Type'] == "2"
                            ? "assets/images/coffee.png"
                            : "assets/images/restaurant.png")),
                title: Text(
                  Estate["NameEn"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  Estate["Country"] + " \ " + Estate["State"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: ListTile(
                  title: Text("From Date"),
                  subtitle: Text(FromDate!.split(" ")[0]),
                )),
                Expanded(
                    child: ListTile(
                  title: Text("To Date"),
                  subtitle: Text(EndDate!.split(" ")[0]),
                ))
              ],
            ),
            Text(
              "Count of Days :" + countofday.toString(),
            ),
            Text(
              getTranslated(context, "Rooms"),
              style: TextStyle(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: ListView.builder(
                  itemCount: LstRooms.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: ListTile(
                        title: Text(LstRooms[index].name),
                        trailing: Text(LstRooms[index].price),
                      ),
                    );
                  }),
              height: LstRooms.length * 70,
            ),
            Text(
              getTranslated(context, "additional services"),
              style: TextStyle(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: ListView.builder(
                  itemCount: LstAdditional.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: ListTile(
                        title: Text(LstAdditional[index].name),
                        trailing: Text(LstAdditional[index].price),
                      ),
                    );
                  }),
              height: LstAdditional.length * 70,
            ),
            FutureBuilder<String>(
              future: CalcuTotal(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data!);
                }
                return SizedBox(
                  width: 50,
                  height: 50,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            Container(
              height: 20,
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 20, left: 20, bottom: 20),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "Confirm Your Booking"),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          String orderID =
                              generateUniqueOrderID(); // Generate 5-digit Order ID
                          String fullName =
                              await getUserFullName(); // Fetch full name

                          DatabaseReference bookingRef =
                              FirebaseDatabase.instance.ref("App/Booking");

                          await bookingRef.child("Book").child(orderID).set({
                            "IDEstate": Estate['IDEstate'].toString(),
                            "IDBook": orderID, // Use the generated orderID here
                            "NameEn": Estate['NameEn'],
                            "NameAr": Estate['NameAr'],
                            "Status":
                                "1", // Initial status: "1" for "Under Processing"
                            "IDUser": FirebaseAuth.instance.currentUser?.uid,
                            "IDOwner": Estate['IDUser'],
                            "StartDate": _selectedDateRange?.start.toString(),
                            "EndDate": _selectedDateRange?.end.toString(),
                            "Type": Estate['Type'],
                            "Country": Estate["Country"],
                            "State": Estate["State"],
                            "City": Estate["City"],
                            "NameUser": fullName, // Save the full name
                            "NetTotal": netTotal.toString(),
                            "read": "0",
                            "readuser": "0"
                          });

                          for (var room in LstRooms) {
                            await refRooms.child(orderID).child(room.name).set({
                              "ID": room.id,
                              "Name": room.name,
                              "Price": room.price,
                              "BioAr": room.bio,
                              "BioEn": room.bioEn,
                            });
                          }

                          for (var additional in LstAdditional) {
                            await refAdd
                                .child(orderID)
                                .child(additional.id)
                                .set({
                              "IDEstate": Estate['IDEstate'].toString(),
                              "IDBook": orderID,
                              "NameEn": additional.nameEn,
                              "NameAr": additional.name,
                              "Price": additional.price,
                            });
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MainScreen()));
                        },
                      ),
                      flex: 3,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future<String> CalcuTotal() async {
    double TotalDayofRoom = 0;
    double TotalDayofAdditional = 0;

    for (int i = 0; i < LstRooms.length; i++) {
      TotalDayofRoom += (double.parse(LstRooms[i].price) *
          double.parse(countofday.toString()));
    }
    for (int i = 0; i < LstAdditional.length; i++) {
      TotalDayofAdditional += (double.parse(LstAdditional[i].price));
    }
    netTotal = TotalDayofRoom + TotalDayofAdditional;
    return TotalDayofRoom.toString() +
        "\n" +
        TotalDayofAdditional.toString() +
        "\n" +
        netTotal.toString();
  }
}
