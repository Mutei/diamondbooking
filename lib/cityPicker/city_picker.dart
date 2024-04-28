import 'package:flutter/material.dart';
import 'package:csc_picker/csc_picker.dart';
import '../localization/language_constants.dart';

class CityPicker extends StatefulWidget {
  const CityPicker({super.key});

  @override
  State createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  late String countryValue = "";
  late String? stateValue = "";
  late String? cityValue = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CSCPicker(
        showStates: true,
        showCities: true,
        flagState: CountryFlag.ENABLE,
        dropdownDecoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        disabledDropdownDecoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        countrySearchPlaceholder: "Country",
        stateSearchPlaceholder: "State",
        citySearchPlaceholder: "City",
        countryDropdownLabel: getTranslated(context, "*Country"),
        stateDropdownLabel: getTranslated(context, "*State"),
        cityDropdownLabel: getTranslated(context, "*City"),
        selectedItemStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        dropdownHeadingStyle: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        dropdownItemStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        dropdownDialogRadius: 10.0,
        searchBarRadius: 10.0,
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
    );
  }
}
// chooseCity() {
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//     padding: const EdgeInsets.symmetric(horizontal: 10),
//     child: CSCPicker(
//       ///Enable disable state dropdown [OPTIONAL PARAMETER]
//       showStates: true,
//
//       /// Enable disable city drop down [OPTIONAL PARAMETER]
//       showCities: true,
//
//       ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
//       flagState: CountryFlag.DISABLE,
//
//       ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
//       dropdownDecoration: BoxDecoration(
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade300, width: 1)),
//
//       ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
//       disabledDropdownDecoration: BoxDecoration(
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//           color: Colors.grey.shade300,
//           border: Border.all(color: Colors.grey.shade300, width: 1)),
//
//       ///placeholders for dropdown search field
//       countrySearchPlaceholder: "Country",
//       stateSearchPlaceholder: "State",
//       citySearchPlaceholder: "City",
//
//       ///labels for dropdown
//       countryDropdownLabel: getTranslated(context, "*Country"),
//       stateDropdownLabel: getTranslated(context, "*State"),
//       cityDropdownLabel: getTranslated(context, "*City"),
//
//       ///Default Country
//       //defaultCountry: DefaultCountry.India,
//
//       ///Disable country dropdown (Note: use it with default country)
//       //disableCountry: true,
//
//       ///selected item style [OPTIONAL PARAMETER]
//       // ignore: prefer_const_constructors
//       selectedItemStyle: TextStyle(
//         color: Colors.black,
//         fontSize: 14,
//       ),
//
//       ///DropdownDialog Heading style [OPTIONAL PARAMETER]
//       // ignore: prefer_const_constructors
//       dropdownHeadingStyle: TextStyle(
//           color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
//
//       ///DropdownDialog Item style [OPTIONAL PARAMETER]
//       // ignore: prefer_const_constructors
//       dropdownItemStyle: TextStyle(
//         color: Colors.black,
//         fontSize: 14,
//       ),
//
//       ///Dialog box radius [OPTIONAL PARAMETER]
//       dropdownDialogRadius: 10.0,
//
//       ///Search bar radius [OPTIONAL PARAMETER]
//       searchBarRadius: 10.0,
//
//       ///triggers once country selected in dropdown
//       onCountryChanged: (value) {
//         setState(() {
//           ///store value in country variable
//           countryValue = value;
//         });
//       },
//       onStateChanged: (value) {
//         setState(() {
//           ///store value in state variable
//           stateValue = value;
//         });
//       },
//
//       ///triggers once city selected in dropdown
//       onCityChanged: (value) {
//         setState(() {
//           ///store value in city variable
//           cityValue = value;
//         });
//       },
//
//       ///triggers once state selected in dropdown
//     ),
//   );
// }
