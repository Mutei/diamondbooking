// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, unnecessary_brace_in_string_interps

import 'package:csc_picker/csc_picker.dart';
import 'package:diamond_booking/widgets/text_form_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';

class FiltterHotel extends StatefulWidget {
  @override
  String Type;

  FiltterHotel({required this.Type});
  _State createState() => new _State(Type);
}

class _State extends State<FiltterHotel> {
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  TextEditingController TaxNumer_Controller = TextEditingController();
  TextEditingController toPrice_Controller = TextEditingController();

  late String? countryValue;
  late String? stateValue;
  late String? cityValue;
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
        backgroundColor: const Color(0xFFE8C75B),
      ),
      body: Container(
          child: ListView(
        children: [
          SizedBox(
            height: 25,
          ),
          ChoeseCity(),
          SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: TextFormFieldStyle(
                      context: context,
                      hint: "Price From ",
                      // ignore: prefer_const_constructors
                      icon: Icon(
                        Icons.money,
                        color: const Color(0xFFE8C75B),
                      ),
                      control: TaxNumer_Controller,
                      isObsecured: false,
                      validate: true,
                      textInputType: TextInputType.text),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: TextFormFieldStyle(
                      context: context,
                      hint: "To Price",
                      // ignore: prefer_const_constructors
                      icon: Icon(
                        Icons.money,
                        color: const Color(0xFFE8C75B),
                      ),
                      control: toPrice_Controller,
                      isObsecured: false,
                      validate: true,
                      textInputType: TextInputType.text),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                LstSessions.add(countryValue!);
                LstSessions.add(stateValue!);
                // LstSessions.add(cityValue!);
                String flag = "0";
                String flagPrice = "0";
                if (LstSessions.length == 0) {
                  flag = "1";
                }
                if (toPrice_Controller.text.isEmpty ||
                    TaxNumer_Controller.text.isEmpty) {
                  flagPrice = "1";
                }
                String text =
                    "${LstSessions.join(",")}&${"${TaxNumer_Controller.text},${toPrice_Controller.text}&${flag}&${flagPrice}"}";
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
          )
        ],
      )),
    );
  }

  ChoeseCity() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 30),
      child: CSCPicker(
        ///Enable disable state dropdown [OPTIONAL PARAMETER]
        showStates: true,

        /// Enable disable city drop down [OPTIONAL PARAMETER]
        showCities: false,

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
        countryDropdownLabel: getTranslated(context, "*Country"),
        stateDropdownLabel: getTranslated(context, "*State"),
        cityDropdownLabel: getTranslated(context, "*City"),

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
