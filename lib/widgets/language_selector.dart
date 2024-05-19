// import 'package:flutter/material.dart';
//
// import '../constants/colors.dart';
// // Import the main.dart file where MyApp is defined
//
// class LanguageSelector extends StatefulWidget {
//   final String selectedLanguage;
//   final Function(String) onLanguageChanged;
//
//   const LanguageSelector({
//     super.key,
//     required this.selectedLanguage,
//     required this.onLanguageChanged,
//   });
//
//   @override
//   _LanguageSelectorState createState() => _LanguageSelectorState();
// }
//
// class _LanguageSelectorState extends State<LanguageSelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(
//         right: 10,
//         top: 10,
//       ),
//       child: DropdownButton<String>(
//         value: widget.selectedLanguage,
//         icon: const Icon(
//           Icons.language,
//           color: Colors.black,
//         ),
//         dropdownColor: kPrimaryColor,
//         onChanged: (String? newValue) {
//           if (newValue != null) {
//             widget.onLanguageChanged(newValue);
//           }
//         },
//         items:
//             <String>['en', 'ar'].map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(
//               value == 'en' ? 'en' : 'ar',
//               style: const TextStyle(color: Colors.black),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
