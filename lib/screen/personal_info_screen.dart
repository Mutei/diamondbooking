import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chooseCity.dart';
import '../constants/colors.dart';
import '../widgets/text_form_style.dart';
import 'main_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String password;
  final String typeUser;
  final String typeAccount;
  final String? restorationId;

  const PersonalInfoScreen({
    super.key,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.typeUser,
    required this.typeAccount,
    this.restorationId,
  });

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with RestorationMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bodController = TextEditingController();
  String countryValue = '';
  String? stateValue = "";
  String? cityValue = "";
  bool validateSpecialDate = false;
  String? get restorationId => widget.restorationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _lastNameController.dispose();
    _bodController.dispose();
    super.dispose();
  }

  void _saveUserInfo() async {
    if (_firstNameController.text.isEmpty ||
        _secondNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        countryValue.isEmpty ||
        stateValue!.isEmpty ||
        cityValue!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user != null) {
      final userData = {
        'FirstName': _firstNameController.text,
        'SecondName': _secondNameController.text,
        'LastName': _lastNameController.text,
        'Email': widget.email,
        'PhoneNumber': widget.phoneNumber,
        'Password': widget.password,
        'DateOfBirth': _bodController.text,
        'Country': countryValue,
        'State': stateValue,
        'City': cityValue,
        'TypeUser': widget.typeUser,
        'TypeAccount': widget.typeAccount,
      };

      DatabaseReference ref =
          FirebaseDatabase.instance.ref("App").child("User").child(user.uid);
      await ref.set(userData);

      // Save the user type in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("TypeUser", widget.typeUser);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor, // color of the header and selected date
              onPrimary: Colors
                  .white, // color of the text on the header and selected date
              surface: Colors.white, // background color of the header
              onSurface: Colors.black, // text color on the body
            ),
            dialogBackgroundColor:
                Colors.lightBlue[50], // background color of the dialog
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: DatePickerDialog(
            restorationId: 'date_picker_dialog',
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
            firstDate: DateTime(1900),
            lastDate: DateTime(2024),
          ),
        );
      },
    );
  }

  final RestorableDateTime _selectedDate =
      RestorableDateTime(DateTime(2021, 7, 25));
  late final RestorableRouteFuture<DateTime?>
      _restorableBODDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectBirthOfDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableBODDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectBirthOfDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        _bodController.text =
            '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fill up your Personal Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _secondNameController,
                decoration: const InputDecoration(labelText: 'Second Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 10),
              InkWell(
                child: TextFormFieldStyle(
                  context: context,
                  hint: "Birthday",
                  // ignore: prefer_const_constructors
                  icon: Icon(
                    Icons.calendar_month,
                    color: kPrimaryColor,
                  ),
                  control: _bodController,
                  isObsecured: false,
                  validate: validateSpecialDate,
                  textInputType: TextInputType.text,
                ),
                onTap: () {
                  _restorableBODDatePickerRouteFuture.present();
                },
              ),
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
              const SizedBox(height: 10),
              // Add your custom CSC Picker here
              ElevatedButton(
                onPressed: _saveUserInfo,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../chooseCity.dart';
// import '../constants/colors.dart';
// import '../widgets/text_form_style.dart';
// import 'main_screen.dart';
//
// class PersonalInfoScreen extends StatefulWidget {
//   final String email;
//   final String phoneNumber;
//   final String password;
//   final String typeUser;
//   final String typeAccount;
//   final String? restorationId;
//
//   const PersonalInfoScreen({
//     super.key,
//     required this.email,
//     required this.phoneNumber,
//     required this.password,
//     required this.typeUser,
//     required this.typeAccount,
//     this.restorationId,
//   });
//
//   @override
//   _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
// }
//
// class _PersonalInfoScreenState extends State<PersonalInfoScreen>
//     with RestorationMixin {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _secondNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _bodController = TextEditingController();
//   String countryValue = '';
//   String? stateValue = "";
//   String? cityValue = "";
//   bool validateSpecialDate = false;
//   String? get restorationId => widget.restorationId;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _secondNameController.dispose();
//     _lastNameController.dispose();
//     _bodController.dispose();
//     super.dispose();
//   }
//
//   void _saveUserInfo() async {
//     if (_firstNameController.text.isEmpty ||
//         _secondNameController.text.isEmpty ||
//         _lastNameController.text.isEmpty ||
//         countryValue.isEmpty ||
//         stateValue!.isEmpty ||
//         cityValue!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }
//
//     User? user = _auth.currentUser;
//     if (user != null) {
//       final userData = {
//         'FirstName': _firstNameController.text,
//         'SecondName': _secondNameController.text,
//         'LastName': _lastNameController.text,
//         'Email': widget.email,
//         'PhoneNumber': widget.phoneNumber,
//         'Password': widget.password,
//         'DateOfBirth': _bodController.text,
//         'Country': countryValue,
//         'State': stateValue,
//         'City': cityValue,
//         'TypeUser': widget.typeUser,
//         'TypeAccount': widget.typeAccount,
//       };
//
//       DatabaseReference ref =
//           FirebaseDatabase.instance.ref("App").child("User").child(user.uid);
//       await ref.set(userData);
//
//       // Save the user type in SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString("TypeUser", widget.typeUser);
//
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const MainScreen()),
//         (Route<dynamic> route) => false,
//       );
//     }
//   }
//
//   static Route<DateTime> _datePickerRoute(
//     BuildContext context,
//     Object? arguments,
//   ) {
//     return DialogRoute<DateTime>(
//       context: context,
//       builder: (BuildContext context) {
//         return Theme(
//           data: ThemeData(
//             colorScheme: const ColorScheme.light(
//               primary: kPrimaryColor, // color of the header and selected date
//               onPrimary: Colors
//                   .white, // color of the text on the header and selected date
//               surface: Colors.white, // background color of the header
//               onSurface: Colors.black, // text color on the body
//             ),
//             dialogBackgroundColor:
//                 Colors.lightBlue[50], // background color of the dialog
//             buttonTheme: const ButtonThemeData(
//               textTheme: ButtonTextTheme.primary,
//             ),
//           ),
//           child: DatePickerDialog(
//             restorationId: 'date_picker_dialog',
//             initialEntryMode: DatePickerEntryMode.calendarOnly,
//             initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
//             firstDate: DateTime(1900),
//             lastDate: DateTime(2024),
//           ),
//         );
//       },
//     );
//   }
//
//   final RestorableDateTime _selectedDate =
//       RestorableDateTime(DateTime(2021, 7, 25));
//   late final RestorableRouteFuture<DateTime?>
//       _restorableBODDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
//     onComplete: _selectBirthOfDate,
//     onPresent: (NavigatorState navigator, Object? arguments) {
//       return navigator.restorablePush(
//         _datePickerRoute,
//         arguments: _selectedDate.value.millisecondsSinceEpoch,
//       );
//     },
//   );
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_selectedDate, 'selected_date');
//     registerForRestoration(
//         _restorableBODDatePickerRouteFuture, 'date_picker_route_future');
//   }
//
//   void _selectBirthOfDate(DateTime? newSelectedDate) {
//     if (newSelectedDate != null) {
//       setState(() {
//         _selectedDate.value = newSelectedDate;
//         _bodController.text =
//             '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Fill up your Personal Information"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _firstNameController,
//                 decoration: const InputDecoration(labelText: 'First Name'),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _secondNameController,
//                 decoration: const InputDecoration(labelText: 'Second Name'),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _lastNameController,
//                 decoration: const InputDecoration(labelText: 'Last Name'),
//               ),
//               const SizedBox(height: 10),
//               InkWell(
//                 child: TextFormFieldStyle(
//                   context: context,
//                   hint: "Birthday",
//                   // ignore: prefer_const_constructors
//                   icon: Icon(
//                     Icons.calendar_month,
//                     color: kPrimaryColor,
//                   ),
//                   control: _bodController,
//                   isObsecured: false,
//                   validate: validateSpecialDate,
//                   textInputType: TextInputType.text,
//                 ),
//                 onTap: () {
//                   _restorableBODDatePickerRouteFuture.present();
//                 },
//               ),
//               CustomCSCPicker(
//                 onCountryChanged: (value) {
//                   setState(() {
//                     countryValue = value;
//                   });
//                 },
//                 onStateChanged: (value) {
//                   setState(() {
//                     stateValue = value;
//                   });
//                 },
//                 onCityChanged: (value) {
//                   setState(() {
//                     cityValue = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),
//               // Add your custom CSC Picker here
//               ElevatedButton(
//                 onPressed: _saveUserInfo,
//                 child: const Text('Continue'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
