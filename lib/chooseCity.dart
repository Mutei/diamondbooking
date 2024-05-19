import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';

class CustomCSCPicker extends StatefulWidget {
  final void Function(String) onCountryChanged;
  final void Function(String?) onStateChanged;
  final void Function(String?) onCityChanged;

  const CustomCSCPicker({
    super.key,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
  });

  @override
  State<CustomCSCPicker> createState() => _CustomCSCPickerState();
}

class _CustomCSCPickerState extends State<CustomCSCPicker> {
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
            border: Border.all(color: Colors.grey.shade300, width: 1)),
        disabledDropdownDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade300, width: 1)),
        countrySearchPlaceholder: "Country",
        stateSearchPlaceholder: "State",
        citySearchPlaceholder: "City",
        countryDropdownLabel: "Country",
        stateDropdownLabel: "State",
        cityDropdownLabel: "City",
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
        onCountryChanged: widget.onCountryChanged,
        onStateChanged: widget.onStateChanged,
        onCityChanged: widget.onCityChanged,
      ),
    );
  }
}
