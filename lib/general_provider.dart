import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/screen/chat_request_screen.dart';
import 'package:diamond_booking/screen/user_type_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralProvider with ChangeNotifier, DiagnosticableTreeMixin {
  Color color = Color(0xFFE8C75B);
  bool CheckLangValue = true;
  bool CheckLoginValue = false;
  Map UserMap = {};
  int _newRequestCount = 0;
  int _chatRequestCount = 0;

  int get newRequestCount => _newRequestCount;
  int get chatRequestCount => _chatRequestCount;

  FunSnackBarPage(String hint, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        hint,
        style: const TextStyle(
          color: kPrimaryColor,
        ),
      ),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future getUer() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    DatabaseReference starCountRef = FirebaseDatabase.instance
        .ref("App")
        .child("User")
        .child(sharedPreferences.getString("ID")!);
    starCountRef.onValue.listen((DatabaseEvent event) {
      UserMap = event.snapshot.value as Map;
    });
    notifyListeners();
  }

  List<CustomerType> TypeService() {
    List<CustomerType> LstCustomerType = [];
    LstCustomerType.add(CustomerType(
        image: "assets/images/restaurant.png",
        name: "Restaurant",
        type: "3",
        subtext: "Enjoy our top-rated restaurants."));
    LstCustomerType.add(CustomerType(
        image: "assets/images/coffee.png",
        name: "Coffee",
        type: "2",
        subtext: "Relax and unwind at our cozy cafes."));
    LstCustomerType.add(CustomerType(
        image: "assets/images/hotel.png",
        name: "Hotel",
        type: "1",
        subtext: "Stay at our luxurious hotels."));
    return LstCustomerType;
  }

  Future<bool> CheckLang() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? lang = sharedPreferences.getString("Language");
    if (lang == null || lang.isEmpty) {
      CheckLangValue = true;
      return true;
    } else if (lang == "en") {
      CheckLangValue = true;
      return true;
    } else if (lang == "ar") {
      CheckLangValue = false;
      return false;
    }
    return true;
  }

  void CheckLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("TypeUser") == "1") {
      // if was Customer return false
      CheckLoginValue = false;
    } else {
      CheckLoginValue = true;
    }
  }

  void fetchNewRequestCount() {
    String? id = FirebaseAuth.instance.currentUser?.uid;
    if (id != null) {
      FirebaseDatabase.instance
          .ref("App/Booking/Book")
          .orderByChild("IDOwner")
          .equalTo(id)
          .once()
          .then((DatabaseEvent event) {
        int count = 0;
        if (event.snapshot.value != null) {
          Map requests = event.snapshot.value as Map;
          requests.forEach((key, value) {
            if (value["Status"] == "1") {
              count++;
            }
          });
        }
        _newRequestCount = count;
        notifyListeners();
      });
    }
  }

  void resetNewRequestCount() {
    _newRequestCount = 0;
    notifyListeners();
  }

  void checkNewChatRequests(BuildContext context) {
    String? id = FirebaseAuth.instance.currentUser?.uid;
    if (id != null) {
      DatabaseReference refChatRequest =
          FirebaseDatabase.instance.ref("App/PrivateChatRequest").child(id);

      refChatRequest.onChildAdded.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          _chatRequestCount++;
          notifyListeners();
          _showNewChatRequestDialog(context);
        }
      });

      refChatRequest.onChildRemoved.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          _chatRequestCount--;
          notifyListeners();
        }
      });
    }
  }

  void _showNewChatRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Chat Request"),
          content: Text("You have received a new chat request."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("View"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PrivateChatRequest()));
              },
            ),
          ],
        );
      },
    );
  }
}

class CustomerType {
  late String name, image, type, subtext;
  CustomerType(
      {required this.image,
      required this.name,
      required this.type,
      required this.subtext});
}
