import 'package:diamond_booking/chooseCity.dart';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../constants/reused_provider_estate_container.dart';
import '../localization/language_constants.dart';
import '../models/rooms.dart';
import '../page/maps.dart';
import '../widgets/text_form_style.dart';
import 'maps_screen.dart';

class AddEstatesScreen extends StatefulWidget {
  String userType;
  AddEstatesScreen({
    super.key,
    required this.userType,
  });

  @override
  State<AddEstatesScreen> createState() => _AddEstatesScreenState();
}

class _AddEstatesScreenState extends State<AddEstatesScreen> {
  TextEditingController arNameController = TextEditingController();
  TextEditingController arBioController = TextEditingController();
  TextEditingController enNameController = TextEditingController();
  TextEditingController enBioController = TextEditingController();
  TextEditingController facilityNumberController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController singleHotelRoomController = TextEditingController();
  TextEditingController doubleHotelRoomController = TextEditingController();
  TextEditingController suiteHotelRoomController = TextEditingController();
  TextEditingController singleHotelRoomControllerBioAr =
      TextEditingController();
  TextEditingController singleHotelRoomControllerBioEn =
      TextEditingController();
  TextEditingController doubleHotelRoomControllerBioEn =
      TextEditingController();
  TextEditingController doubleHotelRoomControllerBioAr =
      TextEditingController();
  TextEditingController suiteHotelRoomControllerBioEn = TextEditingController();
  TextEditingController suiteHotelRoomControllerBioAr = TextEditingController();
  TextEditingController familyHotelRoomController = TextEditingController();
  TextEditingController familyHotelRoomControllerBioAr =
      TextEditingController();
  TextEditingController familyHotelRoomControllerBioEn =
      TextEditingController();
  List<String> listTypeOfRestaurant = [];
  List<String> listEntry = [];
  List<String> listSessions = [];
  List<String> listMusic = [];
  List<Rooms> listRooms = [];
  bool single = false;
  bool double = false;
  bool suite = false;
  bool family = false;
  bool checkPopularRestaurants = false;
  bool checkIndianRestaurant = false;
  bool checkItalianRestaurant = false;
  bool checkSeafoodRestaurant = false;
  bool checkFastFoodRestaurant = false;
  bool checkSteak = false;
  bool checkGrills = false;
  bool checkHealthy = false;
  bool checkFamilial = false;
  bool checkSingle = false;
  bool checkMixed = false;
  bool checkInternal = false;
  bool checkExternal = false;
  bool checkMusic = false;
  bool haveMusic = false;
  bool haveSinger = false;
  bool haveDJ = false;
  bool haveOud = false;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  int? idEstate;

  late DatabaseReference ref;
  late DatabaseReference refID;
  late Widget btnLogin;

