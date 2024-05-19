// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../screen/main_screen.dart';

class DateBooking extends StatefulWidget {
  Map Estate;
  List<Rooms> LstRooms = [];
  List<Additional> LstAdditional = [];
  DateBooking(
      {required this.Estate,
      required this.LstRooms,
      required this.LstAdditional});

  @override
  State<DateBooking> createState() =>
      _HomeScreenState(Estate, LstAdditional, LstRooms);
}

class _HomeScreenState extends State<DateBooking> {
  DateTimeRange? _selectedDateRange;
  Map Estate;
  List<Rooms> LstRooms = [];
  List<Additional> LstAdditional = [];
  _HomeScreenState(this.Estate, this.LstAdditional, this.LstRooms);
  String? FromDate = "x ";
  String? EndDate = "x ";
  int? countofday = 0;
  double netTotal = 0;
  // This function will be triggered when the floating button is pressed
  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      // Rebuild the UI
      print(result.start.toString());
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

  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("Booking");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF84A5FA),
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
                  // ignore: prefer_const_constructors
                  style: TextStyle(
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
              // ignore: sort_child_properties_last
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
              // ignore: sort_child_properties_last
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
              future: CalcuTaoatl(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
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
            Container(
              height: 20,
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      // ignore: sort_child_properties_last
                      child: InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 20, left: 20, bottom: 30),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84A5FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ignore: prefer_const_constructors
                          child: Center(
                            child: Text(getTranslated(context, "close")),
                          ),
                        ),
                        onTap: () async {},
                      ),
                      flex: 2,
                    ),
                    // ignore: sort_child_properties_last
                    Expanded(
                      // ignore: sort_child_properties_last
                      child: InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 20, left: 20, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84A5FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ignore: prefer_const_constructors
                          child: Center(
                            child: Text(getTranslated(context, "booking")),
                          ),
                        ),
                        onTap: () async {
                          String? date = _selectedDateRange?.start
                              .toString()
                              .split(" ")[0];
                          DatabaseReference ref = FirebaseDatabase.instance
                              .ref("App")
                              .child("Booking");
                          print(date);
                          String formatdate = date!.replaceAll("-", "");
                          String? id = FirebaseAuth.instance.currentUser?.uid;

                          String IDBook = (Estate['IDEstate'].toString() +
                              formatdate +
                              id!);
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          await ref.child("Book").child(IDBook.toString()).set({
                            "IDEstate": Estate['IDEstate'].toString(),
                            "IDBook": IDBook,
                            "NameEn": Estate['NameEn'],
                            "NameAr": Estate['NameAr'],
                            "Status": "1",
                            "IDUser": id,
                            "IDOwner": Estate['IDUser'],
                            "StartDate": _selectedDateRange?.start.toString(),
                            "EndDate": _selectedDateRange?.end.toString(),
                            "Type": Estate['Type'],
                            "Country": Estate["Country"],
                            "State": Estate["State"],
                            "City": Estate["City"],
                            "NameUser": sharedPreferences.getString("Name"),
                            "NetTotal": netTotal.toString(),
                            "read": "0",
                            "readuser": "0"
                          });

                          for (var element in LstRooms) {
                            if (element.id == "1") {
                              await refRooms
                                  .child(IDBook.toString())
                                  .child("Single")
                                  .set({
                                "ID": "1",
                                "Name": "Single",
                                "Price": element.price,
                                "BioAr": element.bio,
                                "BioEn": element.bioEn,
                              });
                            }
                            if (element.id == "2") {
                              await refRooms
                                  .child(IDBook.toString())
                                  .child("Double")
                                  .set({
                                "ID": "2",
                                "Name": "Double",
                                "Price": element.price,
                                "BioAr": element.bio,
                                "BioEn": element.bioEn,
                              });
                            }
                            if (element.id == "3") {
                              await refRooms
                                  .child(IDBook.toString())
                                  .child("Swite")
                                  .set({
                                "ID": "3",
                                "Name": "Swite",
                                "Price": element.price,
                                "BioAr": element.bio,
                                "BioEn": element.bioEn,
                              });
                            }
                            if (element.id == "4") {
                              await refRooms
                                  .child(IDBook.toString())
                                  .child("Family")
                                  .set({
                                "ID": "4",
                                "Name": "Family",
                                "Price": element.price,
                                "BioAr": element.bio,
                                "BioEn": element.bioEn,
                              });
                            }
                          }
                          for (var element in LstAdditional) {
                            refAdd
                                .child(IDBook.toString())
                                .child(element.id)
                                .set({
                              "IDEstate": Estate['IDEstate'].toString(),
                              "IDBook": IDBook.toString(),
                              "NameEn": element.nameEn,
                              "NameAr": element.name,
                              "Price": element.price,
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
      // This button is used to show the date range picker
    );
  }

  Future<String> CalcuTaoatl() async {
    double TotalDayofRomm = 0;
    double TotalDayofAdditional = 0;

    for (int i = 0; i < LstRooms.length; i++) {
      TotalDayofRomm += (double.parse(LstRooms[i].price) *
          double.parse(countofday.toString()));
    }
    for (int i = 0; i < LstAdditional.length; i++) {
      TotalDayofAdditional += (double.parse(LstAdditional[i].price));
    }
    netTotal = TotalDayofRomm + TotalDayofAdditional;
    return TotalDayofRomm.toString() +
        "\n" +
        TotalDayofAdditional.toString() +
        "\n" +
        netTotal.toString();
  }
}
