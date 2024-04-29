import 'package:country_code_picker/country_code_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/screen/login_screen.dart';
import 'package:diamond_booking/screen/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../resources/auth_methods.dart';
import '../textFormField/text_form_style.dart';

class SignInScreen extends StatefulWidget {
  String type;

  SignInScreen({super.key, this.restorationId, required this.type});

  final String? restorationId;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with RestorationMixin {
  String verificationID = "";
  @override
  String? get restorationId => widget.restorationId;
  String? get type => widget.type;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bodController = TextEditingController();
  final TextEditingController _specialDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool validateEmail = true;
  bool validatePassword = true;
  bool validateName = true;
  bool validateBOD = false;
  bool validateSpecialDate = false;
  bool validatePhone = true;
  bool validateCountry = false;
  bool validateCity = false;
  FocusNode focusNode = FocusNode();
  String countryCodePhone = "";
  late String countryValue = "";
  late String? stateValue = "";
  late String? cityValue = "";
  bool _isLoading = false;
  Widget btnLoginx = Text("Sign In");
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");
  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bodController.dispose();
    _specialDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? typeUser = sharedPreferences.getString("TypeUser");
    String res = await AuthMethods().signUpUser(
      userName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
      countryCode: countryCodePhone,
      countryValue: countryValue,
      stateValue: stateValue!,
      cityValue: cityValue!,
      bod: _bodController.text,
      typeAccount: type!,
      typeUser: typeUser!,
    );
    print(res);
  }

  signInFireBase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? id = FirebaseAuth.instance.currentUser?.uid;
    String? typeUser = sharedPreferences.getString("TypeUser");
    try {
      debugPrint(
          'HERE ARE THE >>>>>> countryValue: $countryValue, stateValue: $stateValue, cityValue: $cityValue');
      _showMyDialog();
      sharedPreferences.setString("TypeAccount", type!);
      sharedPreferences.setString("Name", _nameController.text);
      sharedPreferences.setString("Birth of Date", _bodController.text);
      sharedPreferences.setString("Special Date", _specialDateController.text);
      sharedPreferences.setString("Email", _emailController.text);
      sharedPreferences.setString("Phone", _phoneController.text);
      sharedPreferences.setString("Email", _emailController.text);
      sharedPreferences.setString("Pass", _passwordController.text);
      sharedPreferences.setString("cityValue", cityValue ?? "default_city");
      sharedPreferences.setString("stateValue", stateValue ?? "default_state");
      sharedPreferences.setString(
          "countryValue", countryValue ?? "default_country");
      sharedPreferences.setString("ID", id!);
      sharedPreferences.setString("TypeUser", typeUser ?? "default_type");
    } catch (e) {
      print("Error saving data to Firebase Realtime Database: $e");
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // ignore: unnecessary_const
          title: Text(
            getTranslated(context, "Notes..."),
            // ignore: prefer_const_constructors
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
          ),
          content: RichText(
            // ignore: prefer_const_constructors
            text: TextSpan(
              text: getTranslated(
                  context, 'We will send a verification code to '),
              style: GoogleFonts.laila(
                  fontSize: 6.w,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              // ignore: prefer_const_literals_to_create_immutables
              children: <TextSpan>[
                TextSpan(
                  text: countryCodePhone + _phoneController.text,
                  // ignore: prefer_const_constructors
                  style: kPrimaryTypeStyle,
                ),
                TextSpan(
                    text: getTranslated(
                        context, 'Are you sure the number is correct?'),
                    style: GoogleFonts.laila(
                        fontSize: 6.w,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                getTranslated(context, 'Confirm'),
                style: const TextStyle(
                  color: kConfirmTextColor,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VerificationPhone(
                          verificationId: "",
                          countryCodePhone: countryCodePhone,
                          phone: _phoneController.text,
                        )));
              },
            ),
            TextButton(
              child: Text(
                getTranslated(context, 'close'),
                style: const TextStyle(
                  color: kCloseTextColor,
                ),
              ),
              onPressed: () async {
                setState(() {
                  // ignore: prefer_const_constructors
                  btnLoginx = Center(
                      // ignore: prefer_const_constructors
                      child: Text("Sign In"));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  void _onCountryChange(CountryCode countryCode) {
    //TODO : manipulate the selected country code here
    countryCodePhone = countryCode.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: true);
    objProvider.CheckLang();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                ),
                TextFormFieldStyle(
                  context: context,
                  hint: "UserName",
                  icon: const Icon(
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  control: _nameController,
                  isObsecured: false,
                  validate: validateEmail,
                  textInputType: TextInputType.text,
                  showVisibilityToggle: false,
                ),
                TextFormFieldStyle(
                  context: context,
                  hint: "Email",
                  icon: const Icon(
                    Icons.email,
                    color: kPrimaryColor,
                  ),
                  control: _emailController,
                  isObsecured: false,
                  validate: validateEmail,
                  textInputType: TextInputType.emailAddress,
                  showVisibilityToggle: false,
                ),
                TextFormFieldStyle(
                  context: context,
                  hint: "Phone Number",
                  prefixIconWidget: SizedBox(
                    width:
                        130, // Adjust the width of the container holding the CountryCodePicker
                    child: CountryCodePicker(
                      onChanged: _onCountryChange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5), // Reduce horizontal padding
                      initialSelection: 'IT',
                      favorite: const ['+966', 'SA'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: true,
                    ),
                  ),
                  control: _phoneController,
                  isObsecured: false,
                  validate: validatePassword,
                  textInputType: TextInputType.phone,
                  showVisibilityToggle: false,
                ),
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
                TextFormFieldStyle(
                  context: context,
                  hint: "Password",
                  icon: const Icon(
                    Icons.lock,
                    color: kPrimaryColor,
                  ),
                  control: _passwordController,
                  isObsecured: true,
                  validate: validatePassword,
                  textInputType: TextInputType.text,
                  showVisibilityToggle: true,
                ),
                chooseCity(),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          _bodController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          countryValue.isEmpty ||
                          cityValue!.isEmpty ||
                          stateValue!.isEmpty) {
                        // Add checks and potentially use SnackBar to show errors.
                        getTranslated(
                          context,
                          objProvider.FunSnackBarPage(
                              'All Fields must be filled', context),
                        );
                      } else {
                        signUpUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                      backgroundColor: kPrimaryColor,
                    ),
                    child: Text(
                      getTranslated(context, 'Sign Up'),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                        height:
                            10), // Add some space before the first button if necessary
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen(title: '')));
                      },
                      child: Text(
                        getTranslated(context, 'Login'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kSecondaryColor,
                        ),
                      ),
                    ),
                    // Spacing between buttons
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        getTranslated(context, 'Login as Guest'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kSecondaryColor,
                        ),
                      ),
                    ),
                    // Spacing between buttons
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        getTranslated(context, 'Forgot password'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kSecondaryColor,
                        ),
                      ),
                    ),
                    // Add some space after the last button if necessary
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  chooseCity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CSCPicker(
        ///Enable disable state dropdown [OPTIONAL PARAMETER]
        showStates: true,

        /// Enable disable city drop down [OPTIONAL PARAMETER]
        showCities: true,

        ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
        flagState: CountryFlag.ENABLE,

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
}
