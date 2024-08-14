import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:badges/badges.dart' as badges;

import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../page/Estate.dart';
import '../widgets/main_screen_widgets.dart';
import '../page/request.dart';
import '../page/type_estate.dart';
import '../page/upgrade_account.dart';
import '../resources/firebase_services.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/filter_button.dart';
import '../widgets/reused_estate_page.dart';
import 'all_posts_screen.dart';
import 'chat_request_screen.dart';
import '../page/notification_user.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

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
  String _selectedFilter = 'All';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false; // Add this line

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _firebaseServices.afterLayoutWidgetBuild(setUserData, setID));
    _firebaseServices.initMessage(showNotification);
    _firebaseServices.getUserType(setUserType, setPermissionStatus);
    Provider.of<GeneralProvider>(context, listen: false).fetchNewRequestCount();
    Provider.of<GeneralProvider>(context, listen: false)
        .checkNewChatRequests(context);
    _loadUserType();
    _requestPermissions();
  }

  void _requestPermissions() async {
    var status = await Permission.location.request();
    setPermissionStatus(status);

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

  Future<String> _getImages(String key) async {
    // Implement your image fetching logic here
    return 'assets/images/default_image.png';
  }

  Future<Map<String, dynamic>> _getEstateRatings(String estateId) async {
    Map<String, dynamic> ratingsData = {"totalRating": 0.0, "ratingCount": 0};

    DatabaseReference feedbackRef =
        FirebaseDatabase.instance.ref('App/CustomerFeedback/$estateId');
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

  void showNotification(RemoteNotification? notification) async {
    var androidDetails = const AndroidNotificationDetails(
      '1', // Channel ID
      'channelName', // Channel name
      importance: Importance.max,
      priority: Priority.high,
      icon:
          'ic_notification', // The name of your icon file (without the .png extension)
    );
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
    setState(() {
      _searchController.text = text;
    });
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
    setState(() {
      _searchController.clear();
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
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
      backgroundColor: Colors.white,
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _onSearchTextChanged,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  hintText: getTranslated(context, "Search..."),
                  hintStyle: const TextStyle(color: kPrimaryColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: kPrimaryColor),
                    onPressed: _stopSearch,
                  ),
                ),
              )
            : Text(
                getTranslated(context, "Diamond Booking"),
                style: const TextStyle(color: kPrimaryColor),
              ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: kIconTheme,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: kPrimaryColor),
              onPressed: _startSearch,
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
                      selectedFilter: _selectedFilter,
                      onFilterChanged: _onFilterChanged,
                      getEstateRatings: _getEstateRatings,
                      searchQuery: _searchController.text,
                    ),
                  ),
                ),
                NotificationUser(),
                UpgradeAccount(),
                AllPostsScreen(),
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
                      selectedFilter: _selectedFilter,
                      onFilterChanged: _onFilterChanged,
                      getEstateRatings: _getEstateRatings,
                      searchQuery: _searchController.text,
                    ),
                  ),
                ),
                Request(),
                AllPostsScreen(),
              ],
      ),
    );
  }
}
