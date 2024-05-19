// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';

class Filtter extends StatefulWidget {
  @override
  String Type;

  Filtter({required this.Type});
  _State createState() => new _State(Type);
}

class _State extends State<Filtter> {
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  String Type = "";
  _State(this.Type);
  bool checkpopularrestaurant = false;
  bool checkIndianRestaurant = false;
  bool checkItalian = false;
  bool checkSeafoodRestaurant = false;
  bool checkFastFood = false;
  bool checkSteak = false;
  bool checkGrills = false;
  bool checkhealthy = false;
  bool checkmixed = false;
  bool checkFamilial = false;
  bool checkIsmusic = false;
  bool checkSingle = false;
  bool checkinternal = false;
  bool checkExternal = false;
  bool haveMusce = false;
  bool havesinger = false;
  bool haveDJ = false;
  bool haveOud = false;
  List<String> LstTypeofRestaurant = [];
  List<String> LstEntry = [];
  List<String> LstSessions = [];
  List<String> Lstmusic = [];
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF84A5FA),
      ),
      body: Container(
          child: Stack(
        children: [
          ListView(
            children: [
              Visibility(
                  visible: Type == "3" ? true : false,
                  child: TextHedar("Type of Restaurant")),
              Visibility(
                  // type of Restaurant
                  visible: Type == "3" ? true : false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(
                                    context, "popular restaurant"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkpopularrestaurant,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkpopularrestaurant = value!;
                                    if (checkpopularrestaurant) {
                                      LstTypeofRestaurant.add(
                                          "popular restaurant");
                                    } else {
                                      LstTypeofRestaurant.remove(
                                          "popular restaurant");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(
                                    context, "Indian Restaurant"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkIndianRestaurant,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkIndianRestaurant = value!;
                                    if (checkIndianRestaurant) {
                                      LstTypeofRestaurant.add(
                                          "Indian Restaurant");
                                    } else {
                                      LstTypeofRestaurant.remove(
                                          "Indian Restaurant");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "Italian"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkItalian,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkItalian = value!;
                                    if (checkItalian) {
                                      LstTypeofRestaurant.add("Italian");
                                    } else {
                                      LstTypeofRestaurant.remove("Italian");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(
                                    context, "Seafood Restaurant"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkSeafoodRestaurant,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkSeafoodRestaurant = value!;
                                    if (checkSeafoodRestaurant) {
                                      LstTypeofRestaurant.add(
                                          "Seafood Restaurant");
                                    } else {
                                      LstTypeofRestaurant.remove(
                                          "Seafood Restaurant");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child:
                                    Text(getTranslated(context, "Fast Food"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkFastFood,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkFastFood = value!;
                                    if (checkFastFood) {
                                      LstTypeofRestaurant.add("Fast Food");
                                    } else {
                                      LstTypeofRestaurant.remove("Fast Food");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "Steak"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkSteak,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkSteak = value!;
                                    if (checkSteak) {
                                      LstTypeofRestaurant.add("Steak");
                                    } else {
                                      LstTypeofRestaurant.remove("Steak");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "Grills"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkGrills,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkGrills = value!;
                                    if (checkGrills) {
                                      LstTypeofRestaurant.add("Grills");
                                    } else {
                                      LstTypeofRestaurant.remove("Grills");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "healthy"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkhealthy,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkhealthy = value!;
                                    if (checkhealthy) {
                                      LstTypeofRestaurant.add("healthy");
                                    } else {
                                      LstTypeofRestaurant.remove("healthy");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
              // ignore: prefer_const_constructors
              SizedBox(
                height: 15,
              ),
              Visibility(
                  visible: Type == "3" || Type == "2" ? true : false,
                  child: TextHedar("Entry allowed")),
              Visibility(
                  visible: Type == "3" || Type == "2" ? true : false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child:
                                    Text(getTranslated(context, "Familial"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkFamilial,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkFamilial = value!;
                                    if (checkFamilial) {
                                      LstEntry.add("Familial");
                                    } else {
                                      LstEntry.remove("Familial");
                                    }
                                    //  print(LstTypeofRestaurant.join("-"));
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "Single2"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkSingle,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkSingle = value!;
                                    if (checkSingle) {
                                      LstEntry.add("Single");
                                    } else {
                                      LstEntry.remove("Single");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "mixed"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkmixed,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkmixed = value!;
                                    if (checkmixed) {
                                      LstEntry.add("mixed");
                                    } else {
                                      LstEntry.remove("mixed");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),

              Visibility(
                  visible: Type == "3" || Type == "2" ? true : false,
                  child: TextHedar("Sessions type")),
              Visibility(
                  visible: Type == "3" || Type == "2" ? true : false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(
                                    context, "internal sessions"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkinternal,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkinternal = value!;
                                    if (checkinternal) {
                                      LstSessions.add("internal sessions");
                                    } else {
                                      LstEntry.remove("internal sessions");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(
                                    context, "External sessions"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkExternal,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkExternal = value!;
                                    if (checkExternal) {
                                      LstSessions.add("External sessions");
                                    } else {
                                      LstEntry.remove("External sessions");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
              // ignore: prefer_const_constructors
              SizedBox(
                height: 40,
              ),
              // ignore: prefer_const_constructors
              Divider(),
              Visibility(
                  visible: Type == "3" || Type == "2" ? true : false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    getTranslated(context, "Is there music"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: checkIsmusic,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkIsmusic = value!;
                                    if (checkIsmusic && Type == "2") {
                                      haveMusce = true;
                                    } else {
                                      haveMusce = false;
                                      havesinger = false;
                                      haveDJ = false;
                                      haveOud = false;
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),

              //////////////////////////////////////////Restaurant
              ///
              ///Coffe

              Visibility(
                  visible: haveMusce && Type == "2" ? true : false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "singer"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: havesinger,
                                onChanged: (bool? value) {
                                  setState(() {
                                    havesinger = value!;
                                    if (havesinger) {
                                      Lstmusic.add("singer");
                                    } else {
                                      LstEntry.remove("singer");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text(getTranslated(context, "DJ"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: haveDJ,
                                onChanged: (bool? value) {
                                  setState(() {
                                    haveDJ = value!;
                                    if (haveDJ) {
                                      Lstmusic.add("DJ");
                                    } else {
                                      LstEntry.remove("DJ");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(getTranslated(context, "Oud"))),
                            Expanded(
                              child: Checkbox(
                                checkColor: Colors.white,
                                value: haveOud,
                                onChanged: (bool? value) {
                                  setState(() {
                                    haveOud = value!;
                                    if (haveOud) {
                                      Lstmusic.add("Oud");
                                    } else {
                                      LstEntry.remove("Oud");
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 60,
                        )
                      ],
                    ),
                  )),
            ],
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                child: InkWell(
                  onTap: () {
                    String text =
                        "${LstSessions.join(",")}&${LstTypeofRestaurant.join(",")}&${LstEntry.join(",")}";
                    Navigator.pop(context, text);
                  },
                  child: Container(
                    width: 150.w,
                    height: 4.h,
                    margin: const EdgeInsets.only(
                        right: 40, left: 40, bottom: 20, top: 70),
                    decoration: BoxDecoration(
                      color: const Color(0xFF84A5FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text("Save"),
                    ),
                  ),
                ),
              ))
        ],
      )),
    );
  }

  TextHedar(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      child: Text(
        getTranslated(context, text),
        // ignore: prefer_const_constructors
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
    );
  }
}
