import 'package:badges/badges.dart' as badges;
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/page/notification_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../page/Estate.dart';
import '../widgets/main_screen_widgets.dart';
import 'all_posts_screen.dart';
import '../page/request.dart';
import '../page/type_estate.dart';
import '../page/upgrade_account.dart';
import '../resources/firebase_services.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/reused_estate_page.dart'; // Import ReusedEstatePage
import '../widgets/filter_button.dart'; // Import FilterButton

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

  PageController _pageController = PageController();
  int _selectedIndex = 0;
  String _selectedFilter = 'All'; // Add this line
  TextEditingController _searchController =
      TextEditingController(); // Add this line

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
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onSearchTextChanged(String text) {
    // Add this method
    setState(() {});
  }

  Future<String> _getImages(String key) async {
    // Implement your image fetching logic here
    return 'assets/images/default_image.png';
  }

  Future<Map<String, dynamic>> _getEstateRatings(String estateId) async {
    Map<String, dynamic> ratingsData = {"totalRating": 0.0, "ratingCount": 0};

    DatabaseReference feedbackRef =
        FirebaseDatabase.instance.ref('App/Feedback/$estateId');
    DataSnapshot snapshot = await feedbackRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> feedbackData =
          snapshot.value as Map<dynamic, dynamic>;
      double totalRating = 0.0;
      int ratingCount = 0;

      feedbackData.forEach((key, value) {
        totalRating += value['rating'];
        ratingCount += 1;
      });

      ratingsData['totalRating'] = totalRating / ratingCount;
      ratingsData['ratingCount'] = ratingCount;
    }

    return ratingsData;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';

        return AlertDialog(
          title: Text(getTranslated(context, "Search")),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: InputDecoration(
              hintText: getTranslated(
                  context, "Search for Restaurant, Cafe, or Hotel"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _searchController.text = searchQuery;
                });
                // Perform search or filter logic here
              },
              child: Text(getTranslated(context, "Search")),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshPage() async {
    // Clear the search query to reset the view
    setState(() {
      _searchController.clear();
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
    String estates = getTranslated(context, "Estates");

    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: userType == "1"
            ? <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.home,
                    color: kPrimaryColor,
                  ),
                  label: estates,
                ),
                BottomNavigationBarItem(
                  icon: Consumer<GeneralProvider>(
                    builder: (context, provider, child) {
                      if (provider.newRequestCount == 0) {
                        return const Icon(
                          Icons.notifications,
                          color: kPrimaryColor,
                        );
                      } else {
                        return badges.Badge(
                          badgeContent: Text(
                            provider.newRequestCount.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: kPrimaryColor,
                          ),
                        );
                      }
                    },
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
                    Icons.circle,
                    color: kPrimaryColor,
                  ),
                  label: Posts,
                ),
              ]
            : <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.home,
                    color: kPrimaryColor,
                  ),
                  label: Estate,
                ),
                BottomNavigationBarItem(
                  icon: Consumer<GeneralProvider>(
                    builder: (context, provider, child) {
                      if (provider.newRequestCount == 0) {
                        return const Icon(
                          Icons.account_box,
                          color: kPrimaryColor,
                        );
                      } else {
                        return badges.Badge(
                          badgeContent: Text(
                            provider.newRequestCount.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          child: const Icon(
                            Icons.account_box,
                            color: kPrimaryColor,
                          ),
                        );
                      }
                    },
                  ),
                  label: request,
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
          style: const TextStyle(
            color: kPrimaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: kIconTheme, // Set the background color to white
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: kPrimaryColor),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      drawer: CustomDrawer(userType: userType, id: ID),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: userType == "1"
            ? [
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ReusedEstatePage(
                      queryHotel: queryHotel,
                      queryCoffee: queryCoffee,
                      queryRestaurant: queryRestaurant,
                      getImages: _getImages,
                      objProvider: objProvider,
                      selectedFilter: _selectedFilter, // Add this line
                      onFilterChanged: _onFilterChanged, // Add this line
                      getEstateRatings: _getEstateRatings, // Add this line
                      searchQuery: _searchController.text, // Add this line
                    ),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: NotificationUser(),
                ),
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: UpgradeAccount(),
                ),
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: AllPostsScreen(),
                ),
              ]
            : [
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ReusedEstatePage(
                      queryHotel: queryHotel,
                      queryCoffee: queryCoffee,
                      queryRestaurant: queryRestaurant,
                      getImages: _getImages,
                      objProvider: objProvider,
                      selectedFilter: _selectedFilter, // Add this line
                      onFilterChanged: _onFilterChanged, // Add this line
                      getEstateRatings: _getEstateRatings, // Add this line
                      searchQuery: _searchController.text, // Add this line
                    ),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: Request(),
                ),
                RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: AllPostsScreen(),
                ),
              ],
      ),
    );
  }
}

