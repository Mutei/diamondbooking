// ignore_for_file: non_constant_identifier_names
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../models/rooms.dart';
import '../widgets/text_form_style.dart';
import 'additionalfacility.dart';

class EditEstate extends StatefulWidget {
  Map objEstate;
  List<Rooms> LstRooms = [];

  EditEstate({required this.objEstate, required this.LstRooms});
  @override
  _State createState() => new _State(objEstate, LstRooms);
}

class _State extends State<EditEstate> {
  Map objEstate;
  List<Rooms> LstRooms = [];

  _State(this.objEstate, this.LstRooms);
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  TextEditingController Name_Controller = TextEditingController();
  TextEditingController Bio_Controller = TextEditingController();

  TextEditingController EnName_Controller = TextEditingController();
  TextEditingController EnBio_Controller = TextEditingController();

  TextEditingController Country_Controller = TextEditingController();
  TextEditingController City_Controller = TextEditingController();
  TextEditingController State_Controller = TextEditingController();

  TextEditingController Single_Controller = TextEditingController();
  TextEditingController Double_Controller = TextEditingController();
  TextEditingController Swite_Controller = TextEditingController();
  TextEditingController Famely_Controller = TextEditingController();

  TextEditingController Single_ControllerBioAr = TextEditingController();
  TextEditingController Double_ControllerBioAr = TextEditingController();
  TextEditingController Swite_ControllerBioAr = TextEditingController();
  TextEditingController Famely_ControllerBioAr = TextEditingController();
  TextEditingController Single_ControllerBioEn = TextEditingController();
  TextEditingController Double_ControllerBioEn = TextEditingController();
  TextEditingController Swite_ControllerBioEn = TextEditingController();
  TextEditingController Famely_ControllerBioEn = TextEditingController();

  TextEditingController Single_ControllerID = TextEditingController();
  TextEditingController Double_ControllerID = TextEditingController();
  TextEditingController Swite_ControllerID = TextEditingController();
  TextEditingController Famely_ControllerID = TextEditingController();
  bool Single = false;
  bool Double = false;
  bool Swite = false;
  bool Family = false;
  late String? countryValue;
  late String? stateValue;
  late String? cityValue;
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("Estate");

