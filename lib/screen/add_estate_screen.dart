import 'package:diamond_booking/chooseCity.dart';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../constants/reused_provider_estate_container.dart';
import '../localization/language_constants.dart';
import '../models/rooms.dart';
import '../page/maps.dart';
import '../widgets/entry_visibility.dart';
import '../widgets/music_visibility.dart';
import '../widgets/restaurant_type_visibility.dart';
import '../widgets/room_type_visibility.dart';
import '../widgets/sessions_visibility.dart';
import '../widgets/text_form_style.dart';
import 'maps_screen.dart';
import '../resources/estate_services.dart'; // Import the new backend service

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
  final BackendService backendService = BackendService();
  List<XFile>? imageFiles;
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController menuLinkController = TextEditingController();
  bool checkPopularRestaurants = false;
  bool checkIndianRestaurant = false;
  bool checkItalian = false;
  bool checkSeafoodRestaurant = false;
  bool checkFastFood = false;
  bool checkSteak = false;
  bool checkGrills = false;
  bool checkHealthy = false;
  bool checkMixed = false;
  bool checkFamilial = false;
  bool checkMusic = false;
  bool checkSingle = false;
  bool checkInternal = false;
  bool checkExternal = false;
  bool haveMusic = false;
  bool haveSinger = false;
  bool haveDJ = false;
  bool haveOud = false;
  TextEditingController enNameController = TextEditingController();
  TextEditingController enBioController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController estateNumberController = TextEditingController();
  TextEditingController singleController = TextEditingController();
  TextEditingController doubleController = TextEditingController();
  TextEditingController suiteController = TextEditingController();
  TextEditingController familyController = TextEditingController();
  TextEditingController singleControllerBioAr = TextEditingController();
  TextEditingController doubleControllerBioAr = TextEditingController();
  TextEditingController suiteControllerBioAr = TextEditingController();
  TextEditingController familyControllerBioAr = TextEditingController();
  TextEditingController singleControllerBioEn = TextEditingController();
  TextEditingController doubleControllerBioEn = TextEditingController();
  TextEditingController suiteControllerBioEn = TextEditingController();
  TextEditingController familyControllerBioEn = TextEditingController();
  List<String> listTypeOfRestaurant = [];
  List<String> listEntry = [];
  List<String> listSessions = [];
  List<String> listMusic = [];
  List<Rooms> listRooms = [];
  bool single = false;
  bool double = false;
  bool suite = false;
  bool family = false;
  late String? countryValue;
  late String? stateValue;
  late String? cityValue;
  int? idEstate;
  late Widget btnLogin;

  @override
  void initState() {
    super.initState();
    backendService.getIdEstate().then((id) {
      setState(() {
        idEstate = id;
      });
    });
  }

  Future<String?> getTypeAccount(String userId) async {
    return await backendService.getTypeAccount(userId);
  }

  @override
  Widget build(BuildContext context) {
    btnLogin = Text(
      getTranslated(context, "Next"),
      style: const TextStyle(color: Colors.white),
    );
    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
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
                    icon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    control: nameController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Bio",
                    icon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    control: bioController,
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
                    icon: Icon(
                      Icons.person,
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
                    icon: Icon(
                      Icons.person,
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
                    icon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    control: estateNumberController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Tax Number",
                    icon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    control: taxNumberController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.text,
                  ),
                  40.kH,
                  const ReusedProviderEstateContainer(
                    hint: "Menu",
                  ),
                  TextFormFieldStyle(
                    context: context,
                    hint: "Enter Menu Link",
                    icon: Icon(
                      Icons.link,
                      color: kPrimaryColor,
                    ),
                    control: menuLinkController,
                    isObsecured: false,
                    validate: true,
                    textInputType: TextInputType.url,
                  ),
                  80.kH,
                  Visibility(
                    visible: widget.userType == "3" ? true : false,
                    child: const ReusedProviderEstateContainer(
                      hint: "Type of Restaurant",
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 50,
                    ),
                    child: RestaurantTypeVisibility(
                      isVisible: widget.userType == "3",
                      onCheckboxChanged: (value, type) {
                        setState(() {
                          if (value) {
                            listTypeOfRestaurant.add(type);
                          } else {
                            listTypeOfRestaurant.remove(type);
                          }
                        });
                      },
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
                  Container(
                    margin: const EdgeInsets.only(
                      left: 50,
                    ),
                    child: EntryVisibility(
                      isVisible:
                          widget.userType == "3" || widget.userType == "2",
                      onCheckboxChanged: (value, type) {
                        setState(() {
                          if (value) {
                            listEntry.add(type);
                          } else {
                            listEntry.remove(type);
                          }
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: widget.userType == "3" || widget.userType == "2"
                        ? true
                        : false,
                    child: const ReusedProviderEstateContainer(
                      hint: 'Sessions type',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 50,
                    ),
                    child: SessionsVisibility(
                      isVisible:
                          widget.userType == "3" || widget.userType == "2",
                      onCheckboxChanged: (value, type) {
                        setState(() {
                          if (value) {
                            listSessions.add(type);
                          } else {
                            listSessions.remove(type);
                          }
                        });
                      },
                    ),
                  ),
                  40.kH,
                  Container(
                    margin: const EdgeInsets.only(
                      left: 50,
                    ),
                    child: MusicVisibility(
                      isVisible:
                          widget.userType == "3" || widget.userType == "2",
                      checkMusic: checkMusic,
                      haveMusic: haveMusic,
                      haveSinger: haveSinger,
                      haveDJ: haveDJ,
                      haveOud: haveOud,
                      onMusicChanged: (value) {
                        setState(() {
                          checkMusic = value;
                          if (!checkMusic) {
                            haveMusic = false;
                            haveSinger = false;
                            haveDJ = false;
                            haveOud = false;
                          } else if (widget.userType == "2") {
                            haveMusic = true;
                          }
                        });
                      },
                      onSingerChanged: (value) {
                        setState(() {
                          haveSinger = value;
                          if (value) {
                            listMusic.add("singer");
                          } else {
                            listMusic.remove("singer");
                          }
                        });
                      },
                      onDJChanged: (value) {
                        setState(() {
                          haveDJ = value;
                          if (value) {
                            listMusic.add("DJ");
                          } else {
                            listMusic.remove("DJ");
                          }
                        });
                      },
                      onOudChanged: (value) {
                        setState(() {
                          haveOud = value;
                          if (value) {
                            listMusic.add("Oud");
                          } else {
                            listMusic.remove("Oud");
                          }
                        });
                      },
                    ),
                  ),
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
                  RoomTypeVisibility(
                    userType: widget.userType,
                    single: single,
                    double: double,
                    suite: suite,
                    family: family,
                    singleHotelRoomController: singleController,
                    doubleHotelRoomController: doubleController,
                    suiteHotelRoomController: suiteController,
                    familyHotelRoomController: familyController,
                    singleHotelRoomControllerBioAr: singleControllerBioAr,
                    singleHotelRoomControllerBioEn: singleControllerBioEn,
                    doubleHotelRoomControllerBioEn: doubleControllerBioEn,
                    doubleHotelRoomControllerBioAr: doubleControllerBioAr,
                    suiteHotelRoomControllerBioEn: suiteControllerBioEn,
                    suiteHotelRoomControllerBioAr: suiteControllerBioAr,
                    familyHotelRoomControllerBioAr: familyControllerBioAr,
                    familyHotelRoomControllerBioEn: familyControllerBioEn,
                    onSingleChanged: (value) {
                      setState(() {
                        single = value;
                      });
                    },
                    onDoubleChanged: (value) {
                      setState(() {
                        double = value;
                      });
                    },
                    onSuiteChanged: (value) {
                      setState(() {
                        suite = value;
                      });
                    },
                    onFamilyChanged: (value) {
                      setState(() {
                        family = value;
                      });
                    },
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

                        // Fetch the currently authenticated user
                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          String userID = user.uid;
                          print("The userId is $userID");

                          // Fetch user details from Firebase Realtime Database
                          Map<String, String?> userDetails =
                              await backendService.getUserDetails(userID);

                          String? firstName = userDetails["firstName"];
                          String? lastName = userDetails["lastName"];
                          String? typeAccount = userDetails["typeAccount"];

                          if (firstName != null && lastName != null) {
                            // Add selected room types to the listEntry
                            if (single) listEntry.add("Single");
                            if (double) listEntry.add("Double");
                            if (suite) listEntry.add("Suite");
                            if (family) listEntry.add("Family");

                            await backendService.addEstate(
                              childType: childType,
                              idEstate: idEstate.toString(),
                              nameAr: nameController.text,
                              nameEn: enNameController.text,
                              bioAr: bioController.text,
                              bioEn: enBioController.text,
                              country: countryValue ?? "",
                              city: cityValue ?? "",
                              state: stateValue ?? "",
                              userType: widget.userType,
                              userID: userID,
                              typeAccount: typeAccount ?? "",
                              estateNumber: estateNumberController.text,
                              taxNumber: taxNumberController.text,
                              music: music,
                              listTypeOfRestaurant: listTypeOfRestaurant,
                              listSessions: listSessions,
                              listMusic: listMusic,
                              listEntry: listEntry,
                              price: singleController.text.isNotEmpty
                                  ? singleController.text
                                  : "150",
                              priceLast: familyController.text.isNotEmpty
                                  ? familyController.text
                                  : "1500",
                              ownerFirstName: firstName,
                              ownerLastName: lastName,
                              menuLink: menuLinkController.text,
                            );

                            ID = idEstate.toString();
                            if (single) {
                              await backendService.addRoom(
                                estateId: idEstate.toString(),
                                roomId: "1",
                                roomName: "Single",
                                roomPrice: singleController.text,
                                roomBioAr: singleControllerBioAr.text,
                                roomBioEn: singleControllerBioEn.text,
                              );
                            }
                            if (double) {
                              await backendService.addRoom(
                                estateId: idEstate.toString(),
                                roomId: "2",
                                roomName: "Double",
                                roomPrice: doubleController.text,
                                roomBioAr: doubleControllerBioAr.text,
                                roomBioEn: doubleControllerBioEn.text,
                              );
                            }
                            if (suite) {
                              await backendService.addRoom(
                                estateId: idEstate.toString(),
                                roomId: "3",
                                roomName: "Suite",
                                roomPrice: suiteController.text,
                                roomBioAr: suiteControllerBioAr.text,
                                roomBioEn: suiteControllerBioEn.text,
                              );
                            }
                            if (family) {
                              await backendService.addRoom(
                                estateId: idEstate.toString(),
                                roomId: "4",
                                roomName: "Family",
                                roomPrice: familyController.text,
                                roomBioAr: familyControllerBioAr.text,
                                roomBioEn: familyControllerBioEn.text,
                              );
                            }
                            idEstate = (idEstate! + 1);
                            await backendService.updateEstateId(idEstate!);

                            // ignore: use_build_context_synchronously
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapsScreen(
                                  id: ID,
                                  typeEstate: childType,
                                ),
                              ),
                            );
                          } else {
                            // Handle the case where userID is not found or empty
                            setState(() {
                              btnLogin = Text('Failed to get User details');
                            });
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