// import 'package:badges/badges.dart' as badges;
// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/constants/styles.dart';
// import 'package:diamond_booking/page/notification_user.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import '../models/Additional.dart';
// import '../models/rooms.dart';
// import '../page/Estate.dart';
// import '../widgets/main_screen_widgets.dart';
// import 'all_posts_screen.dart';
// import '../page/request.dart';
// import '../page/type_estate.dart';
// import '../page/upgrade_account.dart';
// import '../resources/firebase_services.dart';
// import '../widgets/custom_drawer.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   final FirebaseServices _firebaseServices = FirebaseServices();
//   List<Estate> LstEstate = [];
//   String userType = "2"; // Default to provider type
//   List<Rooms> LstRooms = [];
//   bool CheckLoginValue = false;
//   List<Additional> LstAdditional = [];
//   String ID = "";
//   Map dataUser = {};
//   Query queryHotel =
//   FirebaseDatabase.instance.ref("App").child("Estate").child("Hottel");
//   Query queryCoffee =
//   FirebaseDatabase.instance.ref("App").child("Estate").child("Coffee");
//   Query queryRestaurant =
//   FirebaseDatabase.instance.ref("App").child("Estate").child("Restaurant");
//
//   PageController _pageController = PageController();
//   int _selectedIndex = 0;
//   String _selectedFilter = 'All'; // Add this line
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback(
//             (_) => _firebaseServices.afterLayoutWidgetBuild(setUserData, setID));
//     _firebaseServices.initMessage(showNotification);
//     _firebaseServices.getUserType(setUserType, setPermissionStatus);
//     Provider.of<GeneralProvider>(context, listen: false).fetchNewRequestCount();
//     _loadUserType();
//     _requestPermissions(); // Request permissions
//   }
//
//   void _requestPermissions() async {
//     // Request location permission
//     var status = await Permission.location.request();
//     setPermissionStatus(status);
//
//     // Request notification permission
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission for notifications');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('User granted provisional permission for notifications');
//     } else {
//       print('User declined or has not accepted permission for notifications');
//     }
//   }
//
//   void showNotification(RemoteNotification? notification) async {
//     var androidDetails = const AndroidNotificationDetails('1', 'channelName');
//     var iosDetails = const DarwinNotificationDetails();
//     var generalNotificationDetails =
//     NotificationDetails(android: androidDetails, iOS: iosDetails);
//
//     await _firebaseServices.flutterLocalNotificationPlugin.show(
//         0, notification?.title, notification?.body, generalNotificationDetails,
//         payload: 'Notification');
//   }
//
//   void setUserType(String type) {
//     setState(() {
//       userType = type;
//       print("User Type Set: $userType");
//     });
//   }
//
//   void _loadUserType() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userType = prefs.getString("TypeUser") ?? "2";
//       print("Loaded User Type: $userType");
//     });
//   }
//
//   void setPermissionStatus(PermissionStatus status) {
//     print(status);
//   }
//
//   void setUserData(Map data) {
//     setState(() {
//       dataUser = data;
//       SharedPreferences.getInstance().then((prefs) {
//         prefs.setString("TypeUser", dataUser["TypeUser"]);
//         prefs.setString("Email", dataUser["Email"]);
//         prefs.setString("Name", dataUser["Name"]);
//         print("TypeUser: ${dataUser['TypeUser']}");
//       });
//     });
//   }
//
//   void setID(String id) {
//     setState(() {
//       ID = id;
//     });
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.jumpToPage(index);
//   }
//
//   void _onFilterChanged(String filter) {
//     setState(() {
//       _selectedFilter = filter;
//     });
//   }
//
//   Future<String> _getImages(String key) async {
//     // Implement your image fetching logic here
//     return 'assets/images/default_image.png';
//   }
//
//   Future<Map<String, dynamic>> _getEstateRatings(String estateId) async {
//     Map<String, dynamic> ratingsData = {"totalRating": 0.0, "ratingCount": 0};
//
//     DatabaseReference feedbackRef =
//     FirebaseDatabase.instance.ref('App/Feedback/$estateId');
//     DataSnapshot snapshot = await feedbackRef.get();
//
//     if (snapshot.exists) {
//       Map<dynamic, dynamic> feedbackData =
//       snapshot.value as Map<dynamic, dynamic>;
//       double totalRating = 0.0;
//       int ratingCount = 0;
//
//       feedbackData.forEach((key, value) {
//         totalRating += value['rating'];
//         ratingCount += 1;
//       });
//
//       ratingsData['totalRating'] = totalRating / ratingCount;
//       ratingsData['ratingCount'] = ratingCount;
//     }
//
//     return ratingsData;
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
//     String estates = getTranslated(context, "Estates");
//
//     return Scaffold(
//       backgroundColor: Colors.white, // Set the background color to white
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: Colors.blue,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         items: userType == "1"
//             ? <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.home,
//               color: kPrimaryColor,
//             ),
//             label: estates,
//           ),
//           BottomNavigationBarItem(
//             icon: Consumer<GeneralProvider>(
//               builder: (context, provider, child) {
//                 if (provider.newRequestCount == 0) {
//                   return const Icon(
//                     Icons.notifications,
//                     color: kPrimaryColor,
//                   );
//                 } else {
//                   return badges.Badge(
//                     badgeContent: Text(
//                       provider.newRequestCount.toString(),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     child: const Icon(
//                       Icons.notifications,
//                       color: kPrimaryColor,
//                     ),
//                   );
//                 }
//               },
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
//           // BottomNavigationBarItem(
//           //   icon: const Icon(
//           //     Icons.chat,
//           //     color: kPrimaryColor,
//           //   ),
//           //   label: chatU,
//           // ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.circle,
//               color: kPrimaryColor,
//             ),
//             label: Posts,
//           ),
//         ]
//             : <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.home,
//               color: kPrimaryColor,
//             ),
//             label: Estate,
//           ),
//           BottomNavigationBarItem(
//             icon: Consumer<GeneralProvider>(
//               builder: (context, provider, child) {
//                 if (provider.newRequestCount == 0) {
//                   return const Icon(
//                     Icons.account_box,
//                     color: kPrimaryColor,
//                   );
//                 } else {
//                   return badges.Badge(
//                     badgeContent: Text(
//                       provider.newRequestCount.toString(),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     child: const Icon(
//                       Icons.account_box,
//                       color: kPrimaryColor,
//                     ),
//                   );
//                 }
//               },
//             ),
//             label: request,
//           ),
//           // BottomNavigationBarItem(
//           //   icon: const Icon(
//           //     Icons.chat,
//           //     color: kPrimaryColor,
//           //   ),
//           //   label: chat,
//           // ),
//           BottomNavigationBarItem(
//             icon: const Icon(
//               Icons.circle,
//               color: kPrimaryColor,
//             ),
//             label: getTranslated(context, "Posts"),
//           ),
//         ],
//       ),
//
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(
//           getTranslated(context, "Diamond Booking"),
//           style: const TextStyle(
//             color: kPrimaryColor,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         iconTheme: kIconTheme, // Set the background color to white
//       ),
//       drawer: CustomDrawer(userType: userType, id: ID),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         children: userType == "1"
//             ? [
//           ReusedEstatePage(
//             queryHotel: queryHotel,
//             queryCoffee: queryCoffee,
//             queryRestaurant: queryRestaurant,
//             getImages: _getImages,
//             objProvider: objProvider,
//             selectedFilter: _selectedFilter, // Add this line
//             onFilterChanged: _onFilterChanged, // Add this line
//             getEstateRatings: _getEstateRatings, // Add this line
//           ),
//           NotificationUser(),
//           UpgradeAccount(),
//           // TypeEstate(Check: "chatuser"),
//           AllPostsScreen(),
//         ]
//             : [
//           ReusedEstatePage(
//             queryHotel: queryHotel,
//             queryCoffee: queryCoffee,
//             queryRestaurant: queryRestaurant,
//             getImages: _getImages,
//             objProvider: objProvider,
//             selectedFilter: _selectedFilter, // Add this line
//             onFilterChanged: _onFilterChanged, // Add this line
//             getEstateRatings: _getEstateRatings, // Add this line
//           ),
//           Request(),
//           // TypeEstate(Check: "chat"),
//           AllPostsScreen(),
//         ],
//       ),
//     );
//   }
// }
//
// class ReusedEstatePage extends StatelessWidget {
//   final Query queryHotel;
//   final Query queryCoffee;
//   final Query queryRestaurant;
//   final Future<String> Function(String) getImages;
//   final GeneralProvider objProvider;
//   final String selectedFilter;
//   final Function(String) onFilterChanged;
//   final Future<Map<String, dynamic>> Function(String) getEstateRatings;
//
//   const ReusedEstatePage({
//     Key? key,
//     required this.queryHotel,
//     required this.queryCoffee,
//     required this.queryRestaurant,
//     required this.getImages,
//     required this.objProvider,
//     required this.selectedFilter,
//     required this.onFilterChanged,
//     required this.getEstateRatings,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
//       child: ListView(
//         children: [
//           Container(height: 20),
//           // Container(
//           //   padding: const EdgeInsets.only(bottom: 10),
//           //   height: 13.h,
//           //   child: ListView.builder(
//           //     itemCount: objProvider.TypeService().length,
//           //     scrollDirection: Axis.horizontal,
//           //     itemBuilder: (BuildContext context, int index) {
//           //       return CardType(
//           //         context: context,
//           //         obj: objProvider.TypeService()[index],
//           //       );
//           //     },
//           //   ),
//           // ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               FilterButton(
//                 label: 'All',
//                 isSelected: selectedFilter == 'All',
//                 onTap: () => onFilterChanged('All'),
//               ),
//               FilterButton(
//                 label: 'Restaurant',
//                 isSelected: selectedFilter == 'Restaurant',
//                 onTap: () => onFilterChanged('Restaurant'),
//               ),
//               FilterButton(
//                 label: 'Hotel',
//                 isSelected: selectedFilter == 'Hotel',
//                 onTap: () => onFilterChanged('Hotel'),
//               ),
//               FilterButton(
//                 label: 'Coffee',
//                 isSelected: selectedFilter == 'Coffee',
//                 onTap: () => onFilterChanged('Coffee'),
//               ),
//             ],
//           ),
//           Divider(),
//           if (selectedFilter == 'All' || selectedFilter == 'Hotel')
//             CustomWidgets.buildSectionTitle(context, 'Hotel'),
//           if (selectedFilter == 'All' || selectedFilter == 'Hotel')
//             CustomWidgets.buildFirebaseAnimatedListWithRatings(
//                 queryHotel,
//                 'assets/images/hotel.png',
//                 getImages,
//                 getEstateRatings,
//                 selectedFilter),
//           Divider(),
//           if (selectedFilter == 'All' || selectedFilter == 'Coffee')
//             CustomWidgets.buildSectionTitle(context, 'Coffee'),
//           if (selectedFilter == 'All' || selectedFilter == 'Coffee')
//             CustomWidgets.buildFirebaseAnimatedListWithRatings(
//                 queryCoffee,
//                 'assets/images/coffee.png',
//                 getImages,
//                 getEstateRatings,
//                 selectedFilter),
//           Divider(),
//           if (selectedFilter == 'All' || selectedFilter == 'Restaurant')
//             CustomWidgets.buildSectionTitle(context, 'Restaurant'),
//           if (selectedFilter == 'All' || selectedFilter == 'Restaurant')
//             CustomWidgets.buildFirebaseAnimatedListWithRatings(
//                 queryRestaurant,
//                 'assets/images/restaurant.png',
//                 getImages,
//                 getEstateRatings,
//                 selectedFilter),
//         ],
//       ),
//     );
//   }
// }
//
// class FilterButton extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const FilterButton({
//     Key? key,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         decoration: BoxDecoration(
//           color: isSelected ? kPrimaryColor : Colors.grey[200],
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }
