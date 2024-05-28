import 'package:badges/badges.dart' as badges;
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/page/notification_user.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
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
    Provider.of<GeneralProvider>(context, listen: false).fetchNewRequestCount();
    _loadUserType();
    _requestPermissions(); // Request permissions
  }

  void _requestPermissions() async {
    // Request location permission
    var status = await Permission.location.request();
    setPermissionStatus(status);

    // Request notification permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission for notifications');
    } else {
      print('User declined or has not accepted permission for notifications');
    }
  }

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
                  icon: badges.Badge(
                    badgeContent: Consumer<GeneralProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          provider.newRequestCount.toString(),
                          style: TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    child: Icon(
                      Icons.account_box,
                      color: kPrimaryColor,
                    ),
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
}