  @override
  void initState() {
    super.initState();
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Initialize the DatabaseReference variables
    ref = FirebaseDatabase.instance
        .ref("App")
        .child("Users")
        .child(userId)
        .child("Estate");
    refID = FirebaseDatabase.instance.ref("App").child("EstateID");
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref("App").child("EstateID");
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;
      idEstate = data['EstateID'] ?? 1;
    });
  }

  closeTextFormFieldStyle(Function() fun) {
    // ignore: sort_child_properties_last
    return InkWell(
      // ignore: sort_child_properties_last
      child: Container(

          // ignore: prefer_const_constructors
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            // ignore: prefer_const_literals_to_create_immutables
            boxShadow: [
              // ignore: prefer_const_constructors
              BoxShadow(blurRadius: 10, color: Colors.grey, spreadRadius: 1)
            ],
          ),
          // ignore: prefer_const_constructors
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          )),
      onTap: fun,
    );
  }

  Future<String?> getTypeAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString("ID")!;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("App")
        .child("Users")
        .child(userId)
        .child("TypeAccount");
    DataSnapshot snapshot = await ref.get();
    return snapshot.value as String?;
  }

  @override
  Widget build(BuildContext context) {
    btnLogin = Text(
      getTranslated(context, "Next"),
    );
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: 20,
            ),
            child: SafeArea(
              child: ListView(
                children: [
                  25.kH,
                  const ReusedProviderEstateContainer(
                    hint: "Information in Arabic",
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Name",
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.restaurant,
                      color: kPrimaryColor,
                    ),
                    control: arNameController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Bio",
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.menu,
                      color: kPrimaryColor,
                    ),
                    control: arBioController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  40.kH,
                  const ReusedProviderEstateContainer(
                    hint: "Information in English",
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Name",
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.restaurant,
                      color: kPrimaryColor,
                    ),
                    control: enNameController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Bio",
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.menu,
                      color: kPrimaryColor,
                    ),
                    control: enBioController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  40.kH,
                  const ReusedProviderEstateContainer(
                    hint: "Legal information",
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "No. facility",
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.restaurant,
                      color: kPrimaryColor,
                    ),
                    control: facilityNumberController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Tax Number",
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.menu,
                      color: kPrimaryColor,
                    ),
                    control: taxNumberController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  80.kH,
                  Visibility(
                    visible: widget.userType == "3" ? true : false,
                    child: const ReusedProviderEstateContainer(
                      hint: "Type of Restaurant",
                    ),
                  ),
                  Visibility(
                    // type of Restaurant
                    visible: widget.userType == "3" ? true : false,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  getTranslated(context, "popular restaurant"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkPopularRestaurants,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkPopularRestaurants = value!;
                                      if (checkPopularRestaurants) {
                                        listTypeOfRestaurant
                                            .add("popular restaurant");
                                      } else {
                                        listTypeOfRestaurant
                                            .remove("popular restaurant");
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
                                child: Text(
                                  getTranslated(context, "Indian Restaurant"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkIndianRestaurant,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkIndianRestaurant = value!;
                                      if (checkIndianRestaurant) {
                                        listTypeOfRestaurant
                                            .add("Indian Restaurant");
                                      } else {
                                        listTypeOfRestaurant
                                            .remove("Indian Restaurant");
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
                                child: Text(
                                  getTranslated(context, "Italian"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkItalianRestaurant,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkItalianRestaurant = value!;
                                      if (checkItalianRestaurant) {
                                        listTypeOfRestaurant.add("Italian");
                                      } else {
                                        listTypeOfRestaurant.remove("Italian");
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
                                child: Text(
                                  getTranslated(context, "Seafood Restaurant"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkSeafoodRestaurant,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkSeafoodRestaurant = value!;
                                      if (checkSeafoodRestaurant) {
                                        listTypeOfRestaurant
                                            .add("Seafood Restaurant");
                                      } else {
                                        listTypeOfRestaurant
                                            .remove("Seafood Restaurant");
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
                                child: Text(
                                  getTranslated(context, "Fast Food"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkFastFoodRestaurant,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkFastFoodRestaurant = value!;
                                      if (checkFastFoodRestaurant) {
                                        listTypeOfRestaurant.add("Fast Food");
                                      } else {
                                        listTypeOfRestaurant
                                            .remove("Fast Food");
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
                                child: Text(
                                  getTranslated(context, "Steak"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkSteak,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkSteak = value!;
                                      if (checkSteak) {
                                        listTypeOfRestaurant.add("Steak");
                                      } else {
                                        listTypeOfRestaurant.remove("Steak");
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
                                child: Text(
                                  getTranslated(context, "Grills"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkGrills,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkGrills = value!;
                                      if (checkGrills) {
                                        listTypeOfRestaurant.add("Grills");
                                      } else {
                                        listTypeOfRestaurant.remove("Grills");
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
                                child: Text(
                                  getTranslated(context, "healthy"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkHealthy,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkHealthy = value!;
                                      if (checkHealthy) {
                                        listTypeOfRestaurant.add("healthy");
                                      } else {
                                        listTypeOfRestaurant.remove("healthy");
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  15.kH,
                  Visibility(
                    visible: widget.userType == "3" || widget.userType == "2"
                        ? true
                        : false,
                    child: const ReusedProviderEstateContainer(
                      hint: "Entry allowed",
                    ),
                  ),
                  Visibility(
                      visible: widget.userType == "3" || widget.userType == "2"
                          ? true
                          : false,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    getTranslated(context, "Familial"),
                                  ),
                                ),
                                Expanded(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: checkFamilial,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkFamilial = value!;
                                        if (checkFamilial) {
                                          listEntry.add("Familial");
                                        } else {
                                          listEntry.remove("Familial");
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
                                  child: Text(
                                    getTranslated(context, "Single2"),
                                  ),
                                ),
                                Expanded(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: checkSingle,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkSingle = value!;
                                        if (checkSingle) {
                                          listEntry.add("Single");
                                        } else {
                                          listEntry.remove("Single");
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
                                  child: Text(
                                    getTranslated(context, "mixed"),
                                  ),
                                ),
                                Expanded(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: checkMixed,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkMixed = value!;
                                        if (checkMixed) {
                                          listEntry.add("mixed");
                                        } else {
                                          listEntry.remove("mixed");
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
                    visible: widget.userType == "3" || widget.userType == "2"
                        ? true
                        : false,
                    child: const ReusedProviderEstateContainer(
                      hint: 'Sessions type',
                    ),
                  ),
                  Visibility(
                    visible: widget.userType == "3" || widget.userType == "2"
                        ? true
                        : false,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  getTranslated(context, "internal sessions"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkInternal,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkInternal = value!;
                                      if (checkInternal) {
                                        listSessions.add("internal sessions");
                                      } else {
                                        listEntry.remove("internal sessions");
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  getTranslated(context, "External sessions"),
                                ),
                              ),
                              Expanded(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: checkExternal,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkExternal = value!;
                                      if (checkExternal) {
                                        listSessions.add("External sessions");
                                      } else {
                                        listEntry.remove("External sessions");
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  40.kH,
                  Visibility(
                      visible: widget.userType == "3" || widget.userType == "2"
                          ? true
                          : false,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(getTranslated(
                                        context, "Is there music"))),
                                Expanded(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: checkMusic,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkMusic = value!;
                                        if (checkMusic &&
                                            widget.userType == "2") {
                                          haveMusic = true;
                                        } else {
                                          haveMusic = false;
                                          haveSinger = false;
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
                  Visibility(
                      visible:
                          haveMusic && widget.userType == "2" ? true : false,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child:
                                        Text(getTranslated(context, "singer"))),
                                Expanded(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: haveSinger,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        haveSinger = value!;
                                        if (haveSinger) {
                                          listMusic.add("singer");
                                        } else {
                                          listEntry.remove("singer");
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
                                    child: Text(getTranslated(context, "DJ"))),
                                Expanded(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: haveDJ,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        haveDJ = value!;
                                        if (haveDJ) {
                                          listMusic.add("DJ");
                                        } else {
                                          listEntry.remove("DJ");
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
                                          listMusic.add("Oud");
                                        } else {
                                          listEntry.remove("Oud");
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
                  40.kH,
                  const ReusedProviderEstateContainer(
                    hint: "Location information",
                  ),
                  20.kH,
                  CustomCSCPicker(
                    onCountryChanged: (value) {
                      setState(() {
                        countryValue = value;
                      });
                    },
                    onStateChanged: (value) {
                      setState(() {
                        stateValue = value;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        cityValue = value;
                      });
                    },
                  ),
                  40.kH,
                  Visibility(
                    visible: widget.userType == "1" ? true : false,
                    child: const ReusedProviderEstateContainer(
                        hint: "What We have ?"),
                  ),
                  Visibility(
                    visible: widget.userType == "1" ? true : false,
                    child: Column(
                      children: [
                        Visibility(
                            visible: !single,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ignore: prefer_const_constructors
                                  Text(
                                    getTranslated(context, "Single"),
                                    // ignore: prefer_const_constructors
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    value: single,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        single = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                        // ignore: sort_child_properties_last
                        Visibility(
                          // ignore: sort_child_properties_last
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReusedProviderEstateContainer(
                                          hint: "Single"),
                                      TextFormFieldStyle(
                                          context: context,
                                          hint: "Single1",
                                          // ignore: prefer_const_constructors
                                          icon: Icon(
                                            Icons.single_bed,
                                            color: const Color(0xFF84A5FA),
                                          ),
                                          control: singleHotelRoomController,
                                          isObsecured: false,
                                          validate: true,
                                          textInputType: TextInputType.number),
                                      TextFormFieldStyle(
                                          context: context,
                                          hint: "Bio",
                                          // ignore: prefer_const_constructors
                                          icon: Icon(
                                            Icons.single_bed,
                                            color: const Color(0xFF84A5FA),
                                          ),
                                          control:
                                              singleHotelRoomControllerBioAr,
                                          isObsecured: false,
                                          validate: true,
                                          textInputType: TextInputType.text),
                                      TextFormFieldStyle(
                                          context: context,
                                          hint: "BioEn",
                                          // ignore: prefer_const_constructors
                                          icon: Icon(
                                            Icons.single_bed,
                                            color: const Color(0xFF84A5FA),
                                          ),
                                          control:
                                              singleHotelRoomControllerBioEn,
                                          isObsecured: false,
                                          validate: true,
                                          textInputType: TextInputType.text)
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(child: closeTextFormFieldStyle(
                                () {
                                  setState(() {
                                    single = false;
                                  });
                                },
                              ))
                            ],
                          ),
                          visible: single,
                        ),
                        Visibility(
                            visible: !double,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ignore: prefer_const_constructors
                                  Text(
                                    getTranslated(context, "Double"),
                                    // ignore: prefer_const_constructors
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    value: double,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        double = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                        Visibility(
                            visible: double,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const ReusedProviderEstateContainer(
                                            hint: 'Double',
                                          ),
                                          TextFormFieldStyle(
                                              context: context,
                                              hint: "Double1",
                                              // ignore: prefer_const_constructors
                                              icon: Icon(
                                                Icons.single_bed,
                                                color: const Color(0xFF84A5FA),
                                              ),
                                              control:
                                                  doubleHotelRoomController,
                                              isObsecured: false,
                                              validate: true,
                                              textInputType:
                                                  TextInputType.number),
                                          TextFormFieldStyle(
                                              context: context,
                                              hint: "Bio",
                                              // ignore: prefer_const_constructors
                                              icon: Icon(
                                                Icons.single_bed,
                                                color: const Color(0xFF84A5FA),
                                              ),
                                              control:
                                                  doubleHotelRoomControllerBioAr,
                                              isObsecured: false,
                                              validate: true,
                                              textInputType:
                                                  TextInputType.text),
                                          TextFormFieldStyle(
                                              context: context,
                                              hint: "BioEn",
                                              // ignore: prefer_const_constructors
                                              icon: Icon(
                                                Icons.single_bed,
                                                color: const Color(0xFF84A5FA),
                                              ),
                                              control:
                                                  doubleHotelRoomControllerBioEn,
                                              isObsecured: false,
                                              validate: true,
                                              textInputType: TextInputType.text)
                                        ],
                                      ),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: closeTextFormFieldStyle(() {
                                    setState(() {
                                      double = false;
                                    });
                                  }),
                                ),
                              ],
                            )),
                        Visibility(
                            visible: !suite,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ignore: prefer_const_constructors
                                  Text(
                                    getTranslated(context, "Swite"),
                                    // ignore: prefer_const_constructors
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    value: suite,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        suite = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                        Visibility(
                            visible: suite,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const ReusedProviderEstateContainer(
                                              hint: 'Swite'),
                                          TextFormFieldStyle(
                                              context: context,
                                              hint: "Swite1",
                                              // ignore: prefer_const_constructors
                                              icon: Icon(
                                                Icons.single_bed,
                                                color: const Color(0xFF84A5FA),
                                              ),
                                              control: suiteHotelRoomController,
                                              isObsecured: false,
                                              validate: true,
                                              textInputType:
                                                  TextInputType.number),
                                          TextFormFieldStyle(
                                              context: context,
                                              hint: "Bio",
                                              // ignore: prefer_const_constructors
                                              icon: Icon(
                                                Icons.single_bed,
                                                color: const Color(0xFF84A5FA),
                                              ),
                                              control:
                                                  suiteHotelRoomControllerBioAr,
                                              isObsecured: false,
                                              validate: true,
                                              textInputType:
                                                  TextInputType.text),
                                          TextFormFieldStyle(
                                              context: context,
                                              hint: "BioEn",
                                              // ignore: prefer_const_constructors
                                              icon: Icon(
                                                Icons.single_bed,
                                                color: const Color(0xFF84A5FA),
                                              ),
                                              control:
                                                  suiteHotelRoomControllerBioEn,
                                              isObsecured: false,
                                              validate: true,
                                              textInputType: TextInputType.text)
                                        ],
                                      ),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: closeTextFormFieldStyle(() {
                                      setState(() {
                                        suite = false;
                                      });
                                    }))
                              ],
                            )),
                        Visibility(
                            visible: !family,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ignore: prefer_const_constructors
                                  Text(
                                    getTranslated(context, "Family"),
                                    // ignore: prefer_const_constructors
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    value: family,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        family = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                        Visibility(
                          visible: family,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ReusedProviderEstateContainer(
                                            hint: 'Family'),
                                        TextFormFieldStyle(
                                            context: context,
                                            hint: "Family1",
                                            // ignore: prefer_const_constructors
                                            icon: Icon(
                                              Icons.single_bed,
                                              color: const Color(0xFF84A5FA),
                                            ),
                                            control: familyHotelRoomController,
                                            isObsecured: false,
                                            validate: true,
                                            textInputType:
                                                TextInputType.number),
                                        TextFormFieldStyle(
                                            context: context,
                                            hint: "Bio",
                                            // ignore: prefer_const_constructors
                                            icon: Icon(
                                              Icons.single_bed,
                                              color: const Color(0xFF84A5FA),
                                            ),
                                            control:
                                                familyHotelRoomControllerBioAr,
                                            isObsecured: false,
                                            validate: true,
                                            textInputType: TextInputType.text),
                                        TextFormFieldStyle(
                                            context: context,
                                            hint: "BioEn",
                                            // ignore: prefer_const_constructors
                                            icon: Icon(
                                              Icons.single_bed,
                                              color: const Color(0xFF84A5FA),
                                            ),
                                            control:
                                                familyHotelRoomControllerBioEn,
                                            isObsecured: false,
                                            validate: true,
                                            textInputType: TextInputType.text)
                                      ],
                                    ),
                                  )),
                              Expanded(
                                child: closeTextFormFieldStyle(() {
                                  setState(() {
                                    family = false;
                                  });
                                }),
                              ),
                            ],
                          ),
                        ),
                        40.kH,
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      child: Container(
                        width: 150.w,
                        height: 6.h,
                        margin: const EdgeInsets.only(
                            right: 40, left: 40, bottom: 20),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // ignore: prefer_const_constructors
                        child: Center(
                          child: btnLogin,
                        ),
                      ),
                      onTap: () async {
                        String childType = '';
                        String ID;
                        setState(() {
                          btnLogin = const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        });
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        if (widget.userType == "1") {
                          childType = "Hottel";
                        } else if (widget.userType == "2") {
                          childType = "Coffee";
                        } else {
                          childType = "Restaurant";
                        }
                        String music = "0";
                        if (checkMusic) {
                          music = "1";
                        }
                        String? TypeAccount = await getTypeAccount() ?? "2";

                        await ref
                            .child(childType)
                            .child(idEstate.toString())
                            .set({
                          "NameAr": arNameController.text,
                          "NameEn": enNameController.text,
                          "BioAr": arBioController.text,
                          "BioEn": enBioController.text,
                          "Country": countryValue,
                          "City": cityValue,
                          "State": stateValue,
                          "Type": widget.userType,
                          "IDUser": sharedPreferences.getString("ID")!,
                          // "IDEstate": idEstate,
                          "TypeAccount": TypeAccount,
                          "FacilityNumber": facilityNumberController.text,
                          "TaxNumer": taxNumberController.text,
                          "Music": music,
                          "TypeofRestaurant": listTypeOfRestaurant.join(","),
                          "Sessions": listSessions.join(","),
                          "Lstmusic": listMusic.join(","),
                          "Entry": listEntry.join(","),
                          "Price": singleHotelRoomController.text.isNotEmpty
                              ? singleHotelRoomController.text
                              : "150",
                          "PriceLast": familyHotelRoomController.text.isNotEmpty
                              ? familyHotelRoomController.text
                              : "1500",
                        });
                        ID = idEstate.toString();
                        DatabaseReference refRooms =
                            FirebaseDatabase.instance.ref("App").child("Rooms");
                        if (single) {
                          await refRooms
                              .child(idEstate.toString())
                              .child("Single")
                              .set({
                            "ID": "1",
                            "Name": "Single",
                            "Price": singleHotelRoomController.text,
                            "BioAr": singleHotelRoomControllerBioAr.text,
                            "BioEn": singleHotelRoomControllerBioEn.text,
                          });
                        }
                        if (double) {
                          await refRooms
                              .child(idEstate.toString())
                              .child("Double")
                              .set({
                            "ID": "2",
                            "Name": "Double",
                            "Price": doubleHotelRoomController.text,
                            "BioAr": doubleHotelRoomControllerBioAr.text,
                            "BioEn": doubleHotelRoomControllerBioEn.text,
                          });
                        }
                        if (suite) {
                          await refRooms
                              .child(idEstate.toString())
                              .child("Swite")
                              .set({
                            "ID": "3",
                            "Name": "Swite",
                            "Price": suiteHotelRoomController.text,
                            "BioAr": suiteHotelRoomControllerBioAr.text,
                            "BioEn": suiteHotelRoomControllerBioEn.text,
                          });
                        }
                        if (family) {
                          await refRooms
                              .child(idEstate.toString())
                              .child("Family")
                              .set({
                            "ID": "4",
                            "Name": "Family",
                            "Price": familyHotelRoomController.text,
                            "BioAr": familyHotelRoomControllerBioAr.text,
                            "BioEn": familyHotelRoomControllerBioEn.text,
                          });
                        }
                        idEstate = (idEstate! + 1);
                        refID.update({"EstateID": idEstate});
                        // ignore: use_build_context_synchronously
                        Map e = Map();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapsScreen(
                              id: ID,
                              typeEstate: childType,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// import 'package:diamond_booking/chooseCity.dart';
// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/extension/sized_box_extension.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:csc_picker/csc_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
//
// import '../constants/reused_provider_estate_container.dart';
// import '../localization/language_constants.dart';
// import '../models/rooms.dart';
// import '../page/maps.dart';
// import '../widgets/text_form_style.dart';
// import 'maps_screen.dart';
//
// class AddEstatesScreen extends StatefulWidget {
//   String userType;
//   AddEstatesScreen({
//     super.key,
//     required this.userType,
//   });
//
//   @override
//   State<AddEstatesScreen> createState() => _AddEstatesScreenState();
// }
//
// class _AddEstatesScreenState extends State<AddEstatesScreen> {
//   final ImagePicker imagePicker = ImagePicker();
//   List<XFile>? imageFiles;
//   TextEditingController nameController = TextEditingController();
//   TextEditingController bioController = TextEditingController();
//   bool checkPopularRestaurants = false;
//   bool checkIndianRestaurant = false;
//   bool checkItalian = false;
//   bool checkSeafoodRestaurant = false;
//   bool checkFastFood = false;
//   bool checkSteak = false;
//   bool checkGrills = false;
//   bool checkHealthy = false;
//   bool checkMixed = false;
//   bool checkFamilial = false;
//   bool checkMusic = false;
//   bool checkSingle = false;
//   bool checkInternal = false;
//   bool checkExternal = false;
//   bool haveMusic = false;
//   bool haveSinger = false;
//   bool haveDJ = false;
//   bool haveOud = false;
//   DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("Estate");
//   DatabaseReference refID =
//       FirebaseDatabase.instance.ref("App").child("EstateID");
//   TextEditingController enNameController = TextEditingController();
//   TextEditingController enBioController = TextEditingController();
//   TextEditingController taxNumberController = TextEditingController();
//   TextEditingController estateNumberController = TextEditingController();
//   TextEditingController singleController = TextEditingController();
//   TextEditingController doubleController = TextEditingController();
//   TextEditingController suiteController = TextEditingController();
//   TextEditingController familyController = TextEditingController();
//   TextEditingController singleControllerBioAr = TextEditingController();
//   TextEditingController doubleControllerBioAr = TextEditingController();
//   TextEditingController suiteControllerBioAr = TextEditingController();
//   TextEditingController familyControllerBioAr = TextEditingController();
//   TextEditingController singleControllerBioEn = TextEditingController();
//   TextEditingController doubleControllerBioEn = TextEditingController();
//   TextEditingController suiteControllerBioEn = TextEditingController();
//   TextEditingController familyControllerBioEn = TextEditingController();
//   List<String> listTypeOfRestaurant = [];
//   List<String> listEntry = [];
//   List<String> listSessions = [];
//   List<String> listMusic = [];
//   List<Rooms> listRooms = [];
//   bool single = false;
//   bool double = false;
//   bool suite = false;
//   bool family = false;
//   late String? countryValue;
//   late String? stateValue;
//   late String? cityValue;
//   int? idEstate;
//   late Widget btnLogin;
//   void initState() {
//     DatabaseReference starCountRef =
//         FirebaseDatabase.instance.ref("App").child("EstateID");
//     starCountRef.onValue.listen((DatabaseEvent event) {
//       final data = event.snapshot.value as Map;
//       idEstate = data['EstateID'] ?? 1;
//     });
//     super.initState();
//   }
//
//   closeTextFormFieldStyle(Function() fun) {
//     // ignore: sort_child_properties_last
//     return InkWell(
//       // ignore: sort_child_properties_last
//       child: Container(
//
//           // ignore: prefer_const_constructors
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             // ignore: prefer_const_literals_to_create_immutables
//             boxShadow: [
//               // ignore: prefer_const_constructors
//               BoxShadow(blurRadius: 10, color: Colors.grey, spreadRadius: 1)
//             ],
//           ),
//           // ignore: prefer_const_constructors
//           child: CircleAvatar(
//             backgroundColor: Colors.white,
//             child: const Icon(
//               Icons.close,
//               color: Colors.red,
//             ),
//           )),
//       onTap: fun,
//     );
//   }
//
//   openImages() async {
//     try {
//       var pickedFiles = await imagePicker.pickMultiImage();
//       //you can use ImageCourse.camera for Camera capture
//       if (pickedFiles != null) {
//         imageFiles = pickedFiles;
//         print(imageFiles?.length.toString());
//         setState(() {});
//       } else {
//         print("No image is selected.");
//       }
//     } catch (e) {
//       print("error while picking file.");
//     }
//   }
//
//   Future<String?> getTypeAccount() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     String userId = sharedPreferences.getString("ID")!;
//     DatabaseReference ref = FirebaseDatabase.instance
//         .ref("App")
//         .child("Users")
//         .child(userId)
//         .child("TypeUser");
//     DataSnapshot snapshot = await ref.get();
//     return snapshot.value as String?;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     btnLogin = Text(
//       getTranslated(context, "Next"),
//     );
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kPrimaryColor,
//       ),
//       body: Stack(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(bottom: 20),
//             child: SafeArea(
//               child: ListView(
//                 children: [
//                   25.kH,
//                   const ReusedProviderEstateContainer(
//                     hint: "Information in Arabic",
//                   ),
//                   TextFormFieldStyle(
//                     context: context,
//                     hint: "Name",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.person,
//                       color: kPrimaryColor,
//                     ),
//                     control: nameController,
//                     isObsecured: false,
//                     validate: true,
//                     textInputType: TextInputType.text,
//                   ),
//                   TextFormFieldStyle(
//                     context: context,
//                     hint: "Bio",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.person,
//                       color: kPrimaryColor,
//                     ),
//                     control: bioController,
//                     isObsecured: false,
//                     validate: true,
//                     textInputType: TextInputType.text,
//                   ),
//                   40.kH,
//                   const ReusedProviderEstateContainer(
//                     hint: "Information in English",
//                   ),
//                   TextFormFieldStyle(
//                     context: context,
//                     hint: "Name",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.person,
//                       color: kPrimaryColor,
//                     ),
//                     control: enNameController,
//                     isObsecured: false,
//                     validate: true,
//                     textInputType: TextInputType.text,
//                   ),
//                   TextFormFieldStyle(
//                     context: context,
//                     hint: "Bio",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.person,
//                       color: kPrimaryColor,
//                     ),
//                     control: enBioController,
//                     isObsecured: false,
//                     validate: true,
//                     textInputType: TextInputType.text,
//                   ),
//                   40.kH,
//                   const ReusedProviderEstateContainer(
//                     hint: "Legal information",
//                   ),
//                   TextFormFieldStyle(
//                     context: context,
//                     hint: "No. facility",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.person,
//                       color: kPrimaryColor,
//                     ),
//                     control: estateNumberController,
//                     isObsecured: false,
//                     validate: true,
//                     textInputType: TextInputType.text,
//                   ),
//                   TextFormFieldStyle(
//                     context: context,
//                     hint: "Tax Number",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.person,
//                       color: kPrimaryColor,
//                     ),
//                     control: taxNumberController,
//                     isObsecured: false,
//                     validate: true,
//                     textInputType: TextInputType.text,
//                   ),
//                   40.kH,
//
//                   40.kH,
//                   Visibility(
//                     visible: widget.userType == "3" ? true : false,
//                     child: const ReusedProviderEstateContainer(
//                       hint: "Type of Restaurant",
//                     ),
//                   ),
//                   Visibility(
//                     // type of Restaurant
//                     visible: widget.userType == "3" ? true : false,
//                     child: Container(
//                       margin: const EdgeInsets.only(left: 20, right: 20),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   getTranslated(context, "popular restaurant"),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkPopularRestaurants,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkPopularRestaurants = value!;
//                                       if (checkPopularRestaurants) {
//                                         listTypeOfRestaurant
//                                             .add("popular restaurant");
//                                       } else {
//                                         listTypeOfRestaurant
//                                             .remove("popular restaurant");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child: Text(getTranslated(
//                                       context, "Indian Restaurant"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkIndianRestaurant,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkIndianRestaurant = value!;
//                                       if (checkIndianRestaurant) {
//                                         listTypeOfRestaurant
//                                             .add("Indian Restaurant");
//                                       } else {
//                                         listTypeOfRestaurant
//                                             .remove("Indian Restaurant");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child:
//                                       Text(getTranslated(context, "Italian"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkItalian,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkItalian = value!;
//                                       if (checkItalian) {
//                                         listTypeOfRestaurant.add("Italian");
//                                       } else {
//                                         listTypeOfRestaurant.remove("Italian");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child: Text(getTranslated(
//                                       context, "Seafood Restaurant"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkSeafoodRestaurant,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkSeafoodRestaurant = value!;
//                                       if (checkSeafoodRestaurant) {
//                                         listTypeOfRestaurant
//                                             .add("Seafood Restaurant");
//                                       } else {
//                                         listTypeOfRestaurant
//                                             .remove("Seafood Restaurant");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child: Text(
//                                       getTranslated(context, "Fast Food"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkFastFood,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkFastFood = value!;
//                                       if (checkFastFood) {
//                                         listTypeOfRestaurant.add("Fast Food");
//                                       } else {
//                                         listTypeOfRestaurant
//                                             .remove("Fast Food");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child: Text(getTranslated(context, "Steak"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkSteak,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkSteak = value!;
//                                       if (checkSteak) {
//                                         listTypeOfRestaurant.add("Steak");
//                                       } else {
//                                         listTypeOfRestaurant.remove("Steak");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child:
//                                       Text(getTranslated(context, "Grills"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkGrills,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkGrills = value!;
//                                       if (checkGrills) {
//                                         listTypeOfRestaurant.add("Grills");
//                                       } else {
//                                         listTypeOfRestaurant.remove("Grills");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                   child:
//                                       Text(getTranslated(context, "healthy"))),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkHealthy,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkHealthy = value!;
//                                       if (checkHealthy) {
//                                         listTypeOfRestaurant.add("healthy");
//                                       } else {
//                                         listTypeOfRestaurant.remove("healthy");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   15.kH,
//                   Visibility(
//                     visible: widget.userType == "3" || widget.userType == "2"
//                         ? true
//                         : false,
//                     child: const ReusedProviderEstateContainer(
//                       hint: "Entry allowed",
//                     ),
//                   ),
//                   Visibility(
//                       visible: widget.userType == "3" || widget.userType == "2"
//                           ? true
//                           : false,
//                       child: Container(
//                         margin: const EdgeInsets.only(left: 20, right: 20),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     getTranslated(context, "Familial"),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: checkFamilial,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         checkFamilial = value!;
//                                         if (checkFamilial) {
//                                           listEntry.add("Familial");
//                                         } else {
//                                           listEntry.remove("Familial");
//                                         }
//                                         //  print(LstTypeofRestaurant.join("-"));
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child: Text(
//                                         getTranslated(context, "Single2"))),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: checkSingle,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         checkSingle = value!;
//                                         if (checkSingle) {
//                                           listEntry.add("Single");
//                                         } else {
//                                           listEntry.remove("Single");
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child:
//                                         Text(getTranslated(context, "mixed"))),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: checkMixed,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         checkMixed = value!;
//                                         if (checkMixed) {
//                                           listEntry.add("mixed");
//                                         } else {
//                                           listEntry.remove("mixed");
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       )),
//                   Visibility(
//                     visible: widget.userType == "3" || widget.userType == "2"
//                         ? true
//                         : false,
//                     child: const ReusedProviderEstateContainer(
//                       hint: 'Sessions type',
//                     ),
//                   ),
//                   Visibility(
//                     visible: widget.userType == "3" || widget.userType == "2"
//                         ? true
//                         : false,
//                     child: Container(
//                       margin: const EdgeInsets.only(left: 20, right: 20),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   getTranslated(context, "internal sessions"),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkInternal,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkInternal = value!;
//                                       if (checkInternal) {
//                                         listSessions.add("internal sessions");
//                                       } else {
//                                         listEntry.remove("internal sessions");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   getTranslated(context, "External sessions"),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Checkbox(
//                                   checkColor: Colors.white,
//                                   value: checkExternal,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       checkExternal = value!;
//                                       if (checkExternal) {
//                                         listSessions.add("External sessions");
//                                       } else {
//                                         listEntry.remove("External sessions");
//                                       }
//                                     });
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   40.kH,
//                   // const Divider(),
//                   Visibility(
//                       visible: widget.userType == "3" || widget.userType == "2"
//                           ? true
//                           : false,
//                       child: Container(
//                         margin: const EdgeInsets.only(left: 20, right: 20),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child: Text(getTranslated(
//                                         context, "Is there music"))),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: checkMusic,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         checkMusic = value!;
//                                         if (checkMusic &&
//                                             widget.userType == "2") {
//                                           haveMusic = true;
//                                         } else {
//                                           haveMusic = false;
//                                           haveSinger = false;
//                                           haveDJ = false;
//                                           haveOud = false;
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       )),
//                   Visibility(
//                       visible:
//                           haveMusic && widget.userType == "2" ? true : false,
//                       child: Container(
//                         margin: const EdgeInsets.only(left: 20, right: 20),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child:
//                                         Text(getTranslated(context, "singer"))),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: haveSinger,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         haveSinger = value!;
//                                         if (haveSinger) {
//                                           listMusic.add("singer");
//                                         } else {
//                                           listEntry.remove("singer");
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child: Text(getTranslated(context, "DJ"))),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: haveDJ,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         haveDJ = value!;
//                                         if (haveDJ) {
//                                           listMusic.add("DJ");
//                                         } else {
//                                           listEntry.remove("DJ");
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child: Text(getTranslated(context, "Oud"))),
//                                 Expanded(
//                                   child: Checkbox(
//                                     checkColor: Colors.white,
//                                     value: haveOud,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         haveOud = value!;
//                                         if (haveOud) {
//                                           listMusic.add("Oud");
//                                         } else {
//                                           listEntry.remove("Oud");
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       )),
//                   40.kH,
//                   const ReusedProviderEstateContainer(
//                     hint: "Location information",
//                   ),
//                   20.kH,
//                   CustomCSCPicker(
//                     onCountryChanged: (value) {
//                       setState(() {
//                         countryValue = value;
//                       });
//                     },
//                     onStateChanged: (value) {
//                       setState(() {
//                         stateValue = value;
//                       });
//                     },
//                     onCityChanged: (value) {
//                       setState(() {
//                         cityValue = value;
//                       });
//                     },
//                   ),
//                   40.kH,
//                   Visibility(
//                     visible: widget.userType == "1" ? true : false,
//                     child: const ReusedProviderEstateContainer(
//                         hint: "What We have ?"),
//                   ),
//                   Visibility(
//                     visible: widget.userType == "1" ? true : false,
//                     child: Column(
//                       children: [
//                         Visibility(
//                             visible: !single,
//                             child: Container(
//                               margin:
//                                   const EdgeInsets.only(left: 20, right: 20),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   // ignore: prefer_const_constructors
//                                   Text(
//                                     getTranslated(context, "Single"),
//                                     // ignore: prefer_const_constructors
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.black),
//                                   ),
//                                   Checkbox(
//                                     checkColor: Colors.white,
//                                     value: single,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         single = value!;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             )),
//                         // ignore: sort_child_properties_last
//                         Visibility(
//                           // ignore: sort_child_properties_last
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 flex: 3,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 20),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const ReusedProviderEstateContainer(
//                                           hint: "Single"),
//                                       TextFormFieldStyle(
//                                           context: context,
//                                           hint: "Single1",
//                                           // ignore: prefer_const_constructors
//                                           icon: Icon(
//                                             Icons.single_bed,
//                                             color: const Color(0xFF84A5FA),
//                                           ),
//                                           control: singleController,
//                                           isObsecured: false,
//                                           validate: true,
//                                           textInputType: TextInputType.number),
//                                       TextFormFieldStyle(
//                                           context: context,
//                                           hint: "Bio",
//                                           // ignore: prefer_const_constructors
//                                           icon: Icon(
//                                             Icons.single_bed,
//                                             color: const Color(0xFF84A5FA),
//                                           ),
//                                           control: singleControllerBioAr,
//                                           isObsecured: false,
//                                           validate: true,
//                                           textInputType: TextInputType.text),
//                                       TextFormFieldStyle(
//                                           context: context,
//                                           hint: "BioEn",
//                                           // ignore: prefer_const_constructors
//                                           icon: Icon(
//                                             Icons.single_bed,
//                                             color: const Color(0xFF84A5FA),
//                                           ),
//                                           control: singleControllerBioEn,
//                                           isObsecured: false,
//                                           validate: true,
//                                           textInputType: TextInputType.text)
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Expanded(child: closeTextFormFieldStyle(
//                                 () {
//                                   setState(() {
//                                     single = false;
//                                   });
//                                 },
//                               ))
//                             ],
//                           ),
//                           visible: single,
//                         ),
//                         Visibility(
//                             visible: !double,
//                             child: Container(
//                               margin:
//                                   const EdgeInsets.only(left: 20, right: 20),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   // ignore: prefer_const_constructors
//                                   Text(
//                                     getTranslated(context, "Double"),
//                                     // ignore: prefer_const_constructors
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.black),
//                                   ),
//                                   Checkbox(
//                                     checkColor: Colors.white,
//                                     value: double,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         double = value!;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             )),
//                         Visibility(
//                             visible: double,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                     flex: 3,
//                                     child: Container(
//                                       margin: const EdgeInsets.only(left: 20),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const ReusedProviderEstateContainer(
//                                             hint: 'Double',
//                                           ),
//                                           TextFormFieldStyle(
//                                               context: context,
//                                               hint: "Double1",
//                                               // ignore: prefer_const_constructors
//                                               icon: Icon(
//                                                 Icons.single_bed,
//                                                 color: const Color(0xFF84A5FA),
//                                               ),
//                                               control: doubleController,
//                                               isObsecured: false,
//                                               validate: true,
//                                               textInputType:
//                                                   TextInputType.number),
//                                           TextFormFieldStyle(
//                                               context: context,
//                                               hint: "Bio",
//                                               // ignore: prefer_const_constructors
//                                               icon: Icon(
//                                                 Icons.single_bed,
//                                                 color: const Color(0xFF84A5FA),
//                                               ),
//                                               control: doubleControllerBioAr,
//                                               isObsecured: false,
//                                               validate: true,
//                                               textInputType:
//                                                   TextInputType.text),
//                                           TextFormFieldStyle(
//                                               context: context,
//                                               hint: "BioEn",
//                                               // ignore: prefer_const_constructors
//                                               icon: Icon(
//                                                 Icons.single_bed,
//                                                 color: const Color(0xFF84A5FA),
//                                               ),
//                                               control: doubleControllerBioEn,
//                                               isObsecured: false,
//                                               validate: true,
//                                               textInputType: TextInputType.text)
//                                         ],
//                                       ),
//                                     )),
//                                 Expanded(
//                                   flex: 1,
//                                   child: closeTextFormFieldStyle(() {
//                                     setState(() {
//                                       double = false;
//                                     });
//                                   }),
//                                 ),
//                               ],
//                             )),
//                         Visibility(
//                             visible: !suite,
//                             child: Container(
//                               margin:
//                                   const EdgeInsets.only(left: 20, right: 20),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   // ignore: prefer_const_constructors
//                                   Text(
//                                     getTranslated(context, "Swite"),
//                                     // ignore: prefer_const_constructors
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.black),
//                                   ),
//                                   Checkbox(
//                                     checkColor: Colors.white,
//                                     value: suite,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         suite = value!;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             )),
//                         Visibility(
//                             visible: suite,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                     flex: 3,
//                                     child: Container(
//                                       margin: const EdgeInsets.only(left: 20),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const ReusedProviderEstateContainer(
//                                               hint: 'Swite'),
//                                           TextFormFieldStyle(
//                                               context: context,
//                                               hint: "Swite1",
//                                               // ignore: prefer_const_constructors
//                                               icon: Icon(
//                                                 Icons.single_bed,
//                                                 color: const Color(0xFF84A5FA),
//                                               ),
//                                               control: suiteController,
//                                               isObsecured: false,
//                                               validate: true,
//                                               textInputType:
//                                                   TextInputType.number),
//                                           TextFormFieldStyle(
//                                               context: context,
//                                               hint: "Bio",
//                                               // ignore: prefer_const_constructors
//                                               icon: Icon(
//                                                 Icons.single_bed,
//                                                 color: const Color(0xFF84A5FA),
//                                               ),
//                                               control: suiteControllerBioAr,
//                                               isObsecured: false,
//                                               validate: true,
//                                               textInputType:
//                                                   TextInputType.text),
//                                           TextFormFieldStyle(
//                                               context: context,
//                                               hint: "BioEn",
//                                               // ignore: prefer_const_constructors
//                                               icon: Icon(
//                                                 Icons.single_bed,
//                                                 color: const Color(0xFF84A5FA),
//                                               ),
//                                               control: suiteControllerBioEn,
//                                               isObsecured: false,
//                                               validate: true,
//                                               textInputType: TextInputType.text)
//                                         ],
//                                       ),
//                                     )),
//                                 Expanded(
//                                     flex: 1,
//                                     child: closeTextFormFieldStyle(() {
//                                       setState(() {
//                                         suite = false;
//                                       });
//                                     }))
//                               ],
//                             )),
//                         Visibility(
//                             visible: !family,
//                             child: Container(
//                               margin:
//                                   const EdgeInsets.only(left: 20, right: 20),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   // ignore: prefer_const_constructors
//                                   Text(
//                                     getTranslated(context, "Family"),
//                                     // ignore: prefer_const_constructors
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.black),
//                                   ),
//                                   Checkbox(
//                                     checkColor: Colors.white,
//                                     value: family,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         family = value!;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             )),
//                         Visibility(
//                           visible: family,
//                           child: Row(
//                             children: [
//                               Expanded(
//                                   flex: 3,
//                                   child: Container(
//                                     margin: const EdgeInsets.only(left: 20),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const ReusedProviderEstateContainer(
//                                             hint: 'Family'),
//                                         TextFormFieldStyle(
//                                             context: context,
//                                             hint: "Family1",
//                                             // ignore: prefer_const_constructors
//                                             icon: Icon(
//                                               Icons.single_bed,
//                                               color: const Color(0xFF84A5FA),
//                                             ),
//                                             control: familyController,
//                                             isObsecured: false,
//                                             validate: true,
//                                             textInputType:
//                                                 TextInputType.number),
//                                         TextFormFieldStyle(
//                                             context: context,
//                                             hint: "Bio",
//                                             // ignore: prefer_const_constructors
//                                             icon: Icon(
//                                               Icons.single_bed,
//                                               color: const Color(0xFF84A5FA),
//                                             ),
//                                             control: familyControllerBioAr,
//                                             isObsecured: false,
//                                             validate: true,
//                                             textInputType: TextInputType.text),
//                                         TextFormFieldStyle(
//                                             context: context,
//                                             hint: "BioEn",
//                                             // ignore: prefer_const_constructors
//                                             icon: Icon(
//                                               Icons.single_bed,
//                                               color: const Color(0xFF84A5FA),
//                                             ),
//                                             control: familyControllerBioEn,
//                                             isObsecured: false,
//                                             validate: true,
//                                             textInputType: TextInputType.text)
//                                       ],
//                                     ),
//                                   )),
//                               Expanded(
//                                 child: closeTextFormFieldStyle(() {
//                                   setState(() {
//                                     family = false;
//                                   });
//                                 }),
//                               ),
//                             ],
//                           ),
//                         ),
//                         40.kH,
//                       ],
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: InkWell(
//                       child: Container(
//                         width: 150.w,
//                         height: 6.h,
//                         margin: const EdgeInsets.only(
//                             right: 40, left: 40, bottom: 20),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF84A5FA),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         // ignore: prefer_const_constructors
//                         child: Center(
//                           child: btnLogin,
//                         ),
//                       ),
//                       onTap: () async {
//                         String childType = '';
//                         String ID;
//                         setState(() {
//                           btnLogin = const CircularProgressIndicator(
//                             color: Colors.white,
//                           );
//                         });
//                         SharedPreferences sharedPreferences =
//                             await SharedPreferences.getInstance();
//                         if (widget.userType == "1") {
//                           childType = "Hottel";
//                         } else if (widget.userType == "2") {
//                           childType = "Coffee";
//                         } else {
//                           childType = "Restaurant";
//                         }
//                         String music = "0";
//                         if (checkMusic) {
//                           music = "1";
//                         }
//                         String? TypeAccount = await getTypeAccount() ?? "2";
//
//                         await ref
//                             .child(childType)
//                             .child(idEstate.toString())
//                             .set({
//                           "NameAr": nameController.text,
//                           "NameEn": enNameController.text,
//                           "BioAr": bioController.text,
//                           "BioEn": enBioController.text,
//                           "Country": countryValue,
//                           "City": cityValue,
//                           "State": stateValue,
//                           "Type": widget.userType,
//                           "IDUser": sharedPreferences.getString("ID")!,
//                           "IDEstate": idEstate,
//                           "TypeAccount": TypeAccount,
//                           "EstateNumber": estateNumberController.text,
//                           "TaxNumer": taxNumberController.text,
//                           "Music": music,
//                           "TypeofRestaurant": listTypeOfRestaurant.join(","),
//                           "Sessions": listSessions.join(","),
//                           "Lstmusic": listMusic.join(","),
//                           "Entry": listEntry.join(","),
//                           "Price": singleController.text.isNotEmpty
//                               ? singleController.text
//                               : "150",
//                           "PriceLast": familyController.text.isNotEmpty
//                               ? familyController.text
//                               : "1500",
//                         });
//                         ID = idEstate.toString();
//                         DatabaseReference refRooms =
//                             FirebaseDatabase.instance.ref("App").child("Rooms");
//                         if (single) {
//                           await refRooms
//                               .child(idEstate.toString())
//                               .child("Single")
//                               .set({
//                             "ID": "1",
//                             "Name": "Single",
//                             "Price": singleController.text,
//                             "BioAr": singleControllerBioAr.text,
//                             "BioEn": singleControllerBioEn.text,
//                           });
//                         }
//                         if (double) {
//                           await refRooms
//                               .child(idEstate.toString())
//                               .child("Double")
//                               .set({
//                             "ID": "2",
//                             "Name": "Double",
//                             "Price": doubleController.text,
//                             "BioAr": doubleControllerBioAr.text,
//                             "BioEn": doubleControllerBioEn.text,
//                           });
//                         }
//                         if (suite) {
//                           await refRooms
//                               .child(idEstate.toString())
//                               .child("Swite")
//                               .set({
//                             "ID": "3",
//                             "Name": "Swite",
//                             "Price": suiteController.text,
//                             "BioAr": suiteControllerBioAr.text,
//                             "BioEn": suiteControllerBioEn.text,
//                           });
//                         }
//                         if (family) {
//                           await refRooms
//                               .child(idEstate.toString())
//                               .child("Family")
//                               .set({
//                             "ID": "4",
//                             "Name": "Family",
//                             "Price": familyController.text,
//                             "BioAr": familyControllerBioAr.text,
//                             "BioEn": familyControllerBioEn.text,
//                           });
//                         }
//                         idEstate = (idEstate! + 1);
//                         refID.update({"EstateID": idEstate});
//                         // ignore: use_build_context_synchronously
//                         Map e = Map();
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => MapsScreen(
//                               id: ID,
//                               typeEstate: childType,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
