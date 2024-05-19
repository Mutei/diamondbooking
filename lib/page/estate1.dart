import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import '../localization/language_constants.dart';
import '../models/Additional.dart';
import '../models/rooms.dart';
import '../widgets/cardEstate.dart';
import 'Estate.dart';
import 'filter.dart';
import 'filter_hotel.dart';

class EstatePage extends StatefulWidget {
  String type;
  String icon;
  Query query;
  EstatePage({required this.type, required this.icon, required this.query});
  @override
  _State createState() => new _State(type, query);
}

class _State extends State<EstatePage> {
  List<Estate> LstEstate = [];
  List<Rooms> LstRooms = [];
  Query query;
  final storageRef = FirebaseStorage.instance.ref();
  String type;
  _State(this.type, this.query);
  TextEditingController Search_Controller = TextEditingController();
  List<Additional> LstAdditional = [];
  int counter = 0;
  Map datauser = Map();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterLayoutWidgetBuild());
  }

  void afterLayoutWidgetBuild() async {
    String? id = FirebaseAuth.instance.currentUser?.uid;

    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref("App").child("User").child(id!);
    starCountRef.onValue.listen((DatabaseEvent event) {
      final Map data = event.snapshot.value as Map;
      setState(() {
        datauser = data;
      });
    });
  }

  late Map map = {};
  String varFiltterRes = "";
  String varFiltterSess = "";
  String varFiltterEntr = "";
  String varFiltterContre = "";
  String varFiltterPrice = "";
  String flagCity = "";
  String flagPrice = "";
  bool flag = false;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            Visibility(
                visible: true,
                child: IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () async {
                    if (type == "1") {
                      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                      final result =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FiltterHotel(
                                    Type: type,
                                  )));
                      if (result != null) {
                        setState(() {
                          varFiltterContre = result.split("&")[0].toString();
                          varFiltterPrice = result.split("&")[1].toString();
                          flag = true;
                          flagCity = result.split("&")[2].toString();
                          flagPrice = result.split("&")[3].toString();
                        });
                      }
                    } else {
                      print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
                      final result =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Filtter(
                                    Type: type,
                                  )));
                      if (result != null) {
                        setState(() {
                          varFiltterSess = result.split("&")[0].toString();
                          varFiltterRes = result.split("&")[1].toString();
                          varFiltterEntr = result.split("&")[2].toString();
                          flag = true;
                        });
                      }
                    }
                  },
                ))
          ],
          backgroundColor: const Color(0xFF84A5FA),
        ),
        body: SafeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    child: !flag
                        ? Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 10, bottom: 10, right: 5, top: 5),
                                child: Row(
                                  children: [
                                    // ignore: sort_child_properties_last
                                    Expanded(
                                      // ignore: sort_child_properties_last
                                      child: TextFormFieldStyle(),
                                      flex: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  bottom: 20,
                                ),
                                // ignore: sort_child_properties_last
                                child: FirebaseAnimatedList(
                                  shrinkWrap: true,
                                  defaultChild: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  itemBuilder:
                                      (context, snapshot, animation, index) {
                                    Map map = snapshot.value as Map;

                                    counter++;
                                    if (datauser['TypeAccount'] == "1") {
                                      if (map['State'] == datauser['State']) {
                                        if (Search_Controller.text.isEmpty) {
                                          return CardEstate(
                                              context: context,
                                              obj: map,
                                              icon: widget.icon,
                                              VisEdit: false,
                                              image: "",
                                              Visimage: false);
                                        } else {
                                          if (map['NameEn']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(Search_Controller
                                                      .text
                                                      .toLowerCase()) ||
                                              map['NameAr'].toString().contains(
                                                  Search_Controller.text)) {
                                            return CardEstate(
                                                context: context,
                                                obj: map,
                                                icon: widget.icon,
                                                VisEdit: false,
                                                image: "",
                                                Visimage: false);
                                          } else {
                                            return Container();
                                          }
                                        }
                                      }
                                    }
                                    if (datauser['TypeAccount'] == "2") {
                                      if (map['Country'] ==
                                          datauser['Country']) {
                                        if (Search_Controller.text.isEmpty) {
                                          return CardEstate(
                                              context: context,
                                              obj: map,
                                              icon: widget.icon,
                                              VisEdit: false,
                                              image: "",
                                              Visimage: false);
                                        } else {
                                          if (map['NameEn']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(Search_Controller
                                                      .text
                                                      .toLowerCase()) ||
                                              map['NameAr'].toString().contains(
                                                  Search_Controller.text
                                                      .toLowerCase())) {
                                            return CardEstate(
                                                context: context,
                                                obj: map,
                                                icon: widget.icon,
                                                VisEdit: false,
                                                image: "",
                                                Visimage: false);
                                          } else {
                                            return Container();
                                          }
                                        }
                                      }
                                    }
                                    if (datauser['TypeAccount'] == "3" ||
                                        datauser['TypeAccount'] == "4") {
                                      if (Search_Controller.text.isEmpty) {
                                        return CardEstate(
                                            context: context,
                                            obj: map,
                                            icon: widget.icon,
                                            VisEdit: false,
                                            image: "",
                                            Visimage: false);
                                      } else {
                                        if (map['NameEn']
                                                .toString()
                                                .toLowerCase()
                                                .contains(Search_Controller.text
                                                    .toLowerCase()) ||
                                            map['NameAr'].toString().contains(
                                                Search_Controller.text)) {
                                          return CardEstate(
                                              context: context,
                                              obj: map,
                                              icon: widget.icon,
                                              VisEdit: false,
                                              image: "",
                                              Visimage: false);
                                        } else {
                                          return Container();
                                        }
                                      }
                                    }

                                    return Container();
                                  },
                                  query: query,
                                ),

                                height: MediaQuery.of(context).size.height,
                              ),
                            ],
                          )
                        : type != "1"
                            ? Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, bottom: 10, right: 5, top: 5),
                                    child: Row(
                                      children: [
                                        // ignore: sort_child_properties_last
                                        Expanded(
                                          // ignore: sort_child_properties_last
                                          child: TextFormFieldStyle(),
                                          flex: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    // ignore: sort_child_properties_last
                                    child: FirebaseAnimatedList(
                                      shrinkWrap: true,
                                      defaultChild: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      itemBuilder: (context, snapshot,
                                          animation, index) {
                                        Map map = snapshot.value as Map;

                                        counter++;
                                        if (varFiltterRes.isNotEmpty) {
                                          if (map['State'] ==
                                              datauser['State']) {
                                            if (map['Sessions']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(varFiltterSess
                                                        .toLowerCase()) &&
                                                map['TypeofRestaurant']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(varFiltterRes
                                                        .toLowerCase()) &&
                                                map['Entry']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(varFiltterEntr
                                                        .toLowerCase())) {
                                              return CardEstate(
                                                  context: context,
                                                  obj: map,
                                                  icon: widget.icon,
                                                  VisEdit: false,
                                                  image: "",
                                                  Visimage: false);
                                            }
                                          }
                                        }
                                        if (datauser['TypeAccount'] == "2") {
                                          if (map['Country'] ==
                                              datauser['Country']) {
                                            {
                                              if (map['Sessions']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(varFiltterSess
                                                          .toLowerCase()) &&
                                                  map['TypeofRestaurant']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(varFiltterRes
                                                          .toLowerCase()) &&
                                                  map['Entry']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(varFiltterEntr
                                                          .toLowerCase())) {
                                                return CardEstate(
                                                    context: context,
                                                    obj: map,
                                                    icon: widget.icon,
                                                    VisEdit: false,
                                                    image: "",
                                                    Visimage: false);
                                              } else {
                                                return Container();
                                              }
                                            }
                                          }
                                        }
                                        if (datauser['TypeAccount'] == "3" ||
                                            datauser['TypeAccount'] == "4") {
                                          {
                                            if (map['Sessions']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(varFiltterSess
                                                        .toLowerCase()) &&
                                                map['TypeofRestaurant']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(varFiltterRes
                                                        .toLowerCase()) &&
                                                map['Entry']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(varFiltterEntr
                                                        .toLowerCase())) {
                                              return CardEstate(
                                                  context: context,
                                                  obj: map,
                                                  icon: widget.icon,
                                                  VisEdit: false,
                                                  image: "",
                                                  Visimage: false);
                                            } else {
                                              return Container();
                                            }
                                          }
                                        }

                                        return Container();
                                      },
                                      query: query,
                                    ),

                                    height: MediaQuery.of(context).size.height,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, bottom: 10, right: 5, top: 5),
                                    child: Row(
                                      children: [
                                        // ignore: sort_child_properties_last
                                        Expanded(
                                          // ignore: sort_child_properties_last
                                          child: TextFormFieldStyle(),
                                          flex: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    // ignore: sort_child_properties_last
                                    child: FirebaseAnimatedList(
                                      shrinkWrap: true,
                                      defaultChild: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      itemBuilder: (context, snapshot,
                                          animation, index) {
                                        Map map = snapshot.value as Map;

                                        counter++;
                                        if (flagCity == "0" &&
                                            flagPrice == "0") {
                                          if (map['Country']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(varFiltterContre
                                                      .split(",")[0]
                                                      .toLowerCase()) &&
                                              map['State']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(varFiltterContre
                                                      .split(",")[1]
                                                      .toLowerCase()) &&
                                              double.parse(map['Price']) >=
                                                  double.parse(varFiltterPrice
                                                      .split(",")[0]) &&
                                              double.parse(varFiltterPrice
                                                      .split(",")[1]) <=
                                                  double.parse(
                                                      map['PriceLast'])) {
                                            return CardEstate(
                                                context: context,
                                                obj: map,
                                                icon: widget.icon,
                                                VisEdit: false,
                                                image: "",
                                                Visimage: false);
                                          }
                                        } else if (flagCity == "0" &&
                                            flagPrice == "1") {
                                          if (map['Country']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(varFiltterContre
                                                      .split(",")[0]
                                                      .toLowerCase()) &&
                                              map['State']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(varFiltterContre
                                                      .split(",")[1]
                                                      .toLowerCase())) {
                                            return CardEstate(
                                                context: context,
                                                obj: map,
                                                icon: widget.icon,
                                                VisEdit: false,
                                                image: "",
                                                Visimage: false);
                                          }
                                        } else if (flagPrice == "0" &&
                                            flagCity == "1") {
                                          if (double.parse(map['Price']) >=
                                                  double.parse(varFiltterPrice
                                                      .split(",")[0]) &&
                                              double.parse(varFiltterPrice
                                                      .split(",")[1]) <=
                                                  double.parse(
                                                      map['PriceLast'])) {
                                            return CardEstate(
                                                context: context,
                                                obj: map,
                                                icon: widget.icon,
                                                VisEdit: false,
                                                image: "",
                                                Visimage: false);
                                          }
                                        }

                                        return Container();
                                      },
                                      query: query,
                                    ),

                                    height: MediaQuery.of(context).size.height,
                                  ),
                                ],
                              )))));
  }

  Widget TextFormFieldStyle() {
    return Container(
      height: 6.5.h,
      width: 150.w,
      margin: const EdgeInsets.only(right: 40, top: 10),
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        // ignore: prefer_const_literals_to_create_immutables
        boxShadow: [
          // ignore: prefer_const_constructors
          BoxShadow(
            color: Colors.grey,
            offset: const Offset(0.0, 1.0), //(x,y)
            blurRadius: 10.0,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        controller: Search_Controller,
        obscureText: false,
        onChanged: (String x) {
          setState(() {});
        },
        decoration: InputDecoration(
            // ignore: prefer_const_constructors
            icon: Icon(
              Icons.search,
              color: const Color(0xFF84A5FA),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: getTranslated(context, "Search"),
            hintStyle: TextStyle(fontSize: 12)
            //fillColor: Colors.green
            ),
        style: const TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}
