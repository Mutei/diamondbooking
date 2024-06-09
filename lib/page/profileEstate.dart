// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/page/qrViewScan.dart';
// import 'package:diamond_booking/page/qr_image.dart';
// import 'package:diamond_booking/widgets/text_header.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import '../models/rooms.dart';
// import './chat.dart';
// import 'add_posts.dart';
// import 'additionalfacility.dart';
// import 'chat_group.dart';
// import 'editEstate.dart';
//
// class ProfileEstate extends StatefulWidget {
//   Map estate;
//   String icon;
//   bool VisEdit;
//
//   ProfileEstate(
//       {super.key,
//       required this.estate,
//       required this.icon,
//       required this.VisEdit});
//   @override
//   _ProfileEstateState createState() =>
//       _ProfileEstateState(estate, icon, VisEdit);
// }
//
// class _ProfileEstateState extends State<ProfileEstate> {
//   Map estate;
//   String icon;
//   bool VisEdit;
//   late Map mapRoom;
//   List<Rooms> LstRooms = [];
//   List<Rooms> LstRoomsSelected = [];
//
//   _ProfileEstateState(this.estate, this.icon, this.VisEdit);
//   int count = 0;
//   String ID = "";
//   String TypUser = "";
//   String checkGroup = "";
//   final storageRef = FirebaseStorage.instance.ref();
//   bool flagDate = false;
//   bool flagTime = false;
//   final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
//   final databaseRef = FirebaseDatabase.instance.ref();
//   String userType = "2";
//
//   @override
//   void initState() {
//     getData();
//     fetchUserType();
//     super.initState();
//   }
//
//   Future<void> fetchUserType() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         String uid = user.uid;
//         DatabaseReference userTypeRef =
//             databaseRef.child('App/User/$uid/TypeUser');
//         DataSnapshot snapshot = await userTypeRef.get();
//         if (snapshot.exists) {
//           setState(() {
//             userType = snapshot.value.toString();
//           });
//           print("The usertype in profile estate is: $userType");
//         } else {
//           print("User Type not found");
//         }
//       } else {
//         print("User not logged in");
//       }
//     } catch (e) {
//       print("Failed to fetch user type: $e");
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         flagDate = true;
//       });
//     }
//   }
//
//   Future<void> selectTime(BuildContext context) async {
//     final selectedTime = await showTimePicker(
//       initialTime: sTime!,
//       context: context,
//     );
//     if (selectedTime != null && selectedTime != sTime) {
//       setState(() {
//         sTime = selectedTime;
//         flagTime = true;
//       });
//     }
//   }
//
//   getData() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     setState(() {
//       ID = sharedPreferences.getString("ID") ?? "";
//       TypUser = sharedPreferences.getString("Typ") ?? "";
//       checkGroup =
//           sharedPreferences.getString(estate['IDEstate'].toString()) ?? "0";
//     });
//
//     if (ID.isNotEmpty) {
//       DatabaseReference userRef =
//           FirebaseDatabase.instance.ref("App").child("User").child(ID);
//       DataSnapshot snapshot = await userRef.get();
//
//       if (snapshot.exists) {
//         setState(() {
//           estate["FirstName"] =
//               snapshot.child("FirstName").value as String? ?? "";
//           estate["SecondName"] =
//               snapshot.child("SecondName").value as String? ?? "";
//           estate["LastName"] =
//               snapshot.child("LastName").value as String? ?? "";
//         });
//       }
//     }
//   }
//
//   _launchMaps() async {
//     String googleUrl =
//         'https://www.google.com/maps/search/?api=1&query=${estate['Lat']},${estate['Lon']}';
//     if (await canLaunch(googleUrl)) {
//       await launch(googleUrl);
//     } else {
//       throw 'Could not open the map.';
//     }
//   }
//
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay? sTime = TimeOfDay?.now();
//
//   Future<List<String>> listPhotos(String EID) async {
//     List<String> LstImage = [];
//     final result = await FirebaseStorage.instance.ref().child(EID).listAll();
//     var Ref = await FirebaseStorage.instance.ref();
//     for (Ref in result.items) {
//       String url =
//           await FirebaseStorage.instance.ref(Ref.fullPath).getDownloadURL();
//       LstImage.add(url);
//     }
//     return LstImage;
//   }
//
//   Future<String> splitText(String data) async {
//     String text = "";
//     List<String> Lst = data.split(",");
//     for (int i = 0; i < Lst.length; i++) {
//       if (i == 0) {
//         setState(() {
//           text = getTranslated(context, Lst[i]);
//         });
//       } else {
//         setState(() {
//           text = text + " ," + getTranslated(context, Lst[i]);
//         });
//       }
//     }
//     return text;
//   }
//
//   Query query = FirebaseDatabase.instance.ref("App").child("Rooms");
//
//   Future<String> getimages(String EID, String id) async {
//     try {
//       String imageUrl;
//       imageUrl = await storageRef
//           .child("Post")
//           .child(EID + ".jpg")
//           .child(id)
//           .getDownloadURL()
//           .onError((error, stackTrace) => '')
//           .then((value) => value);
//       print(imageUrl.toString());
//       return imageUrl.toString();
//     } catch (e) {
//       return "";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final objProvider = Provider.of<GeneralProvider>(context, listen: true);
//     return Scaffold(
//       key: _scaffoldKey1,
//       appBar: userType == '2'
//           ? AppBar(
//               elevation: 0,
//               backgroundColor: kPrimaryColor,
//               actions: [
//                 InkWell(
//                   child: const Icon(Icons.edit),
//                   onTap: () {
//                     print(LstRooms.length.toString());
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => EditEstate(
//                               objEstate: estate,
//                               LstRooms: LstRooms,
//                             )));
//                   },
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 InkWell(
//                   child: Icon(Icons.message),
//                   onTap: () {
//                     if (ID != "null") {
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => Chat(
//                                 idEstate: estate['IDEstate'].toString(),
//                                 Name: estate['NameEn'],
//                                 Key: estate['IDUser'],
//                               )));
//                     } else {
//                       objProvider.FunSnackBarPage(
//                           getTranslated(context, "Please login first"),
//                           context);
//                     }
//                   },
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 InkWell(
//                   child: Icon(Icons.map_outlined),
//                   onTap: () {
//                     if (ID != "null") {
//                       _launchMaps();
//                     } else {
//                       objProvider.FunSnackBarPage(
//                           getTranslated(context, "Please login first"),
//                           context);
//                     }
//                   },
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 Visibility(
//                   visible: TypUser == "3" || TypUser == "4",
//                   child: InkWell(
//                     child: Icon(Icons.qr_code),
//                     onTap: () async {
//                       if (ID != "null") {
//                         final result =
//                             await Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => QRViewScan(
//                                       ID: estate['IDEstate'].toString(),
//                                     )));
//                         if (result) {
//                           SharedPreferences sharedPreferences =
//                               await SharedPreferences.getInstance();
//                           sharedPreferences.setString(
//                               estate['IDEstate'].toString(), "1");
//                           setState(() {
//                             checkGroup = "1";
//                           });
//                         }
//                       } else {
//                         objProvider.FunSnackBarPage(
//                             getTranslated(context, "Please login first"),
//                             context);
//                       }
//                     },
//                   ),
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 Visibility(
//                   visible: checkGroup == "1",
//                   child: InkWell(
//                     child: Icon(Icons.group),
//                     onTap: () async {
//                       if (ID != "null") {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => ChatGroup(
//                                   idEstate: estate['IDEstate'].toString(),
//                                   Name: estate['NameEn'],
//                                   Key: estate['IDUser'],
//                                 )));
//                       } else {
//                         objProvider.FunSnackBarPage(
//                             getTranslated(context, "Please login first"),
//                             context);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             )
//           : AppBar(
//               elevation: 0,
//               backgroundColor: kPrimaryColor,
//               actions: [
//                 Container(
//                   width: 25,
//                 ),
//                 InkWell(
//                   child: Icon(Icons.message),
//                   onTap: () {
//                     if (ID != "null") {
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => Chat(
//                                 idEstate: estate['IDEstate'].toString(),
//                                 Name: estate['NameEn'],
//                                 Key: estate['IDUser'],
//                               )));
//                     } else {
//                       objProvider.FunSnackBarPage(
//                           getTranslated(context, "Please login first"),
//                           context);
//                     }
//                   },
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 InkWell(
//                   child: Icon(Icons.map_outlined),
//                   onTap: () {
//                     if (ID != "null") {
//                       _launchMaps();
//                     } else {
//                       objProvider.FunSnackBarPage(
//                           getTranslated(context, "Please login first"),
//                           context);
//                     }
//                   },
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 Visibility(
//                   visible: TypUser == "3" || TypUser == "4",
//                   child: InkWell(
//                     child: Icon(Icons.qr_code),
//                     onTap: () async {
//                       if (ID != "null") {
//                         final result =
//                             await Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => QRViewScan(
//                                       ID: estate['IDEstate'].toString(),
//                                     )));
//                         if (result) {
//                           SharedPreferences sharedPreferences =
//                               await SharedPreferences.getInstance();
//                           sharedPreferences.setString(
//                               estate['IDEstate'].toString(), "1");
//                           setState(() {
//                             checkGroup = "1";
//                           });
//                         }
//                       } else {
//                         objProvider.FunSnackBarPage(
//                             getTranslated(context, "Please login first"),
//                             context);
//                       }
//                     },
//                   ),
//                 ),
//                 Container(
//                   width: 25,
//                 ),
//                 Visibility(
//                   visible: checkGroup == "1",
//                   child: InkWell(
//                     child: Icon(Icons.group),
//                     onTap: () async {
//                       if (ID != "null") {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => ChatGroup(
//                                   idEstate: estate['IDEstate'].toString(),
//                                   Name: estate['NameEn'],
//                                   Key: estate['IDUser'],
//                                 )));
//                       } else {
//                         objProvider.FunSnackBarPage(
//                             getTranslated(context, "Please login first"),
//                             context);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: SafeArea(
//           child: Stack(
//             children: [
//               ListView(
//                 children: [
//                   Container(
//                     height: 250,
//                     width: MediaQuery.of(context).size.width,
//                     child: FutureBuilder<List<String>?>(
//                       future: listPhotos(estate['IDEstate'].toString()),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData &&
//                             snapshot.connectionState == ConnectionState.done) {
//                           return ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: snapshot.data!.length,
//                             itemBuilder: (context, index) {
//                               return Container(
//                                 width: MediaQuery.of(context).size.width,
//                                 child: Image(
//                                     image: NetworkImage(snapshot.data![index]),
//                                     fit: BoxFit.fitWidth),
//                               );
//                             },
//                           );
//                         }
//                         return SizedBox(
//                           width: 50,
//                           height: 50,
//                           child: const Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                         );
//                       },
//                     ),
//                     color: kPrimaryColor,
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 10, right: 10),
//                     child: ListTile(
//                       title: Text(
//                         objProvider.CheckLangValue
//                             ? estate["NameEn"]
//                             : estate["NameAr"],
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       subtitle: Text(
//                         estate["Country"] + " \\ " + estate["State"],
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             color: Colors.black),
//                       ),
//                       leading: Container(
//                         width: 60,
//                         height: 60,
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                                 blurRadius: 10,
//                                 color: Colors.grey,
//                                 spreadRadius: 1)
//                           ],
//                         ),
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           child: Image(
//                             image: AssetImage(icon),
//                             width: 35,
//                             height: 35,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 35, right: 35),
//                     child: Text(
//                       objProvider.CheckLangValue
//                           ? estate["BioEn"]
//                           : estate["BioAr"],
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ),
//                   Visibility(
//                     visible: estate["Type"] == "1" ? true : false,
//                     child: TextHeader("Rooms", context),
//                   ),
//                   Visibility(
//                     visible: estate["Type"] == "1",
//                     child: Container(
//                       child: FirebaseAnimatedList(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         defaultChild: const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                         itemBuilder: (context, snapshot, animation, index) {
//                           Map map = snapshot.value as Map;
//
//                           map['Key'] = snapshot.key;
//
//                           LstRooms.add(Rooms(
//                               id: map['ID'],
//                               name: map['Name'],
//                               nameEn: map['Name'],
//                               price: map['Price'],
//                               bio: map['BioAr'],
//                               bioEn: map['BioEn'],
//                               color: Colors.white));
//
//                           return Container(
//                             width: MediaQuery.of(context).size.width,
//                             height: 70,
//                             color: LstRooms[index].color,
//                             child: ListTile(
//                               title: Text(
//                                   getTranslated(context, LstRooms[index].name)),
//                               subtitle: Text(objProvider.CheckLangValue
//                                   ? LstRooms[index].bioEn
//                                   : LstRooms[index].bio),
//                               leading: const Icon(
//                                 Icons.single_bed,
//                                 color: Color(0xFF84A5FA),
//                               ),
//                               trailing: Text(
//                                 LstRooms[index].price,
//                                 style: const TextStyle(
//                                     color: Colors.green, fontSize: 18),
//                               ),
//                               onTap: () async {
//                                 int index = LstRoomsSelected.indexWhere(
//                                     (element) => element.name == map['Name']);
//                                 if (index == -1) {
//                                   LstRoomsSelected.add(Rooms(
//                                       id: map['ID'],
//                                       name: map['Name'],
//                                       nameEn: map['Name'],
//                                       price: map['Price'],
//                                       bio: map['BioAr'],
//                                       bioEn: map['BioEn'],
//                                       color: Colors.white));
//                                   setState(() {
//                                     LstRooms[index].color = Colors.blue;
//                                     count++;
//                                   });
//                                 } else {
//                                   LstRoomsSelected.removeAt(index);
//                                   setState(() {
//                                     LstRooms[index].color = Colors.white;
//                                     count--;
//                                   });
//                                 }
//                               },
//                             ),
//                           );
//                         },
//                         query: FirebaseDatabase.instance
//                             .ref("App")
//                             .child("Rooms")
//                             .child(estate['IDEstate'].toString()),
//                       ),
//                     ),
//                   ),
//                   Visibility(
//                     visible: estate["Type"] == "2" || estate["Type"] == "3",
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Visibility(
//                           visible: estate["Type"] == "3",
//                           child: ListTile(
//                             title: Text(
//                               getTranslated(context, "Type of Restaurant"),
//                               style: TextStyle(fontSize: 14),
//                             ),
//                             subtitle: FutureBuilder<String>(
//                               future: splitText(
//                                   estate["TypeofRestaurant"].toString()),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData &&
//                                     snapshot.connectionState ==
//                                         ConnectionState.done) {
//                                   return Text(
//                                     snapshot.data.toString(),
//                                     style: TextStyle(fontSize: 12),
//                                   );
//                                 }
//                                 return Center(
//                                   child: const CircularProgressIndicator(),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Visibility(
//                           visible:
//                               estate["Type"] == "2" || estate["Type"] == "3",
//                           child: ListTile(
//                             title: Text(
//                               getTranslated(context, "Entry allowed"),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                             subtitle: FutureBuilder<String>(
//                               future: splitText(estate["Entry"].toString()),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData &&
//                                     snapshot.connectionState ==
//                                         ConnectionState.done) {
//                                   return Text(
//                                     snapshot.data.toString(),
//                                     style: TextStyle(fontSize: 12),
//                                   );
//                                 }
//                                 return Center(
//                                   child: const CircularProgressIndicator(),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Visibility(
//                           visible:
//                               estate["Type"] == "2" || estate["Type"] == "3",
//                           child: ListTile(
//                             title: Text(
//                               getTranslated(context, "Sessions type"),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                             subtitle: FutureBuilder<String>(
//                               future: splitText(estate["Sessions"].toString()),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData &&
//                                     snapshot.connectionState ==
//                                         ConnectionState.done) {
//                                   return Text(
//                                     snapshot.data.toString(),
//                                     style: TextStyle(fontSize: 12),
//                                   );
//                                 }
//                                 return Center(
//                                   child: const CircularProgressIndicator(),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Visibility(
//                           visible: estate["Type"] == "3",
//                           child: ListTile(
//                             title: Text(
//                               getTranslated(
//                                   context,
//                                   estate["Music"] == "1"
//                                       ? "There is music"
//                                       : "There is no music"),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//                         Visibility(
//                           visible: estate["Type"] == "2",
//                           child: ListTile(
//                             title: Text(
//                               getTranslated(context, "Is there music"),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                             subtitle: Text(
//                               estate["Lstmusic"],
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     child: const Text(
//                       "Post",
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     margin: const EdgeInsets.only(left: 35, right: 35),
//                   ),
//                   FirebaseAnimatedList(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     defaultChild: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                     itemBuilder: (context, snapshot, animation, index) {
//                       Map map = snapshot.value as Map;
//                       if (map["Type"] == "1") {
//                         return Container(
//                           width: MediaQuery.of(context).size.width,
//                           child: Column(
//                             children: [
//                               ListTile(
//                                 title: Text(map["Text"]),
//                                 subtitle: Text(map["Date"]),
//                               ),
//                               FutureBuilder<String>(
//                                 future: getimages(estate['IDEstate'].toString(),
//                                     map["IDPost"]),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData &&
//                                       snapshot.connectionState ==
//                                           ConnectionState.done) {
//                                     return Container(
//                                       width: MediaQuery.of(context).size.width,
//                                       child: snapshot.data != ""
//                                           ? Image(
//                                               image:
//                                                   NetworkImage(snapshot.data!),
//                                               fit: BoxFit.cover)
//                                           : Container(),
//                                     );
//                                   }
//
//                                   return Center(
//                                     child: const CircularProgressIndicator(),
//                                   );
//                                 },
//                               ),
//                               Visibility(
//                                 visible: VisEdit,
//                                 child: Align(
//                                   alignment: Alignment.bottomCenter,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       InkWell(
//                                         child: Container(
//                                           width: 150.w,
//                                           height: 6.h,
//                                           margin: const EdgeInsets.only(
//                                               right: 40, left: 40, bottom: 20),
//                                           decoration: BoxDecoration(
//                                             color: Colors.red,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               getTranslated(context, "delete"),
//                                             ),
//                                           ),
//                                         ),
//                                         onTap: () {
//                                           FirebaseDatabase.instance
//                                               .ref("App")
//                                               .child("Post")
//                                               .child(
//                                                   estate['IDEstate'].toString())
//                                               .child(map["IDPost"])
//                                               .remove();
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       } else {
//                         return Container();
//                       }
//                     },
//                     query: FirebaseDatabase.instance
//                         .ref("App")
//                         .child("Post")
//                         .child(estate['IDEstate'].toString())
//                         .orderByChild("Date"),
//                   ),
//                   const SizedBox(
//                     height: 150,
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: userType == '2',
//                 child: Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       InkWell(
//                         child: Container(
//                           width: 150.w,
//                           height: 6.h,
//                           margin: const EdgeInsets.only(
//                               right: 40, left: 40, bottom: 20),
//                           decoration: BoxDecoration(
//                             color: kPrimaryColor,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text(
//                               getTranslated(context, "Post"),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => AddPost(
//                                 map: estate,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       InkWell(
//                         child: Container(
//                           width: 150.w,
//                           height: 6.h,
//                           margin: const EdgeInsets.only(
//                               right: 40, left: 40, bottom: 20),
//                           decoration: BoxDecoration(
//                             color: kPrimaryColor,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text(
//                               getTranslated(context, "GenerateQRCode"),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) =>
//                                   QRImage(estate['IDEstate'].toString())));
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: userType == "1",
//                 child: Align(
//                   alignment: Alignment.bottomCenter,
//                   child: InkWell(
//                     child: Container(
//                       width: 150.w,
//                       height: 6.h,
//                       margin: const EdgeInsets.only(
//                           right: 40, left: 40, bottom: 20),
//                       decoration: BoxDecoration(
//                         color: kPrimaryColor,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Center(
//                         child: Text(
//                           getTranslated(context, "Next"),
//                           style: const TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     onTap: () async {
//                       if (ID != "null") {
//                         if (estate['Type'] == "1") {
//                           if (LstRoomsSelected.isEmpty) {
//                             objProvider.FunSnackBarPage(
//                                 "Choees Room Befor", context);
//                           } else {
//                             Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => AdditionalFacility(
//                                       CheckState: "",
//                                       CheckIsBooking: true,
//                                       estate: estate,
//                                       IDEstate: estate['IDEstate'].toString(),
//                                       Lstroom: LstRoomsSelected,
//                                     )));
//                           }
//                         } else {
//                           await _selectDate(context);
//                           await selectTime(context);
//                           DatabaseReference ref = FirebaseDatabase.instance
//                               .ref("App")
//                               .child("Booking");
//
//                           String? id = FirebaseAuth.instance.currentUser?.uid;
//                           if (flagDate && flagTime) {
//                             String? hour =
//                                 sTime?.hour.toString().padLeft(2, '0');
//                             String? minute =
//                                 sTime?.minute.toString().padLeft(2, '0');
//                             String IDBook = (estate['IDEstate'].toString() +
//                                 selectedDate.toString().split(" ")[0] +
//                                 id!);
//                             SharedPreferences sharedPreferences =
//                                 await SharedPreferences.getInstance();
//                             await ref
//                                 .child("Book")
//                                 .child(IDBook.toString())
//                                 .set({
//                               "IDEstate": estate['IDEstate'].toString(),
//                               "IDBook": IDBook,
//                               "NameEn": estate['NameEn'],
//                               "NameAr": estate['NameAr'],
//                               "Status": "1",
//                               "IDUser": id,
//                               "IDOwner": estate['IDUser'],
//                               "StartDate":
//                                   "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
//                               "Clock": "${hour!}:${minute!}",
//                               "EndDate": "",
//                               "Type": estate['Type'],
//                               "Country": estate["Country"],
//                               "State": estate["State"],
//                               "City": estate["City"],
//                               "NameUser":
//                                   "${estate['FirstName']} ${estate['SecondName']} ${estate['LastName']}",
//                             });
//                             objProvider.FunSnackBarPage(
//                                 getTranslated(context, "Successfully"),
//                                 context);
//                           }
//                         }
//                       } else {
//                         objProvider.FunSnackBarPage(
//                             getTranslated(context, "Please login first"),
//                             context);
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/page/qrViewScan.dart';
import 'package:diamond_booking/page/qr_image.dart';
import 'package:diamond_booking/widgets/text_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/rooms.dart';
import './chat.dart';
import 'add_posts.dart';
import 'additionalfacility.dart';
import 'chat_group.dart';
import 'editEstate.dart';

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
  _ProfileEstateState createState() =>
      _ProfileEstateState(estate, icon, VisEdit);
}

class _ProfileEstateState extends State<ProfileEstate> {
  Map estate;
  String icon;
  bool VisEdit;
  late Map mapRoom;
  List<Rooms> LstRooms = [];
  List<Rooms> LstRoomsSelected = [];

  _ProfileEstateState(this.estate, this.icon, this.VisEdit);

  int count = 0;
  String ID = "";
  String TypUser = "";
  String checkGroup = "";
  final storageRef = FirebaseStorage.instance.ref();
  bool flagDate = false;
  bool flagTime = false;
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  final databaseRef = FirebaseDatabase.instance.ref();
  String userType = "2";

  @override
  void initState() {
    getData();
    fetchUserType();
    super.initState();
  }

  Future<void> fetchUserType() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DatabaseReference userTypeRef =
            databaseRef.child('App/User/$uid/TypeUser');
        DataSnapshot snapshot = await userTypeRef.get();
        if (snapshot.exists) {
          setState(() {
            userType = snapshot.value.toString();
          });
          print("The usertype in profile estate is: $userType");
        } else {
          print("User Type not found");
        }
      } else {
        print("User not logged in");
      }
    } catch (e) {
      print("Failed to fetch user type: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        flagDate = true;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
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

  getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      ID = sharedPreferences.getString("ID") ?? "";
      TypUser = sharedPreferences.getString("Typ") ?? "";
      checkGroup =
          sharedPreferences.getString(estate['IDEstate'].toString()) ?? "0";
    });

    if (ID.isNotEmpty) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref("App").child("User").child(ID);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        setState(() {
          estate["FirstName"] =
              snapshot.child("FirstName").value as String? ?? "";
          estate["SecondName"] =
              snapshot.child("SecondName").value as String? ?? "";
          estate["LastName"] =
              snapshot.child("LastName").value as String? ?? "";
        });
      }
    }
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

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      print('Camera image selected: ${pickedFile.path}');
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: true);
    bool canEditEstate = userType == '2' && estate['IDUser'] == ID;
    return Scaffold(
      key: _scaffoldKey1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimaryColor,
        actions: [
          if (canEditEstate)
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
          if (canEditEstate) const SizedBox(width: 25),
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
          const SizedBox(width: 25),
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
          const SizedBox(width: 25),
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
          const SizedBox(width: 25),
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
          if (!canEditEstate)
            InkWell(
              child: Icon(Icons.camera_alt),
              onTap: () {
                _openCamera();
              },
            ),
          const SizedBox(width: 25),
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
                        return const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
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
                        estate["Country"] + " \\ " + estate["State"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black),
                      ),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
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
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 35, right: 35),
                    child: Text(
                      objProvider.CheckLangValue
                          ? estate["BioEn"]
                          : estate["BioAr"],
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  Visibility(
                    visible: estate["Type"] == "1",
                    child: TextHeader("Rooms", context),
                  ),
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

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            color: LstRooms[index].color,
                            child: ListTile(
                              title: Text(
                                  getTranslated(context, LstRooms[index].name)),
                              subtitle: Text(objProvider.CheckLangValue
                                  ? LstRooms[index].bioEn
                                  : LstRooms[index].bio),
                              leading: const Icon(
                                Icons.single_bed,
                                color: Color(0xFF84A5FA),
                              ),
                              trailing: Text(
                                LstRooms[index].price,
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 18),
                              ),
                              onTap: () async {
                                int index = LstRoomsSelected.indexWhere(
                                    (element) => element.name == map['Name']);
                                if (index == -1) {
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
                                  LstRoomsSelected.removeAt(index);
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
                    ),
                  ),
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
                                return Center(
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              estate["Type"] == "2" || estate["Type"] == "3",
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
                                return Center(
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              estate["Type"] == "2" || estate["Type"] == "3",
                          child: ListTile(
                            title: Text(
                              getTranslated(context, "Sessions type"),
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: FutureBuilder<String>(
                              future: splitText(estate["Sessions"].toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  return Text(
                                    snapshot.data.toString(),
                                    style: TextStyle(fontSize: 12),
                                  );
                                }
                                return Center(
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
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
                          ),
                        ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          width: 150.w,
                                          height: 6.h,
                                          margin: const EdgeInsets.only(
                                              right: 40, left: 40, bottom: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              getTranslated(context, "delete"),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          FirebaseDatabase.instance
                                              .ref("App")
                                              .child("Post")
                                              .child(
                                                  estate['IDEstate'].toString())
                                              .child(map["IDPost"])
                                              .remove();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                visible: canEditEstate,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // InkWell(
                      //   child: Container(
                      //     width: 150.w,
                      //     height: 6.h,
                      //     margin: const EdgeInsets.only(
                      //         right: 40, left: 40, bottom: 20),
                      //     decoration: BoxDecoration(
                      //       color: kPrimaryColor,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Center(
                      //       child: Text(
                      //         getTranslated(context, "Post"),
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => AddPost(
                      //           map: estate,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 40, left: 40, bottom: 20),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "GenerateQRCode"),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                visible: userType == "1",
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
                      child: Center(
                        child: Text(
                          getTranslated(context, "Next"),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (ID != "null") {
                        if (estate['Type'] == "1") {
                          if (LstRoomsSelected.isEmpty) {
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
                          await selectTime(context);
                          DatabaseReference ref = FirebaseDatabase.instance
                              .ref("App")
                              .child("Booking");

                          String? id = FirebaseAuth.instance.currentUser?.uid;
                          if (flagDate && flagTime) {
                            String? hour =
                                sTime?.hour.toString().padLeft(2, '0');
                            String? minute =
                                sTime?.minute.toString().padLeft(2, '0');
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
                                  "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                              "Clock": "${hour!}:${minute!}",
                              "EndDate": "",
                              "Type": estate['Type'],
                              "Country": estate["Country"],
                              "State": estate["State"],
                              "City": estate["City"],
                              "NameUser":
                                  "${estate['FirstName']} ${estate['SecondName']} ${estate['LastName']}",
                            });
                            objProvider.FunSnackBarPage(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
