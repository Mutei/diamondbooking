import 'dart:math';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/extension/sized_box_extension.dart';
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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/services.dart';

import '../constants/styles.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/rooms.dart';
import '../screen/customer_points.dart';
import './chat.dart';
import 'additionalfacility.dart';
import 'chat_group.dart';
import 'editEstate.dart';

class ProfileEstate extends StatefulWidget {
  final Map estate;
  final String icon;
  final bool VisEdit;

  ProfileEstate({
    required this.estate,
    required this.icon,
    required this.VisEdit,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileEstateState createState() =>
      _ProfileEstateState(estate, icon, VisEdit);
}

class _ProfileEstateState extends State<ProfileEstate> {
  final Map estate;
  final String icon;
  final bool VisEdit;
  List<Rooms> LstRooms = [];
  List<Rooms> LstRoomsSelected = [];
  int count = 0;
  String ID = "";
  String TypUser = "";
  String checkGroup = "";
  final storageRef = FirebaseStorage.instance.ref();
  final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();
  final databaseRef = FirebaseDatabase.instance.ref();
  String userType = "2";
  DateTime selectedDate = DateTime.now();
  TimeOfDay? sTime = TimeOfDay.now();
  bool flagDate = false;
  bool flagTime = false;
  double rating = 0.0;
  final TextEditingController feedbackController = TextEditingController();
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackBarController;
  bool isOwner = false;
  bool hasChatAccess = false; // Added variable to track chat access

  _ProfileEstateState(this.estate, this.icon, this.VisEdit);

  @override
  void initState() {
    super.initState();
    getData();
    fetchUserType();
    checkIfOwner();
    checkChatAccess(); // Check chat access state on initialization
  }

  @override
  void dispose() {
    snackBarController?.close();
    feedbackController.dispose();
    super.dispose();
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
        }
      }
    } catch (e) {
      print("Failed to fetch user type: $e");
    }
  }

  Future<void> checkIfOwner() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isOwner = estate['IDUser'] == user.uid;
      });
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

  String generateUniqueID() {
    var random = Random();
    return (random.nextInt(90000) + 10000)
        .toString(); // Generates a 5-digit number
  }

  Future<void> _createBooking() async {
    if (flagDate && flagTime) {
      String uniqueID = generateUniqueID();
      String IDBook = uniqueID;

      DatabaseReference ref =
          FirebaseDatabase.instance.ref("App").child("Booking").child("Book");
      String? id = FirebaseAuth.instance.currentUser?.uid;

      // Fetch user information directly before creating the booking
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref("App").child("User").child(id!);
      DataSnapshot snapshot = await userRef.get();
      String firstName = "";
      String secondName = "";
      String lastName = "";
      String smokerStatus = "No";
      String allergies = "";

      if (snapshot.exists) {
        firstName = snapshot.child("FirstName").value?.toString() ?? "";
        secondName = snapshot.child("SecondName").value?.toString() ?? "";
        lastName = snapshot.child("LastName").value?.toString() ?? "";
        smokerStatus = snapshot.child("IsSmoker").value?.toString() ?? "No";
        allergies = snapshot.child("Allergies").value?.toString() ?? "";
      }

      String fullName = "$firstName $secondName $lastName";

      String? hour = sTime?.hour.toString().padLeft(2, '0');
      String? minute = sTime?.minute.toString().padLeft(2, '0');

      // Fetch user rating from ProviderFeedbackToCustomer
      double? userRating = await fetchUserRating(id);

      await ref.child(IDBook.toString()).set({
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
        "NameUser": fullName,
        "Smoker": smokerStatus,
        "Allergies": allergies,
        "Rating": userRating ?? 0.0,
      });

      Provider.of<GeneralProvider>(context, listen: false).FunSnackBarPage(
        getTranslated(context, "Successfully"),
        context,
      );
    }
  }

  Future<double?> fetchUserRating(String userId) async {
    DatabaseReference ratingsRef = FirebaseDatabase.instance
        .ref("App")
        .child("ProviderFeedbackToCustomer")
        .child(userId)
        .child("averageRating");

    DataSnapshot snapshot = await ratingsRef.get();
    if (snapshot.exists) {
      var ratingValue = snapshot.value;
      if (ratingValue is int) {
        return ratingValue.toDouble(); // Convert int to double
      } else if (ratingValue is double) {
        return ratingValue;
      } else {
        return null; // Return null if the value is not int or double
      }
    }
    return null;
  }

  Future<void> getData() async {
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

          // Debugging output
          print("FirstName: ${estate["FirstName"]}");
          print("SecondName: ${estate["SecondName"]}");
          print("LastName: ${estate["LastName"]}");
        });
      } else {
        print("User snapshot does not exist");
      }
    } else {
      print("ID is empty");
    }
  }

  Future<bool> checkChatAccess() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String accessTimeKey = 'access_time_${estate['IDEstate']}_$ID';
    String? accessEndTimeString = sharedPreferences.getString(accessTimeKey);

    if (accessEndTimeString != null) {
      DateTime accessEndTime = DateTime.parse(accessEndTimeString);
      if (accessEndTime.isAfter(DateTime.now())) {
        setState(() {
          hasChatAccess = true;
        });
        return true; // Access is still valid
      } else {
        setState(() {
          hasChatAccess = false;
        });
        return false; // Access has expired
      }
    } else {
      setState(() {
        hasChatAccess = false;
      });
      return false; // No valid access time found
    }
  }

  void _launchMaps() async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${estate['Lat']},${estate['Lon']}';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<List<String>> listPhotos(String EID) async {
    List<String> LstImage = [];
    final result = await FirebaseStorage.instance.ref().child(EID).listAll();
    for (var ref in result.items) {
      String url =
          await FirebaseStorage.instance.ref(ref.fullPath).getDownloadURL();
      LstImage.add(url);
    }
    return LstImage;
  }

  Future<String> splitText(String data) async {
    List<String> Lst = data.split(",");
    return Lst.map((e) => getTranslated(context, e)).join(" ,");
  }

  Future<String> getImages(String EID, String id) async {
    try {
      String imageUrl = await storageRef
          .child("Post")
          .child("$EID.jpg")
          .child(id)
          .getDownloadURL()
          .catchError((error) => '');
      return imageUrl;
    } catch (e) {
      return "";
    }
  }

  Future<String> getUserFullName(String userId) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App").child("User").child(userId);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      String firstName = snapshot.child("FirstName").value?.toString() ?? "";
      String secondName = snapshot.child("SecondName").value?.toString() ?? "";
      String lastName = snapshot.child("LastName").value?.toString() ?? "";
      return "$firstName $secondName $lastName";
    }
    return "";
  }

  void _showRatingSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.white, // Set the background color to white
      duration: const Duration(minutes: 5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                this.rating = rating;
              });
            },
          ),
          TextField(
            controller: feedbackController,
            maxLength: 30,
            maxLines: null,
            decoration: InputDecoration(
              labelText: getTranslated(context, "Add a Feedback"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  if (rating == 0) {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .FunSnackBarPage(
                      getTranslated(context, "Please provide a rating"),
                      context,
                    );
                  } else {
                    _saveRatingAndFeedback();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                },
                child: Text(getTranslated(context, "Send")),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text(getTranslated(context, "Cancel")),
              ),
            ],
          ),
        ],
      ),
    );
    snackBarController = ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _saveRatingAndFeedback() async {
    try {
      String estateId = estate['IDEstate'].toString();
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      String userName = await getUserFullName(userId);

      await databaseRef.child('App/CustomerFeedback/$estateId/$userId').set({
        'rating': rating,
        'feedback': feedbackController.text,
        'userName': userName,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update points for providing a rating
      await CustomerPoints.addPointsForRating();

      Provider.of<GeneralProvider>(context, listen: false).FunSnackBarPage(
        getTranslated(context, "Feedback submitted successfully"),
        context,
      );
    } catch (e) {
      Provider.of<GeneralProvider>(context, listen: false).FunSnackBarPage(
        getTranslated(context, "Failed to submit feedback"),
        context,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getFeedback() async {
    List<Map<String, dynamic>> feedbackList = [];
    DatabaseReference feedbackRef =
        databaseRef.child('App/CustomerFeedback/${estate['IDEstate']}');
    DataSnapshot snapshot = await feedbackRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> feedbackData =
          snapshot.value as Map<dynamic, dynamic>;
      feedbackData.forEach((key, value) {
        feedbackList.add({
          'userName': value['userName'],
          'rating': value['rating'],
          'feedback': value['feedback'],
        });
      });
    }
    return feedbackList;
  }

  void _copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey1,
      appBar: AppBar(
        elevation: 0,
        iconTheme: kIconTheme,
        actions: [
          if (userType == '2' && isOwner) ...[
            InkWell(
              child: Icon(Icons.message),
              onTap: () {
                if (ID != "null") {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Chat(
                            idEstate: estate['IDEstate'].toString(),
                            Name: estate['NameEn'],
                            Key: estate['IDUser'],
                            onAccessChange: (access) {
                              setState(() {
                                hasChatAccess = access;
                              });
                            },
                          )));
                } else {
                  objProvider.FunSnackBarPage(
                      getTranslated(context, "Please login first"), context);
                }
              },
            ),
            25.kW,
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
            25.kW,
            InkWell(
              child: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditEstate(
                          objEstate: estate,
                          LstRooms: LstRooms,
                        )));
              },
            ),
            25.kW,
          ],
          if (userType == '1') ...[
            InkWell(
              child: Icon(Icons.message),
              onTap: () {
                if (ID != "null") {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Chat(
                            idEstate: estate['IDEstate'].toString(),
                            Name: estate['NameEn'],
                            Key: estate['IDUser'],
                            onAccessChange: (access) {
                              setState(() {
                                hasChatAccess = access;
                              });
                            },
                          )));
                } else {
                  objProvider.FunSnackBarPage(
                      getTranslated(context, "Please login first"), context);
                }
              },
            ),
            25.kW,
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
            25.kW,
            InkWell(
              child: Text(
                getTranslated(context, "Rate"),
                style: TextStyle(
                  color: hasChatAccess
                      ? kPrimaryColor
                      : Colors.grey, // Change color based on access
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                if (hasChatAccess) {
                  bool isValid =
                      await checkChatAccess(); // Check if chat access is still valid
                  if (isValid) {
                    // If access is valid, show the rating snackbar
                    _showRatingSnackbar(context);
                  } else {
                    // If access is no longer valid, update the state
                    setState(() {
                      hasChatAccess = false;
                    });
                    // Optionally, show a message that access has expired
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          getTranslated(context, "Rate Access has Expired."),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            25.kW,
          ],
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
                    color: kPrimaryColor,
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
                                child: Image.network(snapshot.data![index],
                                    fit: BoxFit.fitWidth),
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
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
                        "${estate["Country"]} \\ ${estate["State"]}",
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
                          child: Image.asset(icon, width: 35, height: 35),
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
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  Visibility(
                    visible: estate["Type"] == "1",
                    child: TextHeader("Rooms", context),
                  ),
                  Visibility(
                    visible: estate["Type"] == "1",
                    child: FirebaseAnimatedList(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      defaultChild:
                          const Center(child: CircularProgressIndicator()),
                      itemBuilder: (context, snapshot, animation, index) {
                        Map map = snapshot.value as Map;
                        map['Key'] = snapshot.key;
                        Rooms room = Rooms(
                          id: map['ID'],
                          name: map['Name'],
                          nameEn: map['Name'],
                          price: map['Price'],
                          bio: map['BioAr'],
                          bioEn: map['BioEn'],
                          color: Colors.white,
                        );

                        bool isSelected = LstRoomsSelected.any(
                            (element) => element.id == room.id);

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              if (isSelected) {
                                LstRoomsSelected.removeWhere(
                                    (element) => element.id == room.id);
                              } else {
                                LstRoomsSelected.add(room);
                              }
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            child: ListTile(
                              title: Text(
                                getTranslated(context, room.name),
                                style: TextStyle(
                                  color:
                                      isSelected ? kPrimaryColor : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                objProvider.CheckLangValue
                                    ? room.bioEn
                                    : room.bio,
                                style: TextStyle(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Colors.black54,
                                ),
                              ),
                              leading: const Icon(
                                Icons.single_bed,
                                color: Colors.black,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    room.price,
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 18),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: kPrimaryColor,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      query: FirebaseDatabase.instance
                          .ref("App")
                          .child("Rooms")
                          .child(estate['IDEstate'].toString()),
                    ),
                  ),
                  if (estate.containsKey("MenuLink") &&
                      estate["MenuLink"].isNotEmpty)
                    ListTile(
                      title: Text(
                        getTranslated(context, 'Menu Link'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: InkWell(
                        onTap: () async {
                          final url = estate["MenuLink"];
                          try {
                            await _launchURL(url);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch $url')),
                            );
                          }
                        },
                        onLongPress: () {
                          _copyLink(estate["MenuLink"]);
                        },
                        child: Text(
                          estate["MenuLink"],
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  Visibility(
                    visible: estate["Type"] == "2" || estate["Type"] == "3",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (estate["Type"] == "3")
                          ListTile(
                            title: Text(
                                getTranslated(context, "Type of Restaurant"),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: FutureBuilder<String>(
                              future: splitText(
                                  estate["TypeofRestaurant"].toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  return Text(snapshot.data.toString(),
                                      style: TextStyle(fontSize: 12));
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        if (estate["Type"] == "2" || estate["Type"] == "3")
                          ListTile(
                            title: Text(getTranslated(context, "Entry allowed"),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: FutureBuilder<String>(
                              future: splitText(estate["Entry"].toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  return Text(snapshot.data.toString(),
                                      style: TextStyle(fontSize: 12));
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        if (estate["Type"] == "2" || estate["Type"] == "3")
                          ListTile(
                            title: Text(getTranslated(context, "Sessions type"),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: FutureBuilder<String>(
                              future: splitText(estate["Sessions"].toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  return Text(snapshot.data.toString(),
                                      style: TextStyle(fontSize: 12));
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        if (estate["Type"] == "3")
                          ListTile(
                            title: Text(
                              getTranslated(
                                  context,
                                  estate["Music"] == "1"
                                      ? "There is music"
                                      : "There is no music"),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (estate["Type"] == "2")
                          ListTile(
                            title:
                                Text(getTranslated(context, "Is there music"),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                            subtitle: Text(estate["Lstmusic"],
                                style: const TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  FirebaseAnimatedList(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    defaultChild:
                        const Center(child: CircularProgressIndicator()),
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
                                future: getImages(estate['IDEstate'].toString(),
                                    map["IDPost"]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: snapshot.data!.isNotEmpty
                                          ? Image.network(snapshot.data!,
                                              fit: BoxFit.cover)
                                          : Container(),
                                    );
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              ),
                              if (VisEdit)
                                Align(
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
                                              child: Text(getTranslated(
                                                  context, "delete"))),
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
                            ],
                          ),
                        );
                      }
                      return Container();
                    },
                    query: FirebaseDatabase.instance
                        .ref("App")
                        .child("Post")
                        .child(estate['IDEstate'].toString())
                        .orderByChild("Date"),
                  ),
                  const SizedBox(height: 20),
                  // Feedback section
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getFeedback(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text(
                            getTranslated(context, "Error loading feedback"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(); // Return an empty container when there's no feedback
                      }

                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var feedback = snapshot.data![index];
                            return Container(
                              width: 300,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        feedback['userName'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 10),
                                      RatingBarIndicator(
                                        rating: feedback['rating'].toDouble(),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 20.0,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(feedback['feedback']),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (userType == '2' && isOwner)
                Align(
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
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                                getTranslated(context, "GenerateQRCode"),
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => QRImage(
                                    userId: estate['IDUser'],
                                    userName: estate['NameEn'],
                                    estateId: estate['IDEstate'].toString(),
                                  )));
                        },
                      ),
                    ],
                  ),
                ),
              if (userType == "1")
                Align(
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
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(getTranslated(context, "Next"),
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        onTap: () async {
                          if (ID != "null") {
                            if (estate['Type'] == "1") {
                              if (LstRoomsSelected.isEmpty) {
                                objProvider.FunSnackBarPage(
                                    "Choose Room Before", context);
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AdditionalFacility(
                                          CheckState: "",
                                          CheckIsBooking: true,
                                          estate: estate,
                                          IDEstate:
                                              estate['IDEstate'].toString(),
                                          Lstroom: LstRoomsSelected,
                                        )));
                              }
                            } else {
                              await _selectDate(context);
                              await selectTime(context);
                              await _createBooking();
                            }
                          } else {
                            objProvider.FunSnackBarPage(
                                getTranslated(context, "Please login first"),
                                context);
                          }
                        },
                      ),
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
                                getTranslated(context, "Chat with Group"),
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Chat(
                              idEstate: estate['IDEstate'].toString(),
                              Name: estate['NameEn'],
                              Key: estate['IDUser'],
                              onAccessChange: (access) {
                                setState(() {
                                  hasChatAccess = access;
                                });
                              },
                            ),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
