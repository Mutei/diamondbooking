import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_type_screen.dart';
import '../main.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _State createState() => _State();
}

class _State extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterLayoutWidgetBuild());
  }

  void afterLayoutWidgetBuild() async {
    final String defaultLocale = Platform.localeName;
    Locale newLocale = Locale(defaultLocale.split('_')[0], "SA");
    MyApp.setLocale(context, newLocale);
    bool check = await checkLogin();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("Language", defaultLocale.split('_')[0]);
    String? autoLogin = sharedPreferences.getString("auto");
    String? id = sharedPreferences.getString("id");
    String? userType = sharedPreferences.getString("TypeUser");

    await Future.delayed(const Duration(seconds: 5)).then((value) {
      if (autoLogin == "1" && (id != null || id!.isNotEmpty)) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MainScreen()));
      } else if (check) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LoginScreen(
                  title: '',
                  userType: userType, // Pass the userType here
                )));
      } else {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ChooseTypeUser()));
      }
    });
  }

  Future<bool> checkLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? login = sharedPreferences.getString("TypeUser");
    if (login == null || login.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return new Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // ignore: prefer_const_constructors
        child: Center(
            child: InkWell(
          // ignore: sort_child_properties_last
          child: const SizedBox(
              width: 150,
              height: 150,
              child: Image(
                image: AssetImage("assets/images/logo.png"),
              )),
          onTap: (() {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MainScreen()));
          }),
        )),
      ),
    );
  }
}
