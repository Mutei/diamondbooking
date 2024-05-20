import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/page/notification_user.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../page/Estate.dart';
import 'all_posts_screen.dart';
import '../page/request.dart';
import '../page/type_estate.dart';
import '../page/upgrade_account.dart';
import '../resources/firebase_services.dart';
import '../widgets/cardEstate.dart';
import '../widgets/card_type.dart';
import '../widgets/custom_drawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<Estate> LstEstate = [];
  String userType = "2"; // Default to provider type
  List<Rooms> LstRooms = [];
  bool CheckLoginValue = false;
  List<Additional> LstAdditional = [];
  String ID = "";
  Map dataUser = {};
  Query queryHotel =
      FirebaseDatabase.instance.ref("App").child("Estate").child("Hottel");
  Query queryCoffee =
      FirebaseDatabase.instance.ref("App").child("Estate").child("Coffee");
  Query queryRestaurant =
      FirebaseDatabase.instance.ref("App").child("Estate").child("Restaurant");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _firebaseServices.afterLayoutWidgetBuild(setUserData, setID));
    _firebaseServices.initMessage(showNotification);
    _firebaseServices.getUserType(setUserType, setPermissionStatus);
    _loadUserType();
  }

  // void _loadUserType() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     userType =
  //         prefs.getString("TypeUser") ?? "2"; // Default to type 2 if not found
  //   });
  // }

  void showNotification(RemoteNotification? notification) async {
    var androidDetails = const AndroidNotificationDetails('1', 'channelName');
    var iosDetails = const DarwinNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _firebaseServices.flutterLocalNotificationPlugin.show(
        0, notification?.title, notification?.body, generalNotificationDetails,
        payload: 'Notification');
  }

  void setUserType(String type) {
    setState(() {
      userType = type;
      print("User Type Set: $userType");
    });
  }

  void _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString("TypeUser") ?? "2";
      print("Loaded User Type: $userType");
    });
  }

  void setPermissionStatus(PermissionStatus status) {
    print(status);
  }

  void setUserData(Map data) {
    setState(() {
      dataUser = data;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString("TypeUser", dataUser["TypeUser"]);
        prefs.setString("Email", dataUser["Email"]);
        prefs.setString("Name", dataUser["Name"]);
        print("TypeUser: ${dataUser['TypeUser']}");
      });
    });
  }

  void setID(String id) {
    setState(() {
      ID = id;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        if (ID != "null") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TypeEstate(Check: "Edite")));
        }
      } else if (index == 1) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Request()));
      } else if (index == 2) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TypeEstate(Check: "chat")));
      } else if (index == 3) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AllPostsScreen()));
      }
    });
  }

  void _onItemTapped2(int index) {
    setState(() {
      if (index == 0) {
        if (ID != "null") {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NotificationUser()));
        }
      } else if (index == 1) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => UpgradeAccount()));
      } else if (index == 2) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TypeEstate(Check: "chatuser")));
      } else if (index == 3) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AllPostsScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    objProvider.CheckLogin();
    String Estate = getTranslated(context, "My Estate");
    String request = getTranslated(context, "Request");
    String chat = getTranslated(context, "Chat for Estate");

    String Notification = getTranslated(context, "Notification");
    String upgrade = getTranslated(context, "upgrade account");
    String chatU = getTranslated(context, "Chat for U");
    String Posts = getTranslated(context, "Posts");

    return Scaffold(
      bottomNavigationBar: userType == "1"
          ? BottomNavigationBar(
              onTap: _onItemTapped2,
              unselectedItemColor: Colors.grey,
              fixedColor: Colors.grey,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.home,
                    color: kPrimaryColor,
                  ),
                  label: Notification,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.account_box,
                    color: kPrimaryColor,
                  ),
                  label: upgrade,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.chat,
                    color: kPrimaryColor,
                  ),
                  label: chatU,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.circle,
                    color: kPrimaryColor,
                  ),
                  label: Posts,
                ),
              ],
            )
          : BottomNavigationBar(
              onTap: _onItemTapped,
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.blue,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.home,
                    color: kPrimaryColor,
                  ),
                  label: Estate,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.account_box,
                    color: kPrimaryColor,
                  ),
                  label: request,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.chat,
                    color: kPrimaryColor,
                  ),
                  label: chat,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.circle,
                    color: kPrimaryColor,
                  ),
                  label: getTranslated(context, "Posts"),
                ),
              ],
            ),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          getTranslated(context, "Diamond Booking"),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      drawer: CustomDrawer(userType: userType, id: ID),
      body: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
        child: ListView(
          children: [
            Container(height: 20),
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              height: 13.h,
              child: ListView.builder(
                  itemCount: objProvider.TypeService().length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return CardType(
                      context: context,
                      obj: objProvider.TypeService()[index],
                    );
                  }),
            ),
            Divider(),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                getTranslated(context, 'Hotel'),
                style: TextStyle(fontSize: 6.w, color: Colors.black),
              ),
            ),
            Container(
              height: 200,
              child: FirebaseAnimatedList(
                shrinkWrap: true,
                defaultChild: const Center(child: CircularProgressIndicator()),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, snapshot, animation, index) {
                  Map map = snapshot.value as Map;
                  map['Key'] = snapshot.key;
                  return FutureBuilder<String>(
                    future: _firebaseServices.getImages(map['Key']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String imageUrl =
                            snapshot.data ?? 'assets/images/default_image.png';
                        return CardEstate(
                          context: context,
                          obj: map,
                          icon: "assets/images/hotel.png",
                          VisEdit: false,
                          image: imageUrl,
                          Visimage: true,
                        );
                      }
                    },
                  );
                },
                query: queryHotel,
              ),
            ),
            Divider(),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                getTranslated(context, 'Coffee'),
                style: TextStyle(fontSize: 6.w, color: Colors.black),
              ),
            ),
            Container(
              height: 200,
              child: FirebaseAnimatedList(
                shrinkWrap: true,
                defaultChild: const Center(child: CircularProgressIndicator()),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, snapshot, animation, index) {
                  Map map = snapshot.value as Map;
                  map['Key'] = snapshot.key;
                  return FutureBuilder<String>(
                    future: _firebaseServices.getImages(map['Key']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String imageUrl =
                            snapshot.data ?? 'assets/images/default_image.png';
                        return CardEstate(
                          context: context,
                          obj: map,
                          icon: "assets/images/coffee.png",
                          VisEdit: false,
                          image: imageUrl,
                          Visimage: true,
                        );
                      }
                    },
                  );
                },
                query: queryCoffee,
              ),
            ),
            Divider(),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                getTranslated(context, 'Restaurant'),
                style: TextStyle(fontSize: 5.w, color: Colors.black),
              ),
            ),
            Container(
              height: 200,
              child: FirebaseAnimatedList(
                shrinkWrap: true,
                defaultChild: const Center(child: CircularProgressIndicator()),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, snapshot, animation, index) {
                  Map map = snapshot.value as Map;
                  map['Key'] = snapshot.key;
                  return FutureBuilder<String>(
                    future: _firebaseServices.getImages(map['Key']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String imageUrl =
                            snapshot.data ?? 'assets/images/default_image.png';
                        return CardEstate(
                          context: context,
                          obj: map,
                          icon: "assets/images/restaurant.png",
                          VisEdit: false,
                          image: imageUrl,
                          Visimage: true,
                        );
                      }
                    },
                  );
                },
                query: queryRestaurant,
              ),
            ),
          ],
        ),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   final objProvider = Provider.of<GeneralProvider>(context, listen: false);