  @override
  void initState() {
    Name_Controller.text = objEstate["NameAr"];
    Bio_Controller.text = objEstate["BioAr"];
    EnName_Controller.text = objEstate["NameEn"];
    EnBio_Controller.text = objEstate["BioEn"];
    Country_Controller.text = objEstate["Country"];
    City_Controller.text = objEstate["City"];
    State_Controller.text = objEstate["State"];
    countryValue = objEstate["Country"];
    cityValue = objEstate["City"];
    stateValue = objEstate["State"];
    for (int i = 0; i < LstRooms.length; i++) {
      if (LstRooms[i].name == "Single") {
        Single = true;
        Single_Controller.text = LstRooms[i].price;
        Single_ControllerBioAr.text = LstRooms[i].bio;
        Single_ControllerBioEn.text = LstRooms[i].bioEn;
        Single_ControllerID.text = LstRooms[i].id;
      }
      if (LstRooms[i].name == "Double") {
        Double = true;
        Double_Controller.text = LstRooms[i].price;
        Double_ControllerBioAr.text = LstRooms[i].bio;
        Double_ControllerBioEn.text = LstRooms[i].bioEn;
        Double_ControllerID.text = LstRooms[i].id;
      }
      if (LstRooms[i].name == "Swite") {
        Swite = true;
        Swite_Controller.text = LstRooms[i].price;
        Swite_ControllerBioAr.text = LstRooms[i].bio;
        Swite_ControllerBioEn.text = LstRooms[i].bioEn;
        Swite_ControllerID.text = LstRooms[i].id;
      }
      if (LstRooms[i].name == "Family") {
        Family = true;
        Famely_Controller.text = LstRooms[i].price;
        Famely_ControllerBioAr.text = LstRooms[i].bio;
        Famely_ControllerBioEn.text = LstRooms[i].bioEn;
        Famely_ControllerID.text = LstRooms[i].id;
      }
    }
    super.initState();
  }

  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        print(imagefiles?.length.toString());
        setState(() {});
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          iconTheme: kIconTheme,
        ),
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                  child: ListView(
                children: [
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 25,
                  ),
                  TextHedar("Information in Arabic"),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: TextFormFieldStyle(
                        context: context,
                        hint: "Name",
                        // ignore: prefer_const_constructors
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        control: Name_Controller,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.emailAddress),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: TextFormFieldStyle(
                        context: context,
                        hint: "Bio",
                        // ignore: prefer_const_constructors
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        control: Bio_Controller,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.emailAddress),
                  ),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 40,
                  ),
                  TextHedar("Information in English"),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: TextFormFieldStyle(
                        context: context,
                        hint: "Name",
                        // ignore: prefer_const_constructors
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        control: EnName_Controller,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.emailAddress),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: TextFormFieldStyle(
                        context: context,
                        hint: "Bio",
                        // ignore: prefer_const_constructors
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        control: EnBio_Controller,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.emailAddress),
                  ),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 40,
                  ),
                  TextHedar("Location information"),
                  const SizedBox(
                    height: 20,
                  ),
                  ChoeseCity(),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 40,
                  ),

                  Visibility(
                      visible: objEstate['Type'] == "1" ? true : false,
                      child: Column(
                        children: [
                          TextHedar("What We have ?"),
                          Visibility(
                              visible: !Single,
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
                                      value: Single,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          Single = value!;
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextHedar("Single"),
                                        TextFormFieldStyle(
                                            context: context,
                                            hint: "Single1",
                                            // ignore: prefer_const_constructors
                                            icon: Icon(
                                              Icons.single_bed,
                                              color: kPrimaryColor,
                                            ),
                                            control: Single_Controller,
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
                                              color: kPrimaryColor,
                                            ),
                                            control: Single_ControllerBioAr,
                                            isObsecured: false,
                                            validate: true,
                                            textInputType: TextInputType.text),
                                        TextFormFieldStyle(
                                            context: context,
                                            hint: "BioEn",
                                            // ignore: prefer_const_constructors
                                            icon: Icon(
                                              Icons.single_bed,
                                              color: kPrimaryColor,
                                            ),
                                            control: Single_ControllerBioEn,
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
                                      Single = false;
                                    });
                                  },
                                ))
                              ],
                            ),
                            visible: Single,
                          ),
                          Visibility(
                              visible: !Double,
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
                                      value: Double,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          Double = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )),
                          Visibility(
                              visible: Double,
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
                                            TextHedar("Double"),
                                            TextFormFieldStyle(
                                                context: context,
                                                hint: "Double1",
                                                // ignore: prefer_const_constructors
                                                icon: Icon(
                                                  Icons.single_bed,
                                                  color: kPrimaryColor,
                                                ),
                                                control: Double_Controller,
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
                                                  color: kPrimaryColor,
                                                ),
                                                control: Double_ControllerBioAr,
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
                                                  color: kPrimaryColor,
                                                ),
                                                control: Double_ControllerBioEn,
                                                isObsecured: false,
                                                validate: true,
                                                textInputType:
                                                    TextInputType.text)
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: closeTextFormFieldStyle(() {
                                        setState(() {
                                          Double = false;
                                        });
                                      }))
                                ],
                              )),
                          Visibility(
                              visible: !Swite,
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
                                      value: Swite,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          Swite = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )),
                          Visibility(
                              visible: Swite,
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
                                            TextHedar("Swite"),
                                            TextFormFieldStyle(
                                                context: context,
                                                hint: "Swite1",
                                                // ignore: prefer_const_constructors
                                                icon: Icon(
                                                  Icons.single_bed,
                                                  color: kPrimaryColor,
                                                ),
                                                control: Swite_Controller,
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
                                                  color: kPrimaryColor,
                                                ),
                                                control: Swite_ControllerBioAr,
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
                                                  color: kPrimaryColor,
                                                ),
                                                control: Swite_ControllerBioEn,
                                                isObsecured: false,
                                                validate: true,
                                                textInputType:
                                                    TextInputType.text)
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: closeTextFormFieldStyle(() {
                                        setState(() {
                                          Swite = false;
                                        });
                                      }))
                                ],
                              )),
                          Visibility(
                              visible: !Family,
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
                                      value: Family,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          Family = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )),
                          Visibility(
                              visible: Family,
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
                                            TextHedar("Family"),
                                            TextFormFieldStyle(
                                                context: context,
                                                hint: "Family1",
                                                // ignore: prefer_const_constructors
                                                icon: Icon(
                                                  Icons.single_bed,
                                                  color: kPrimaryColor,
                                                ),
                                                control: Famely_Controller,
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
                                                  color: kPrimaryColor,
                                                ),
                                                control: Famely_ControllerBioAr,
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
                                                  color: kPrimaryColor,
                                                ),
                                                control: Famely_ControllerBioEn,
                                                isObsecured: false,
                                                validate: true,
                                                textInputType:
                                                    TextInputType.text)
                                          ],
                                        ),
                                      )),
                                  Expanded(child: closeTextFormFieldStyle(() {
                                    setState(() {
                                      Family = false;
                                    });
                                  }))
                                ],
                              )),
                          // ignore: prefer_const_constructors
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      )),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 30,
                  ),
                ],
              )),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      // ignore: sort_child_properties_last
                      child: Visibility(
                          visible: objEstate['Type'] == "1",
                          child: InkWell(
                            child: Container(
                              width: 150.w,
                              height: 6.h,
                              margin: const EdgeInsets.only(
                                  right: 20, left: 20, bottom: 30),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // ignore: prefer_const_constructors
                              child: Center(
                                child: Text(
                                  getTranslated(context, "Skip"),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () async {
                              Map e = Map();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AdditionalFacility(
                                        CheckState: "Edit",
                                        CheckIsBooking: false,
                                        estate: e,
                                        IDEstate:
                                            objEstate['IDEstate'].toString(),
                                      )));
                            },
                          )),
                      flex: 2,
                    ),
                    // ignore: sort_child_properties_last
                    Expanded(
                      // ignore: sort_child_properties_last
                      child: InkWell(
                        child: Container(
                          width: 150.w,
                          height: 6.h,
                          margin: const EdgeInsets.only(
                              right: 20, left: 20, bottom: 20),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ignore: prefer_const_constructors
                          child: Center(
                            child: Text(
                              getTranslated(context, "Next"),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: () async {
                          Map e = Map();
                          Update();
                          if (objEstate['Type'] == "1") {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AdditionalFacility(
                                      CheckState: "Edit",
                                      CheckIsBooking: false,
                                      estate: e,
                                      IDEstate:
                                          objEstate['IDEstate'].toString(),
                                    )));
                          }
                        },
                      ),
                      flex: 3,
                    ),
                  ],
                )),
          ],
        ));
  }

  Update() async {
    String ChildType;
    String type;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (objEstate['Type'] == "1") {
      ChildType = "Hottel";
      type = "1";
    } else if (objEstate['Type'] == "2") {
      ChildType = "Coffee";
      type = "2";
    } else {
      ChildType = "Restaurant";
      type = "3";
    }
    String? TypeAccount = sharedPreferences.getString("TypeAccount") ?? "2";
    await ref.child(ChildType).child(objEstate['IDEstate'].toString()).update({
      "NameAr": Name_Controller.text,
      "NameEn": EnName_Controller.text,
      "BioAr": Bio_Controller.text,
      "BioEn": EnBio_Controller.text,
      "Country": countryValue,
      "City": cityValue,
      "State": stateValue,
      "Type": type,
      "IDUser": sharedPreferences.getString("ID")!,
      "IDEstate": objEstate['IDEstate'],
      "TypeAccount": TypeAccount
    });

    DatabaseReference refRooms =
        FirebaseDatabase.instance.ref("App").child("Rooms");
    if (Single) {
      await refRooms
          .child(objEstate['IDEstate'].toString())
          .child("Single")
          .update({
        "ID": Single_ControllerID.text,
        "Name": "Single",
        "Price": Single_Controller.text,
        "BioAr": Single_ControllerBioAr.text,
        "BioEn": Single_ControllerBioEn.text,
      });
    }
    if (Double) {
      await refRooms
          .child(objEstate['IDEstate'].toString())
          .child("Double")
          .update({
        "ID": Double_ControllerID.text,
        "Name": "Double",
        "Price": Double_Controller.text,
        "BioAr": Double_ControllerBioAr.text,
        "BioEn": Double_ControllerBioEn.text,
      });
    }
    if (Swite) {
      await refRooms
          .child(objEstate['IDEstate'].toString())
          .child("Swite")
          .update({
        "ID": Swite_ControllerID.text,
        "Name": "Swite",
        "Price": Swite_Controller.text,
        "BioAr": Swite_ControllerBioAr.text,
        "BioEn": Swite_ControllerBioEn.text,
      });
    }
    if (Family) {
      await refRooms
          .child(objEstate['IDEstate'].toString())
          .child("Family")
          .set({
        "ID": Famely_ControllerID.text,
        "Name": "Family",
        "Price": Famely_Controller.text,
        "BioAr": Famely_ControllerBioAr.text,
        "BioEn": Famely_ControllerBioEn.text,
      });
    }
  }

  ChoeseCity() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 30),
      child: CSCPicker(
        ///Enable disable state dropdown [OPTIONAL PARAMETER]
        showStates: true,

        /// Enable disable city drop down [OPTIONAL PARAMETER]
        showCities: true,

        ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
        flagState: CountryFlag.DISABLE,

        ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
        dropdownDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1)),

        ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
        disabledDropdownDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade300, width: 1)),

        ///placeholders for dropdown search field
        countrySearchPlaceholder: "Country",
        stateSearchPlaceholder: "State",
        citySearchPlaceholder: "City",

        ///labels for dropdown
        countryDropdownLabel: Country_Controller.text,
        stateDropdownLabel: State_Controller.text,
        cityDropdownLabel: City_Controller.text,

        ///Default Country
        //defaultCountry: DefaultCountry.India,

        ///Disable country dropdown (Note: use it with default country)
        //disableCountry: true,

        ///selected item style [OPTIONAL PARAMETER]
        // ignore: prefer_const_constructors
        selectedItemStyle: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),

        ///DropdownDialog Heading style [OPTIONAL PARAMETER]
        // ignore: prefer_const_constructors
        dropdownHeadingStyle: TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),

        ///DropdownDialog Item style [OPTIONAL PARAMETER]
        // ignore: prefer_const_constructors
        dropdownItemStyle: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),

        ///Dialog box radius [OPTIONAL PARAMETER]
        dropdownDialogRadius: 10.0,

        ///Search bar radius [OPTIONAL PARAMETER]
        searchBarRadius: 10.0,

        ///triggers once country selected in dropdown
        onCountryChanged: (value) {
          setState(() {
            ///store value in country variable
            countryValue = value;
          });
        },
        onStateChanged: (value) {
          setState(() {
            ///store value in state variable
            stateValue = value;
          });
        },

        ///triggers once city selected in dropdown
        onCityChanged: (value) {
          setState(() {
            ///store value in city variable
            cityValue = value;
          });
        },

        ///triggers once state selected in dropdown
      ),
    );
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
