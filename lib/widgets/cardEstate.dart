import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../general_provider.dart';
import '../page/profileEstate.dart';

class CardEstate extends StatefulWidget {
  final BuildContext context;
  final Map obj;
  final String icon;
  final bool VisEdit;
  final String image;
  final bool? Visimage;
  final int? ratings;
  final double? totalRating;

  CardEstate({
    required this.context,
    required this.obj,
    required this.icon,
    required this.VisEdit,
    required this.image,
    this.Visimage,
    this.ratings,
    this.totalRating,
  });

  @override
  _State createState() => _State(context, obj, icon, VisEdit, image,
      Visimage ?? true, ratings!, totalRating!);
}

class _State extends State<CardEstate> {
  final BuildContext context;
  final Map obj;
  final String icon;
  final bool VisEdit;
  final String image;
  final bool Visimage;
  final int ratings;
  final double totalRating;

  final storageRef = FirebaseStorage.instance.ref();
  final databaseRef = FirebaseDatabase.instance.ref();
  String userType = "2";

  _State(
    this.context,
    this.obj,
    this.icon,
    this.VisEdit,
    this.image,
    this.Visimage,
    this.ratings,
    this.totalRating,
  );

  @override
  void initState() {
    super.initState();
    fetchUserType();
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
          print("User Type: $userType");
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

  Future<String> getimages(String EID) async {
    try {
      String imageUrl;
      imageUrl = await storageRef
          .child(EID + "/0.jpg")
          .getDownloadURL()
          .onError((error, stackTrace) => '')
          .then((value) => value);

      return imageUrl.toString();
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Column(
          children: [
            Visibility(
              visible: Visimage,
              child: FutureBuilder<String>(
                future: obj['IDEstate'] != null
                    ? getimages(obj['IDEstate'].toString())
                    : Future.value(""),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done &&
                      snapshot.data!.isNotEmpty) {
                    return Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: Image(
                        image: NetworkImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    return Center(
                      child: Text("No image available"),
                    );
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: ListTile(
                title: Text(
                  objProvider.CheckLangValue
                      ? (obj['NameEn'] ?? 'Unknown')
                      : (obj['NameAr'] ?? 'Unknown'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: !Visimage
                    ? Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Text(
                              obj['State'] ?? 'Unknown',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Visibility(
                              visible: obj["Type"] == 1 ? false : true,
                              child: Text(
                                obj["Sessions"]?.toString() ?? " ",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Visibility(
                              visible: obj["Type"] == 1 ? false : true,
                              child: Text(
                                obj["TypeofRestaurant"]?.toString() ?? " ",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        obj['State'] ?? 'Unknown',
                        style: TextStyle(fontSize: 12),
                      ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                      ),
                      child: Text(
                          '($ratings)  ${totalRating.toStringAsFixed(1)} ⭐'),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(visible: !Visimage, child: Divider())
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileEstate(
                  estate: obj,
                  icon: icon,
                  VisEdit: VisEdit,
                )));
      },
    );
  }
}