//   objProvider.CheckLogin();
//   String Estate = getTranslated(context, "My Estate");
//   String request = getTranslated(context, "Request");
//   String chat = getTranslated(context, "Chat for Estate");
//
//   String Notification = getTranslated(context, "Notification");
//   String upgrade = getTranslated(context, "upgrade account");
//   String chatU = getTranslated(context, "Chat for U");
//   String Posts = getTranslated(context, "Posts");
//
//   return Scaffold(
//     bottomNavigationBar: userType == "1"
//         ? BottomNavigationBar(
//             onTap: _onItemTapped2,
//             unselectedItemColor: Colors.grey,
//             fixedColor: Colors.grey,
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             items: <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.home,
//                   color: kPrimaryColor,
//                 ),
//                 label: Notification,
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.account_box,
//                   color: kPrimaryColor,
//                 ),
//                 label: upgrade,
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.chat,
//                   color: kPrimaryColor,
//                 ),
//                 label: chatU,
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.circle,
//                   color: kPrimaryColor,
//                 ),
//                 label: Posts,
//               ),
//             ],
//           )
//         : BottomNavigationBar(
//             onTap: _onItemTapped,
//             unselectedItemColor: Colors.grey,
//             selectedItemColor: Colors.blue,
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             type: BottomNavigationBarType.fixed,
//             items: <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.home,
//                   color: kPrimaryColor,
//                 ),
//                 label: Estate,
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.account_box,
//                   color: kPrimaryColor,
//                 ),
//                 label: request,
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.chat,
//                   color: kPrimaryColor,
//                 ),
//                 label: chat,
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(
//                   Icons.circle,
//                   color: kPrimaryColor,
//                 ),
//                 label: getTranslated(context, "Posts"),
//               ),
//             ],
//           ),
//     appBar: AppBar(
//       elevation: 0,
//       title: Text(
//         getTranslated(context, "Diamond Booking"),
//         style: const TextStyle(color: Colors.white),
//       ),
//       centerTitle: true,
//       backgroundColor: kPrimaryColor,
//     ),
//     drawer: CustomDrawer(dataUser: dataUser, id: ID),
//     body: Container(
//       margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
//       child: ListView(
//         children: [
//           Container(height: 20),
//           Container(
//             padding: const EdgeInsets.only(bottom: 10),
//             height: 13.h,
//             child: ListView.builder(
//                 itemCount: objProvider.TypeService().length,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (BuildContext context, int index) {
//                   return CardType(
//                     context: context,
//                     obj: objProvider.TypeService()[index],
//                   );
//                 }),
//           ),
//           Divider(),
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             child: Text(
//               getTranslated(context, 'Hotel'),
//               style: TextStyle(fontSize: 6.w, color: Colors.black),
//             ),
//           ),
//           Container(
//             height: 200,
//             child: FirebaseAnimatedList(
//               shrinkWrap: true,
//               defaultChild: const Center(child: CircularProgressIndicator()),
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, snapshot, animation, index) {
//                 Map map = snapshot.value as Map;
//                 map['Key'] = snapshot.key;
//                 return FutureBuilder<String>(
//                   future: _firebaseServices.getImages(map['Key']),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else {
//                       String imageUrl =
//                           snapshot.data ?? 'assets/images/default_image.png';
//                       return CardEstate(
//                         context: context,
//                         obj: map,
//                         icon: "assets/images/hotel.png",
//                         VisEdit: false,
//                         image: imageUrl,
//                         Visimage: true,
//                       );
//                     }
//                   },
//                 );
//               },
//               query: queryHotel,
//             ),
//           ),
//           Divider(),
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             child: Text(
//               getTranslated(context, 'Coffee'),
//               style: TextStyle(fontSize: 6.w, color: Colors.black),
//             ),
//           ),
//           Container(
//             height: 200,
//             child: FirebaseAnimatedList(
//               shrinkWrap: true,
//               defaultChild: const Center(child: CircularProgressIndicator()),
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, snapshot, animation, index) {
//                 Map map = snapshot.value as Map;
//                 map['Key'] = snapshot.key;
//                 return FutureBuilder<String>(
//                   future: _firebaseServices.getImages(map['Key']),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else {
//                       String imageUrl =
//                           snapshot.data ?? 'assets/images/default_image.png';
//                       return CardEstate(
//                         context: context,
//                         obj: map,
//                         icon: "assets/images/coffee.png",
//                         VisEdit: false,
//                         image: imageUrl,
//                         Visimage: true,
//                       );
//                     }
//                   },
//                 );
//               },
//               query: queryCoffee,
//             ),
//           ),
//           Divider(),
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             child: Text(
//               getTranslated(context, 'Restaurant'),
//               style: TextStyle(fontSize: 5.w, color: Colors.black),
//             ),
//           ),
//           Container(
//             height: 200,
//             child: FirebaseAnimatedList(
//               shrinkWrap: true,
//               defaultChild: const Center(child: CircularProgressIndicator()),
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, snapshot, animation, index) {
//                 Map map = snapshot.value as Map;
//                 map['Key'] = snapshot.key;
//                 return FutureBuilder<String>(
//                   future: _firebaseServices.getImages(map['Key']),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else {
//                       String imageUrl =
//                           snapshot.data ?? 'assets/images/default_image.png';
//                       return CardEstate(
//                         context: context,
//                         obj: map,
//                         icon: "assets/images/restaurant.png",
//                         VisEdit: false,
//                         image: imageUrl,
//                         Visimage: true,
//                       );
//                     }
//                   },
//                 );
//               },
//               query: queryRestaurant,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
}

// // ignore_for_file: non_constant_identifier_names
//
// import 'dart:async';
// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/page/notification_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import '../models/Additional.dart';
// import '../models/rooms.dart';
// import '../page/Estate.dart';
// import '../page/all_posts_screen.dart';
// import '../page/request.dart';
// import '../page/type_estate.dart';
// import '../page/upgrade_account.dart';
// import '../widgets/cardEstate.dart';
// import '../widgets/card_type.dart';
// import '../widgets/custom_drawer.dart';
//
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
//   final storageRef = FirebaseStorage.instance.ref();
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   String ID = "";
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin;
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//   Query queryHotel =
//   FirebaseDatabase.instance.ref("App").child("Estate").child("Hottel");
//   Query queryCoffee =
//   FirebaseDatabase.instance.ref("App").child("Estate").child("Coffee");
//   Query queryRestaurant =
//   FirebaseDatabase.instance.ref("App").child("Estate").child("Restaurant");
//   DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");
//   Map dataUser = {};
//
//   @override
//   void initState() {
//     super.initState();
//     initMessage();
//     getUserType();
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => afterLayoutWidgetBuild());
//   }
//
//   void showNotification(RemoteNotification? notification) async {
//     var androidDetails = const AndroidNotificationDetails('1', 'channelName');
//     var iosDetails = const DarwinNotificationDetails();
//     var generalNotificationDetails =
//     NotificationDetails(android: androidDetails, iOS: iosDetails);
//
//     await flutterLocalNotificationPlugin.show(
//         0, notification?.title, notification?.body, generalNotificationDetails,
//         payload: 'Notification');
//   }
//
//   initMessage() {
//     var androidInit = const AndroidInitializationSettings('ic_launcher');
//     var iosInit = const DarwinInitializationSettings();
//     var initSetting =
//     InitializationSettings(android: androidInit, iOS: iosInit);
//     flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
//     flutterLocalNotificationPlugin.initialize(initSetting);
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print("message");
//       print(message.data);
//       showNotification(message.notification);
//     });
//   }
//
//   Future<void> getUserType() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     String typeUser = sharedPreferences.getString("TypeUser") ?? "1";
//     setState(() {
//       userType = typeUser;
//     });
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.storage,
//     ].request();
//
//     print(statuses[Permission.location]);
//   }
//
//   void afterLayoutWidgetBuild() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     setState(() {
//       ID = sharedPreferences.getString("ID")!;
//     });
//     try {
//       if (ID != "null") {
//         Map<Permission, PermissionStatus> statuses = await [
//           Permission.location,
//           Permission.storage,
//         ].request();
//         print(statuses[Permission.location]);
//         String? token = await firebaseMessaging.getToken();
//
//         String? id = FirebaseAuth.instance.currentUser?.uid;
//         sharedPreferences.setString("ID", id!);
//         await ref.child(id).update({
//           "Token": token,
//         });
//         DatabaseReference starCountRef =
//         FirebaseDatabase.instance.ref("App").child("User").child(id);
//         starCountRef.onValue.listen((DatabaseEvent event) {
//           final Map data = event.snapshot.value as Map;
//           setState(() {
//             dataUser = data;
//             sharedPreferences.setString("Typ", dataUser["TypeAccount"]);
//             sharedPreferences.setString("Email", dataUser["Email"]);
//             sharedPreferences.setString("Name", dataUser["Name"]);
//             print("TypeUser: ${dataUser['TypeUser']}");
//           });
//         });
//       } else {
//         dataUser = {"TypeUser": "1"};
//       }
//     } catch (e) {
//       print('Error in afterLayoutWidgetBuild: $e');
//     }
//   }
//
//   Future<String> getimages(String EID) async {
//     String imageUrl = '';
//     try {
//       imageUrl = await storageRef.child(EID + "/0.jpg").getDownloadURL();
//     } catch (e) {
//       imageUrl =
//       'assets/images/default_image.png'; // Provide a default image URL
//       print('Error fetching image: $e');
//     }
//     return imageUrl;
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       if (index == 0) {
//         if (ID != "null") {
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => TypeEstate(Check: "Edite")));
//         }
//       } else if (index == 1) {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => Request()));
//       } else if (index == 2) {
//         Navigator.of(context).push(
//             MaterialPageRoute(builder: (context) => TypeEstate(Check: "chat")));
//       } else if (index == 3) {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => AllPost()));
//       }
//     });
//   }
//
//   void _onItemTapped2(int index) {
//     setState(() {
//       if (index == 0) {
//         if (ID != "null") {
//           Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => NotificationUser()));
//         }
//       } else if (index == 1) {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => UpgradeAccount()));
//       } else if (index == 2) {
//         Navigator.of(context).push(MaterialPageRoute(
//             builder: (context) => TypeEstate(Check: "chatuser")));
//       } else if (index == 3) {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => AllPost()));
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final objProvider = Provider.of<GeneralProvider>(context, listen: false);
//     objProvider.CheckLogin();
//     String Estate = getTranslated(context, "My Estate");
//     String request = getTranslated(context, "Request");
//     String chat = getTranslated(context, "Chat for Estate");
//
//     String Notification = getTranslated(context, "Notification");
//     String upgrade = getTranslated(context, "upgrade account");
//     String chatU = getTranslated(context, "Chat for U");
//     String Posts = getTranslated(context, "Posts");
//     return Scaffold(
//       bottomNavigationBar: dataUser['TypeUser'] == "1"
//           ? BottomNavigationBar(
//         onTap: _onItemTapped2,
//         unselectedItemColor: Colors.grey,
//         fixedColor: Colors.grey,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.home,
//               color: kPrimaryColor,
//             ),
//             label: Notification,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.account_box,
//               color: kPrimaryColor,
//             ),
//             label: upgrade,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.chat,
//               color: kPrimaryColor,
//             ),
//             label: chatU,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.circle,
//               color: kPrimaryColor,
//             ),
//             label: Posts,
//           ),
//         ],
//       )
//           : BottomNavigationBar(
//         onTap: _onItemTapped,
//         unselectedItemColor: Colors.grey,
//         selectedItemColor:
//         Colors.blue, // You can change this color to whatever you like
//         showSelectedLabels:
//         true, // Ensure labels are shown for the selected tab
//         showUnselectedLabels:
//         true, // Ensure labels are shown for the unselected tabs
//         type: BottomNavigationBarType
//             .fixed, // Ensures that all items are fixed and visible
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.home,
//               color: kPrimaryColor,
//             ),
//             label: Estate, // Translated label for "My Estate"
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.account_box,
//               color: kPrimaryColor,
//             ),
//             label: request, // Translated label for "Request"
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.chat,
//               color: kPrimaryColor,
//             ),
//             label: chat, // Translated label for "Chat for Estate"
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.circle,
//               color: kPrimaryColor,
//             ),
//             label: getTranslated(
//                 context, "Posts"), // Translated label for "Posts"
//           ),
//         ],
//       ),
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(
//           getTranslated(context, "Diamond Booking"),
//           style: const TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: kPrimaryColor,
//       ),
//       drawer: CustomDrawer(dataUser: dataUser, id: ID),
//       body: Container(
//         margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
//         child: ListView(
//           children: [
//             Container(height: 20),
//             Container(
//               padding: const EdgeInsets.only(bottom: 10),
//               height: 13.h,
//               child: ListView.builder(
//                   itemCount: objProvider.TypeService().length,
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder: (BuildContext context, int index) {
//                     return CardType(
//                       context: context,
//                       obj: objProvider.TypeService()[index],
//                     );
//                   }),
//             ),
//             Divider(),
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               child: Text(
//                 getTranslated(context, 'Hotel'),
//                 style: TextStyle(fontSize: 6.w, color: Colors.black),
//               ),
//             ),
//             Container(
//               height: 200,
//               child: FirebaseAnimatedList(
//                 shrinkWrap: true,
//                 defaultChild: const Center(child: CircularProgressIndicator()),
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, snapshot, animation, index) {
//                   Map map = snapshot.value as Map;
//                   map['Key'] = snapshot.key;
//                   return FutureBuilder<String>(
//                     future: getimages(map['Key']), // Fetch image URL
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else {
//                         String imageUrl =
//                             snapshot.data ?? 'assets/images/default_image.png';
//                         return CardEstate(
//                           context: context,
//                           obj: map,
//                           icon: "assets/images/hotel.png",
//                           VisEdit: false,
//                           image: imageUrl,
//                           Visimage: true,
//                         );
//                       }
//                     },
//                   );
//                 },
//                 query: queryHotel,
//               ),
//             ),
//             Divider(),
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               child: Text(
//                 getTranslated(context, 'Coffee'),
//                 style: TextStyle(fontSize: 6.w, color: Colors.black),
//               ),
//             ),
//             Container(
//               height: 200,
//               child: FirebaseAnimatedList(
//                 shrinkWrap: true,
//                 defaultChild: const Center(child: CircularProgressIndicator()),
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, snapshot, animation, index) {
//                   Map map = snapshot.value as Map;
//                   map['Key'] = snapshot.key;
//                   return FutureBuilder<String>(
//                     future: getimages(map['Key']), // Fetch image URL
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else {
//                         String imageUrl =
//                             snapshot.data ?? 'assets/images/default_image.png';
//                         return CardEstate(
//                           context: context,
//                           obj: map,
//                           icon: "assets/images/coffee.png",
//                           VisEdit: false,
//                           image: imageUrl,
//                           Visimage: true,
//                         );
//                       }
//                     },
//                   );
//                 },
//                 query: queryCoffee,
//               ),
//             ),
//             Divider(),
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               child: Text(
//                 getTranslated(context, 'Restaurant'),
//                 style: TextStyle(fontSize: 5.w, color: Colors.black),
//               ),
//             ),
//             Container(
//               height: 200,
//               child: FirebaseAnimatedList(
//                 shrinkWrap: true,
//                 defaultChild: const Center(child: CircularProgressIndicator()),
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, snapshot, animation, index) {
//                   Map map = snapshot.value as Map;
//                   map['Key'] = snapshot.key;
//                   return FutureBuilder<String>(
//                     future: getimages(map['Key']), // Fetch image URL
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else {
//                         String imageUrl =
//                             snapshot.data ?? 'assets/images/default_image.png';
//                         return CardEstate(
//                           context: context,
//                           obj: map,
//                           icon: "assets/images/restaurant.png",
//                           VisEdit: false,
//                           image: imageUrl,
//                           Visimage: true,
//                         );
//                       }
//                     },
//                   );
//                 },
//                 query: queryRestaurant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// )
