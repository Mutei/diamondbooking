// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import '../models/Additional.dart';
// import '../models/rooms.dart';
// import '../page/Estate.dart';
// import '../resources/firebase_services.dart';
// import '../widgets/cardEstate.dart';
// import '../widgets/card_type.dart';
// import '../constants/colors.dart';
// import '../page/type_estate.dart';
// import '../page/request.dart';
// import '../page/all_posts_screen.dart';
// import '../page/notification_user.dart';
// import '../page/upgrade_account.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
//
// import '../widgets/item_drawer.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   List<Estate> LstEstate = [];
//   late String userType;
//   List<Rooms> LstRooms = [];
//   bool CheckLoginValue = false;
//   List<Additional> LstAdditional = [];
//   String ID = "";
//   Map dataUser = {};
//   final FirebaseServices firebaseServices = FirebaseServices();
//
//   @override
//   void initState() {
//     super.initState();
//     firebaseServices.initMessage();
//     firebaseServices.getUserType((type) {
//       setState(() {
//         userType = type;
//       });
//     });
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => afterLayoutWidgetBuild());
//   }
//
//   void afterLayoutWidgetBuild() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     setState(() {
//       ID = sharedPreferences.getString("ID")!;
//     });
//     firebaseServices.updateUserDetails((data) {
//       setState(() {
//         dataUser = data;
//       });
//     });
//   }
//
//   void _onItemTapped(int index) {
//     if (index == 0 && ID != "null") {
//       Navigator.of(context).push(
//           MaterialPageRoute(builder: (context) => TypeEstate(Check: "Edite")));
//     } else if (index == 1) {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => Request()));
//     } else if (index == 2) {
//       Navigator.of(context).push(
//           MaterialPageRoute(builder: (context) => TypeEstate(Check: "chat")));
//     } else if (index == 3) {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => AllPost()));
//     }
//   }
//
//   void _onItemTapped2(int index) {
//     if (index == 0 && ID != "null") {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => NotificationUser()));
//     } else if (index == 1) {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => UpgradeAccount()));
//     } else if (index == 2) {
//       Navigator.of(context).push(MaterialPageRoute(
//           builder: (context) => TypeEstate(Check: "chatuser")));
//     } else if (index == 3) {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => AllPost()));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final objProvider = Provider.of<GeneralProvider>(context, listen: false);
//     objProvider.CheckLogin();
//     String Estate = getTranslated(context, "My Estate")!;
//     String request = getTranslated(context, "Request")!;
//     String chat = getTranslated(context, "Chat for Estate")!;
//
//     String Notification = getTranslated(context, "Notification")!;
//     String upgrade = getTranslated(context, "upgrade account")!;
//     String chatU = getTranslated(context, "Chat for U")!;
//     String Posts = getTranslated(context, "Posts")!;
//
//     return Scaffold(
//       bottomNavigationBar: dataUser['TypeUser'] == "1"
//           ? BottomNavigationBar(
//               onTap: _onItemTapped2,
//               unselectedItemColor: Colors.grey,
//               fixedColor: Colors.grey,
//               showSelectedLabels: true,
//               showUnselectedLabels: true,
//               items: <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.home,
//                     color: kPrimaryColor,
//                   ),
//                   label: Notification,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.account_box,
//                     color: kPrimaryColor,
//                   ),
//                   label: upgrade,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.chat,
//                     color: kPrimaryColor,
//                   ),
//                   label: chatU,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.circle,
//                     color: kPrimaryColor,
//                   ),
//                   label: Posts,
//                 ),
//               ],
//             )
//           : BottomNavigationBar(
//               onTap: _onItemTapped,
//               unselectedItemColor: Colors.grey,
//               selectedItemColor: Colors.blue,
//               showSelectedLabels: true,
//               showUnselectedLabels: true,
//               type: BottomNavigationBarType.fixed,
//               items: <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.home,
//                     color: kPrimaryColor,
//                   ),
//                   label: Estate,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.account_box,
//                     color: kPrimaryColor,
//                   ),
//                   label: request,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.chat,
//                     color: kPrimaryColor,
//                   ),
//                   label: chat,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(
//                     Icons.circle,
//                     color: kPrimaryColor,
//                   ),
//                   label: Posts,
//                 ),
//               ],
//             ),
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(
//           getTranslated(context, "Diamond Booking")!,
//           style: const TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: kPrimaryColor,
//       ),
//       drawer: DrawerMenu(
//           dataUser: dataUser,
//           funSnackBarPage: objProvider.FunSnackBarPage,
//           ID: ID),
//       body: Container(
//         margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
//         child: ListView(
//           children: [
//             Container(height: 20),
//             Container(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: ListView.builder(
//                 itemCount: objProvider.TypeService().length,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (BuildContext context, int index) {
//                   return CardType(
//                     context: context,
//                     obj: objProvider.TypeService()[index],
//                   );
//                 },
//               ),
//               height: 13.h,
//             ),
//             Divider(),
//             buildSection(
//                 context, 'Hotel', objProvider, firebaseServices.queryHotel),
//             Divider(),
//             buildSection(
//                 context, 'Coffee', objProvider, firebaseServices.queryCoffee),
//             Divider(),
//             buildSection(context, 'Restaurant', objProvider,
//                 firebaseServices.queryRestaurant),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildSection(BuildContext context, String sectionName,
//       GeneralProvider objProvider, Query query) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: const EdgeInsets.only(top: 10),
//           child: Text(
//             getTranslated(context, sectionName)!,
//             style: TextStyle(fontSize: 6.w, color: Colors.black),
//           ),
//         ),
//         Container(
//           height: 200,
//           child: FirebaseAnimatedList(
//             shrinkWrap: true,
//             defaultChild: const Center(child: CircularProgressIndicator()),
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (context, snapshot, animation, index) {
//               Map map = snapshot.value as Map;
//               map['Key'] = snapshot.key;
//               return FutureBuilder<String>(
//                 future: firebaseServices.getimages(map['Key']),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else {
//                     String imageUrl =
//                         snapshot.data ?? 'assets/images/default_image.png';
//                     return CardEstate(
//                       context: context,
//                       obj: map,
//                       icon: "assets/images/${sectionName.toLowerCase()}.png",
//                       VisEdit: false,
//                       image: imageUrl,
//                       Visimage: true,
//                     );
//                   }
//                 },
//               );
//             },
//             query: query,
//           ),
//         ),
//       ],
//     );
//   }
// }
