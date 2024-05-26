// ignore_for_file: non_constant_identifier_names

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/page/qrViewScan.dart';
import 'package:diamond_booking/page/qr_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/rooms.dart';
import './chat.dart';
import 'add_posts.dart';
import 'additionalfacility.dart';
import 'chat_group.dart';
import 'editEstate.dart';

// import 'package:flutter/material.dart';
// class ProfileEstate extends StatefulWidget {
//   const ProfileEstate({super.key});
//
//   @override
//   State<ProfileEstate> createState() => _ProfileEstateState();
// }
//
// class _ProfileEstateState extends State<ProfileEstate> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

class ProfileEstate extends StatefulWidget {
  Map estate;
  String icon;
  bool VisEdit;

  ProfileEstate(
      {super.key,
      required this.estate,
      required this.icon,
      required this.VisEdit});
  @override
  _State createState() => _State(estate, icon, VisEdit);
}

class _State extends State<ProfileEstate> {
  Map estate;
  String icon;
  bool VisEdit;
  late Map mapRoom;
  List<Rooms> LstRooms = [];
  List<Rooms> LstRoomsSelected = [];

  _State(this.estate, this.icon, this.VisEdit);
  int count = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    getData();
    super.initState();
  }

  String ID = "";
  String TypUser = "";
  String checkGroup = "";
  final storageRef = FirebaseStorage.instance.ref();
  getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      ID = sharedPreferences.getString("ID")!;
      TypUser = sharedPreferences.getString("Typ")!;
      checkGroup =
          sharedPreferences.getString(estate['IDEstate'].toString()) ?? "0";
    });
  }

  _launchMaps() async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${estate['Lat']},${estate['Lon']}';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay? sTime = TimeOfDay?.now();

  Future<List<String>> listPhotos(String EID) async {
    List<String> LstImage = [];
    final result = await FirebaseStorage.instance.ref().child(EID).listAll();
    var Ref = await FirebaseStorage.instance.ref();
    for (Ref in result.items) {
      String url =
          await FirebaseStorage.instance.ref(Ref.fullPath).getDownloadURL();
      LstImage.add(url);
    }
    return LstImage;
  }

  Future<String> splitText(String data) async {
    String text = "";
    List<String> Lst = data.split(",");
    for (int i = 0; i < Lst.length; i++) {
      if (i == 0) {
        setState(() {
          text = getTranslated(context, Lst[i]);
        });
      } else {
        setState(() {
          text = text + " ," + getTranslated(context, Lst[i]);
        });
      }
    }
    return text;
  }

  Query query = FirebaseDatabase.instance.ref("App").child("Rooms");
  Future<String> getimages(String EID, String id) async {
    try {
      String imageUrl;
      imageUrl = await storageRef
          .child("Post")
          .child(EID + ".jpg")
          .child(id)
          .getDownloadURL()
          .onError((error, stackTrace) => '')
          .then((value) => value);
      print(imageUrl.toString());
      return imageUrl.toString();
    } catch (e) {
      return "";
    }
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: true);
    return Scaffold(
        key: _scaffoldKey1,
        // floatingActionButton: Visibility(
        //   // ignore: sort_child_properties_last
        //   child: FloatingActionButton(
        //     onPressed: () {
        //       print(LstRooms.length.toString());
        //       Navigator.of(context).push(MaterialPageRoute(
        //           builder: (context) => EditEstate(
        //                 objEstate: estate,
        //                 LstRooms: LstRooms,
        //               )));
        //     },
        //     backgroundColor: kPrimaryColor,
        //     child: const Icon(Icons.edit),
        //   ),
        //   visible: VisEdit,
        // ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          actions: [
            InkWell(
              child: const Icon(Icons.edit),
              onTap: () {
                print(LstRooms.length.toString());
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditEstate(
                          objEstate: estate,
                          LstRooms: LstRooms,
                        )));
              },
            ),
            Container(
              width: 25,
            ),
            InkWell(
              child: Icon(Icons.message),
              onTap: () {
                if (ID != "null") {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Chat(
                            idEstate: estate['IDEstate'].toString(),
                            Name: estate['NameEn'],
                            Key: estate['IDUser'],
                          )));
                } else {
                  objProvider.FunSnackBarPage(
                      getTranslated(context, "Please login first"), context);
                }
              },
            ),
            Container(
              width: 25,
            ),
            InkWell(
              child: Icon(Icons.map_outlined),
              onTap: () {
                if (ID != "null") {
                  _launchMaps();
                } else {
                  objProvider.FunSnackBarPage(
                      getTranslated(context, "Please login first"), context);
                }
              },
            ),
            Container(
              width: 25,
            ),
            Visibility(
              visible: TypUser == "3" || TypUser == "4",
              child: InkWell(
                child: Icon(Icons.qr_code),
                onTap: () async {
                  if (ID != "null") {
                    final result =
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => QRViewScan(
                                  ID: estate['IDEstate'].toString(),
                                )));
                    if (result) {
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      sharedPreferences.setString(
                          estate['IDEstate'].toString(), "1");
                      setState(() {
                        checkGroup = "1";
                      });
                    }
                  } else {
                    objProvider.FunSnackBarPage(
                        getTranslated(context, "Please login first"), context);
                  }
                },
              ),
            ),
            Container(
              width: 25,
            ),
            Visibility(
              visible: checkGroup == "1",
              child: InkWell(
                child: Icon(Icons.group),
                onTap: () async {
                  if (ID != "null") {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatGroup(
                              idEstate: estate['IDEstate'].toString(),
                              Name: estate['NameEn'],
                              Key: estate['IDUser'],
                            )));
                  } else {
                    objProvider.FunSnackBarPage(
                        getTranslated(context, "Please login first"), context);
                  }
                },
              ),
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
              child: Stack(
            children: [
              ListView(
                children: [
                  Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    // ignore: sort_child_properties_last
                    child: FutureBuilder<List<String>?>(
                      future: listPhotos(estate['IDEstate'].toString()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: Image(
                                    image: NetworkImage(snapshot.data![index]),
                                    fit: BoxFit.fitWidth),
                              );
                            },
                          );
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

                    color: kPrimaryColor,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: ListTile(
                      title: Text(
                        objProvider.CheckLangValue
                            ? estate["NameEn"]
                            : estate["NameAr"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        estate["Country"] + " \ " + estate["State"],
                        // ignore: prefer_const_constructors
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black),
                      ),
                      leading: Container(
                          width: 60,
                          height: 60,
                          // ignore: prefer_const_constructors
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            // ignore: prefer_const_literals_to_create_immutables
                            boxShadow: [
                              // ignore: prefer_const_constructors
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.grey,
                                  spreadRadius: 1)
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image(
                              image: AssetImage(icon),
                              width: 35,
                              height: 35,
                            ),
                          )),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Text(
                        objProvider.CheckLangValue
                            ? estate["BioEn"]
                            : estate["BioAr"],
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )),
                  Visibility(
                      visible: estate["Type"] == "1" ? true : false,
                      child: TextHedar("Rooms")),
                  Visibility(
                      visible: estate["Type"] == "1",
                      child: Container(
                        child: FirebaseAnimatedList(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          defaultChild: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          itemBuilder: (context, snapshot, animation, index) {
                            Map map = snapshot.value as Map;

                            map['Key'] = snapshot.key;

                            LstRooms.add(Rooms(
                                id: map['ID'],
                                name: map['Name'],
                                nameEn: map['Name'],
                                price: map['Price'],
                                bio: map['BioAr'],
                                bioEn: map['BioEn'],
                                color: Colors.white));

                            //----------------------------
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 70,
                              color: LstRooms[index].color,
                              child: ListTile(
                                title: Text(getTranslated(
                                    context, LstRooms[index].name)),
                                subtitle: Text(objProvider.CheckLangValue
                                    ? LstRooms[index].bioEn
                                    : LstRooms[index].bio),
                                // ignore: prefer_const_constructors
                                leading: Icon(
                                  Icons.single_bed,
                                  color: Color(0xFF84A5FA),
                                ),
                                trailing: Text(
                                  LstRooms[index].price,
                                  // ignore: prefer_const_constructors
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 18),
                                ),
                                onTap: () async {
                                  int indx = LstRoomsSelected.indexWhere(
                                      (element) => element.name == map['Name']);
                                  print(indx);
                                  if (indx == -1) {
                                    print(map['ID']);
                                    LstRoomsSelected.add(Rooms(
                                        id: map['ID'],
                                        name: map['Name'],
                                        nameEn: map['Name'],
                                        price: map['Price'],
                                        bio: map['BioAr'],
                                        bioEn: map['BioEn'],
                                        color: Colors.white));
                                    setState(() {
                                      LstRooms[index].color = Colors.blue;
                                      count++;
                                    });
                                  } else {
                                    LstRoomsSelected.removeAt(indx);
                                    setState(() {
                                      LstRooms[index].color = Colors.white;
                                      count--;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                          query: FirebaseDatabase.instance
                              .ref("App")
                              .child("Rooms")
                              .child(estate['IDEstate'].toString()),
                        ),
                      )),
                  /////////////////////////////////////////Restaurant&Coffee
                  Visibility(
                      visible: estate["Type"] == "2" || estate["Type"] == "3",
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                              visible: estate["Type"] == "3",
                              child: ListTile(
                                title: Text(
                                  getTranslated(context, "Type of Restaurant"),
                                  style: TextStyle(fontSize: 14),
                                ),
                                subtitle: FutureBuilder<String>(
                                  future: splitText(
                                      estate["TypeofRestaurant"].toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.connectionState ==
                                            ConnectionState.done) {
                                      return Text(
                                        snapshot.data.toString(),
                                        style: TextStyle(fontSize: 12),
                                      );
                                    }
                                    // ignore: prefer_const_constructors
                                    return Center(
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              )),
                          Visibility(
                              visible: estate["Type"] == "2" ||
                                  estate["Type"] == "3",
                              child: ListTile(
                                title: Text(
                                  getTranslated(context, "Entry allowed"),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: FutureBuilder<String>(
                                  future: splitText(estate["Entry"].toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.connectionState ==
                                            ConnectionState.done) {
                                      return Text(
                                        snapshot.data.toString(),
                                        style: TextStyle(fontSize: 12),
                                      );
                                    }
                                    // ignore: prefer_const_constructors
                                    return Center(
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              )),
                          Visibility(
                              visible: estate["Type"] == "2" ||
                                  estate["Type"] == "3",
                              child: ListTile(
                                title: Text(
                                  getTranslated(context, "Sessions type"),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: FutureBuilder<String>(
                                  future:
                                      splitText(estate["Sessions"].toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.connectionState ==
                                            ConnectionState.done) {
                                      return Text(
                                        snapshot.data.toString(),
                                        style: TextStyle(fontSize: 12),
                                      );
                                    }
                                    // ignore: prefer_const_constructors
                                    return Center(
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              )),
                          Visibility(
                              visible: estate["Type"] == "3",
                              child: ListTile(
                                title: Text(
                                  getTranslated(
                                      context,
                                      estate["Music"] == "1"
                                          ? "There is music"
                                          : "There is no music"),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )),
                          Visibility(
                              visible: estate["Type"] == "2",
                              child: ListTile(
                                title: Text(
                                  getTranslated(context, "Is there music"),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  estate["Lstmusic"],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )),
                        ],
                      )),
                  Container(
                    // ignore: sort_child_properties_last
                    child: const Text(
                      "Post",
                      style: TextStyle(fontSize: 14),
                    ),
                    margin: const EdgeInsets.only(left: 35, right: 35),
                  ),
                  FirebaseAnimatedList(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    defaultChild: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    itemBuilder: (context, snapshot, animation, index) {
                      Map map = snapshot.value as Map;
                      if (map["Type"] == "1") {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(map["Text"]),
                                subtitle: Text(map["Date"]),
                              ),
                              FutureBuilder<String>(
                                future: getimages(estate['IDEstate'].toString(),
                                    map["IDPost"]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: snapshot.data != ""
                                          ? Image(
                                              image:
                                                  NetworkImage(snapshot.data!),
                                              fit: BoxFit.cover)
                                          : Container(),
                                    );
                                  }

                                  return Center(
                                    child: const CircularProgressIndicator(),
                                  );
                                },
                              ),
                              Visibility(
                                  visible: VisEdit,
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            child: Container(
                                              width: 150.w,
                                              height: 6.h,
                                              margin: const EdgeInsets.only(
                                                  right: 40,
                                                  left: 40,
                                                  bottom: 20),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              // ignore: prefer_const_constructors
                                              child: Center(
                                                  child: Text(getTranslated(
                                                      context, "delete"))),
                                            ),
                                            onTap: () {
                                              FirebaseDatabase.instance
                                                  .ref("App")
                                                  .child("Post")
                                                  .child(estate['IDEstate']
                                                      .toString())
                                                  .child(map["IDPost"])
                                                  .remove();
                                            },
                                          ),
                                        ],
                                      ))),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                    query: FirebaseDatabase.instance
                        .ref("App")
                        .child("Post")
                        .child(estate['IDEstate'].toString())
                        .orderByChild("Date"),
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                ],
              ),
              Visibility(
                visible: VisEdit,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 40, left: 40, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84A5FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ignore: prefer_const_constructors
                          child: Center(
                              child: Text(getTranslated(context, "Post"))),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddPost(
                                map: estate,
                              ),
                            ),
                          );
                        },
                      ),
                      InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 40, left: 40, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84A5FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ignore: prefer_const_constructors
                          child: Center(
                              child: Text(
                                  getTranslated(context, "GenerateQRCode"))),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  QRImage(estate['IDEstate'].toString())));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: !VisEdit,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      child: Container(
                        width: 150.w,
                        height: 6.h,
                        margin: const EdgeInsets.only(
                            right: 40, left: 40, bottom: 20),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // ignore: prefer_const_constructors
                        child: Center(
                            child: Text(
                          getTranslated(context, "Next"),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )),
                      ),
                      onTap: () async {
                        if (ID != "null") {
                          if (estate['Type'] == "1") {
                            if (LstRoomsSelected.length == 0) {
                              objProvider.FunSnackBarPage(
                                  "Choees Room Befor", context);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AdditionalFacility(
                                        CheckState: "",
                                        CheckIsBooking: true,
                                        estate: estate,
                                        IDEstate: estate['IDEstate'].toString(),
                                        Lstroom: LstRoomsSelected,
                                      )));
                            }
                          } else {
                            await _selectDate(context);
                            // ignore: use_build_context_synchronously
                            await selectTime(context);
                            DatabaseReference ref = FirebaseDatabase.instance
                                .ref("App")
                                .child("Booking");

                            String? id = FirebaseAuth.instance.currentUser?.uid;
                            if (flagDate && flagTime) {
                              String? hour = sTime?.hour.toString();
                              String? minute = sTime?.minute.toString();
                              String IDBook = (estate['IDEstate'].toString() +
                                  selectedDate.toString().split(" ")[0] +
                                  id!);
                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              await ref
                                  .child("Book")
                                  .child(IDBook.toString())
                                  .set({
                                "IDEstate": estate['IDEstate'].toString(),
                                "IDBook": IDBook,
                                "NameEn": estate['NameEn'],
                                "NameAr": estate['NameAr'],
                                "Status": "1",
                                "IDUser": id,
                                "IDOwner": estate['IDUser'],
                                "StartDate":
                                    "${selectedDate.year}-${selectedDate.month}-${selectedDate.day} ${hour!}:${minute!}",
                                "EndDate": "",
                                "Type": estate['Type'],
                                "Country": estate["Country"],
                                "State": estate["State"],
                                "City": estate["City"],
                                "NameUser": estate["FirstName"],
                              });
                              // ignore: use_build_context_synchronously
                              objProvider.FunSnackBarPage(
                                  // ignore: use_build_context_synchronously
                                  getTranslated(context, "Successfully"),
                                  context);
                            }
                          }
                        } else {
                          objProvider.FunSnackBarPage(
                              getTranslated(context, "Please login first"),
                              context);
                        }
                      },
                    ),
                  )),
            ],
          )),
        ));
  }

  bool flagDate = false;
  bool flagTime = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime.now().subtract(new Duration(days: 0)),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        flagDate = true;
      });
    }
  }

  selectTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      initialTime: sTime!,
      context: context,
    );
    if (selectedTime != null && selectedTime != sTime) {
      setState(() {
        sTime = selectedTime;
        flagTime = true;
      });
    }
  }

  TextHedar(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 10),
      child: Text(
        getTranslated(context, text),
        // ignore: prefer_const_constructors
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
    );
  }
}
